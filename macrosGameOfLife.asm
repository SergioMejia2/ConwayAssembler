.eqv	DIR_BASE	0x10000000	#Dirección base de la matriz de pixeles del Bitmap-Display
.eqv	WHITE		0x00FFFFFF	#Equivalente del color blanco en hexadecimal
.eqv	BLACK		0x00000000	#Equivalente del color negro en hexadecimal
.eqv	COLOR_ALIVE	0x0000994C	#Equivalente del color verde (color de la vida en nuestro programa) en hexadecimal

#								#
# Macro utilizado para cerrar el syscall y terminar el programa	#
#								#
.macro Fin 
	li $v0, 10
	syscall
.end_macro

#						#
#  Macro para poner en blanco todo el display	#
#						#
.macro ClearDisplay
	li $t8, DIR_BASE
	add $t9, $zero, $t8
	li $s7, WHITE
	li $s6, 0
	bucle:
		beq $s6, 256, finBucle
		sw $s7, 0($t9)
		addi $t9, $t9, 4
		addi $s6, $s6, 1
	j bucle	
	finBucle:
.end_macro

#									#
#           Macro encargado de pintar un punto en el display		#
#  Recibe una coordenada (x,y) y el color del que se pintara el punto	#
#									#
.macro PintarPunto(%x, %y, %color)
	add $t5, $zero, %x
	add $t6, $zero, %y
	li $s5, %color
	jal generarDireccion
	sw $s5, 0($t7)
.end_macro

#											#
#    Macro que recibe un tiempo en milisegundos y duerme el programa por este tiempo	#
#											#
.macro EsperarTiempo(%tiempo)
	li $v0, 32
	add $a0, $zero, %tiempo
	syscall
.end_macro

#								#
#    Macro que pinta el logo incial del juego en el display	#
#								#
.macro ImprimirLogo

	li $t8, 0	#Contador del bucle que pinta el marco superior y el izquierdo
	
	# Bucle encargado de pintar la seccion superior e izquierda del marco del logo
	bucle1:
		beq $t8, 16, finBucle1
		PintarPunto($t8,0,WHITE)
		PintarPunto(0,$t8,WHITE)
		EsperarTiempo(60)
		addi $t8, $t8, 1
	j bucle1
	finBucle1:
	
	li $t8, 0	#Contador del bucle que pinta el marco derecho y el inferior
	
	# Bucle encargado de pintar la seccion derecha e inferior del marco del logo
	bucle2:
		beq $t8, 16, finBucle2
		PintarPunto($t8,15,WHITE)
		PintarPunto(15,$t8,WHITE)
		EsperarTiempo(60)
		addi $t8, $t8, 1
	j bucle2
	finBucle2:
	
	# Sección encargada de pintar punto a punto cada punto del logo del juego
	PintarPunto(2,13,WHITE)
	EsperarTiempo(60)
	PintarPunto(3,12,WHITE)
	EsperarTiempo(60)
	PintarPunto(3,11,WHITE)
	EsperarTiempo(60)
	PintarPunto(3,10,WHITE)
	PintarPunto(4,11,WHITE)
	EsperarTiempo(60)
	PintarPunto(3,9,WHITE)
	PintarPunto(4,10,WHITE)
	PintarPunto(5,11,WHITE)
	EsperarTiempo(60)
	PintarPunto(3,8,WHITE)
	PintarPunto(5,9,WHITE)
	PintarPunto(6,11,WHITE)
	EsperarTiempo(60)
	PintarPunto(3,7,WHITE)
	PintarPunto(7,11,WHITE)
	EsperarTiempo(60)
	PintarPunto(4,6,WHITE)
	PintarPunto(6,8,WHITE)
	PintarPunto(8,10,WHITE)
	EsperarTiempo(60)
	PintarPunto(5,5,WHITE)
	PintarPunto(7,7,WHITE)
	PintarPunto(9,9,WHITE)
	EsperarTiempo(60)
	PintarPunto(6,4,WHITE)
	PintarPunto(10,8,WHITE)
	EsperarTiempo(60)
	PintarPunto(7,4,WHITE)
	PintarPunto(10,7,WHITE)
	EsperarTiempo(60)
	PintarPunto(8,3,WHITE)
	PintarPunto(11,6,WHITE)
	EsperarTiempo(60)
	PintarPunto(9,3,WHITE)
	PintarPunto(11,5,WHITE)
	EsperarTiempo(60)
	PintarPunto(10,3,WHITE)
	PintarPunto(11,4,WHITE)
	EsperarTiempo(60)
	PintarPunto(11,3,WHITE)
.end_macro 

#													#
#  Macro que recibe una direccion de memoria de una matriz de memoria y la pinta en el Bitmap-Display	#
#													#
.macro PintarMatriz(%val_word)
	add $t8, $zero, %val_word
	la $s7, DIR_BASE
	bucle:
	lb $t9, 0($t8)
	beq $t9, 0, finBucle
	beq $t9, '0', celulaMuerta
	li $s5, COLOR_ALIVE
	sw $s5, 0($s7)
	j adicion
	celulaMuerta:
	li $s5, WHITE
	sw $s5, 0($s7)
	adicion:
	addi $s7, $s7, 4
	addi $t8, $t8, 1
	j bucle
	finBucle:
.end_macro

#											#
#   Macro encargado de verificar si un punto se encuentra dentro del Bitmap-Display	#
#											#
.macro ValidarPunto (%x, %y)
	bltz %x, noValido
	bltz %y, noValido
	bgt %x, 15, noValido
	bgt %y, 15, noValido
	li $s5, 1
	j finMacro
	noValido:
	li $s5, 0
	finMacro:
.end_macro

#												#
#                  Macro encargado de decir si una celula vive o muere				#
#    Recibe una cordenada (x,y) del Bitmap display y analiza las celulas alrededor de este	#
#	        		Llama al macro de ValidarPunto					#
.macro VerificarPunto(%x, %y)
	add $t5, $zero, %x
	add $t6, $zero, %y
	subi $t5, $t5, 1
	subi $t6, $t6, 1
	li $s3, 0 #contador y
	li $s2, 0 #Contador de vivas
	buclePequenoY:
	beq $s3, 3 ,finBuclePequenoY
	li $s4, 0 #contador x
		buclePequenoX:
		beq $s4, 3, finBuclePequenoX
		ValidarPunto($t5, $t6)
		beqz $s5, noContar
		jal generarDireccion
		lw $t8, 0($t7)
		bne $t8, COLOR_ALIVE, noContar
		addi $s2, $s2, 1
		noContar:
		addi $s4, $s4, 1
		addi $t5, $t5, 1
		j buclePequenoX
		finBuclePequenoX:
	addi $t6, $t6, 1
	subi $t5, %x, 1
	addi $s3, $s3, 1
	j buclePequenoY
	finBuclePequenoY:
	
.end_macro

#											#
#   Macro encargado de reproducir un sonido específico en cada iteración del programa	# 
#                Recibe un tono, un instrumento y el volumen del sonido			#
#											#
.macro ReproducirSonido(%ton, %instrumento, %volumen)
	addi $a0, %ton, 0
	li $a1, 400
	li $a3, %volumen
	li $a2, %instrumento
	li $v0, 31
	syscall
.end_macro
