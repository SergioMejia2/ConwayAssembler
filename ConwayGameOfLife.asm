.include "macrosGameOfLife.asm"

	.data	
bienvenida:	.asciiz "Bienvenido, presione una tecla para continuar..."
pregunta:	.asciiz "Presione ‘i’ para iniciar o ‘s’ para salir: "
volverAJugar:	.asciiz "Desea volver a jugar? Presione ‘s’ para sí y ‘n’ para no: "
direccionArchivo:	.asciiz "./Conway Game Of Life-music/matriz_inicial.txt"
matrizActual:	.asciiz "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
matrizNueva:	.asciiz "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
it:		.byte 0
	.text
main:
	#DIBUJO ICONO HOJITA
	ImprimirLogo		#Macro para imprimir el logo crado
	la $s0, bienvenida	#Se carga en $s0 la dirección del mensaje de bienvenida
	jal PrintString		#Se llama a la función de impresión de String
	jal LeerCaracter	#Se llama a la función para leer el caracter
	juego:			
	ClearDisplay		#Se pinta todo el tablero de blanco
	jal LeerMatriz		#Se lee la matriz inicial del archivo matriz_inicial.txt y se guarda en matrizActual
	la $s0, matrizActual	#Se carga la dirección de la matriz
	PintarMatriz($s0)	#Se pinta la matriz
	
	vuelveAPreguntar:	#Ciclo que pregunta si el usuario deseea jugar de nuevo.
	la $s0, pregunta	
	jal PrintString
	jal LeerCaracter
	beq $s1, 's', fin		#Si se ingresa s termina la ejecución.
	bne $s1, 'i', vuelveAPreguntar 	#Se pregunta mientras que se ingrese un valor correcto.
	# Se ingresa i, inicia el ciclo del juego.
	bucleJuego:
	li $t1, 0 #Coordenada y
	la $s0, matrizNueva		#Se carga la direccion de la matriz nueva.
	bucleY:				#Inician los ciclos para recorrer la matriz.
	beq $t1, 16, finBucleY		
	li $t0, 0 #Coordenada x
		bucleX:				
		beq $t0, 16, finBucleX
		VerificarPunto($t0, $t1)		#Se llama el macro que recibe las cordenadas x, y para verificar el numero de celulas vivas a su alrededor.
		addi $t5, $t0, 0
		addi $t6, $t1, 0		
		jal generarDireccion		
		lw $t2, 0($t7)			
		bne $t2, COLOR_ALIVE, calcularVida	#Si la celula esta muerta, pasamos a calular vida.
		subi $s2, $s2, 1			#Se resta 1 al numero de celulas vivas (para descartar el punto de referencia).
		calcularVida:
		li $t3, '0' 					#Se asume que la celula esta muerta.
		beq $t2, COLOR_ALIVE, condicionesVida 		#Si la celula esta viva, pasamos a verificar su condicion.
		beq $s2, 3, nace 				
		j nuevaMatriz
		condicionesVida:		#Se establecen las condiciones de vida de una celula.
		beq $s2, 2, nace		#Si el numero de celulas vivas es igual a 2 o 3, nace.
		beq $s2, 3, nace		
		j nuevaMatriz
		nace:					
		li $t3, '1'			#Se cumplieron las condiciones de vida, entonces la celula, pasa a estar viva.
		nuevaMatriz:			
		sb $t3, 0($s0)
		addi $s0, $s0, 1
		#Recibo en $s2 el numero de vivas (contando la actual si esta está viva
		addi $t0, $t0, 1
		j bucleX
		finBucleX:
		addi $t1, $t1, 1	
	j bucleY
	finBucleY:
	
	#CONDICIONES FIN JUEGO						#Verificar si la matriz actual esta vacía o si la matriz actual y la anterior son iguales.
	li $t0, 0				
	la $s1, matrizNueva						#Se carga la direccion de la matriz nueva.
	li $t2, 0							#Se declara una bandera.
	bucleMatrizVacia:						
		beq $t0, 256, finBucleMatrizVacia			#Si el contador es igual a 256, termina
		lb $t1, 0($s1)						#Se carga el bit para la comparación.
		beq $t1, '1', matrizContiene				#Si el bit es igual a 1 significa que la matriz no esta vacía.
		addi $t0, $t0, 1					#Se aumenta el contador.
		addi $s1, $s1, 1					#Se aumenta la posición del bit.
	j bucleMatrizVacia
	matrizContiene:							
	li $t2, 1							#Se cambia el valor de la bandera.
	finBucleMatrizVacia:
	
	
	#la $s0, matrizNueva
	#jal PrintString
	#la $s0, matrizActual
	#jal PrintString
	
	la $s0, matrizNueva					#Se carga la direccion de la matriz nueva.
	la $s1, matrizActual					#Se carga la direccion de la matriz actual.
	li $t0, 0						#Se declara el contador del bucle.
	li $t4, 0						#Se declara una bandera.
	bucleComparacion:			
		beq $t0, 256, finBucleComparacion		#Si el contador es igual a 256, termina.
		lb $t1, 0($s0)					#Se carga el bit de la matriz nueva para la comparación.
		lb $t9, 0($s1)					#Se carga el bit de la matriz actual para la comparación.
		bne $t1, $t9, matricesNoIguales			#Se comparan los bits.
		addi $t0, $t0, 1				#Se aumenta el contador.
		addi $s0, $s0, 1				#Se aumenta la posición de los bits.
		addi $s1, $s1, 1
	j bucleComparacion
	matricesNoIguales:					
	li $t4, 1						#Se cambia el valor de la bandera.
	finBucleComparacion:
	
	la $s0, matrizNueva					#Se carga la direccion de la matriz nueva.
	PintarMatriz($s0)					#Se llama el macro para mostrar la matriz.
	
	la $s0, it		
	li $t1, 67
	lb $t5, 0($s0)
	beqz $t5, rep
	li $t1, 71
	li $t3, 0
	sb $t3, 0($s0)
	j soni
	rep:
	li $t3, 1
	sb $t3, 0($s0)
	soni:
	ReproducirSonido($t1, 10, 100)
	
	beq $t2, 0, finJuego
	beq $t4, 0, finJuego
	
	la $s0, matrizNueva
	la $s1, matrizActual
	li $t0, 0
	bucleCopia:
		beq $t0, 256, finBucleCopia
		lb $t1, 0($s0)
		sb $t1, 0($s1)
		addi $s0, $s0, 1
		addi $s1, $s1, 1
		addi $t0, $t0, 1
	j bucleCopia
	finBucleCopia:
	EsperarTiempo(500)
	j bucleJuego
	finJuego:
	
	la $s0, volverAJugar
	jal PrintString
	jal LeerCaracter
	beq $s1, 's', juego
	bne $s1, 'n', finJuego
j fin

#										#
#                    Funcion que imprime un String				#
#  En $s0 debe estar la direccion de memoria del String a imprimir en  consola	#
#										#
PrintString:
	li $v0, 4
	add $a0, $s0, $zero
	syscall
	add $s1, $ra, $zero	#Es necesario salvar el registro de retorno si se llama otra función luego
	jal PrintNewLine
	jr $s1			#Retorno de la función

#														#
#                              Funcion que imprime un salto de linea						#
#  Se carga en $a0 el \n que al llamar el syscall de imprimir un caracter lo muestra como salto de linea	#
#														#	
PrintNewLine:
	li $v0, 11
	li $a0, '\n'
	syscall
	jr $ra

#					#
#      Funcion que lee un caracter	#
#   El valor termina guardado en $s1	#
#					#	
LeerCaracter:
	li $v0, 12
	syscall
	add $s1, $zero, $v0
	add $s2, $ra, $zero	#Es necesario salvar el registro de retorno si se llama otra función luego
	jal PrintNewLine
	jr $s2			#Retorno de la función

#										#
#   Función que lee la matriz incial de un archivo de texto de unos y ceros	#
# 										#
LeerMatriz:
# Open (for writing) a file that does not exist
  li   $v0, 13       # system call for open file
  la   $a0, direccionArchivo    # output file name
  li   $a1, 0        # Open for writing (flags are 0: read, 1: write)
  li   $a2, 0        # mode is ignored
  syscall            # open a file (file descriptor returned in $v0)
  move $s6, $v0      # save the file descriptor 
# Write to file just opened
  li   $v0, 14       # system call for write to file
  move $a0, $s6      # file descriptor 
  la   $a1, matrizActual   # address of buffer from which to read
  li   $a2, 256      # hardcoded buffer length
  syscall            # write to file
# Close the file 
  li   $v0, 16       # system call for close file
  move $a0, $s6      # file descriptor to close
  syscall            # close file
  jr $ra

#    Función encargada de reescribir las coordenadas (x,y) en direcciones de memoria	#
# Recibe en $t5 y en $t6 coordenadas en (x,y) y las transforma en direccion de memoria	#
#											#
generarDireccion:
	add $s6, $zero, $t6
	mul $s6, $s6, 64
	add $s7, $zero, $t5
	mul $s7, $s7, 4
	add $s6, $s6, $s7
	li $t9, DIR_BASE
	add $t7, $t9, $s6
	jr $ra
	
fin:
Fin
