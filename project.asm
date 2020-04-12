.data
M1: .word 1,2,3,4,5,6
r1: .word 2
c1: .word 3
M2: .word 1,2,3,4,5,6,7,8,9
r2: .word 3
c2: .word 3
C: .word 1:6
V: .word 1:6
.eqv DATA_SIZE 4
newLine: .asciiz "\n \t"
tab: .asciiz "\t"
transposeLine: .asciiz " TRANSPOSE OF SECOND MATRIX \n \t "
multiplyLine: .asciiz " \n RESULT OF MULTIPLICATION \n \t "
printError: .asciiz " FIRST MATRIX COLUMNS DOES NOT EQUAL TO SECOND MATRIX ROWS"
.text
main:
	la $t0, M1
	lw $t1, r1				#yukseklik / sat?r miktar? / x
	lw $t2, c1				#genislik / sütun miktar? / y
	la $t5, M2
	lw $t6, r2
	lw $t7, c2
	
	jal controlFunc
	
	jal matrix_transpose
	
	li $v0, 4				
	la $a0, transposeLine
	syscall
	
	sub $a0, $a0, $a0
	
	jal matrix_print
	
	sub $t3, $t3, $t3
	sub $t4, $t4, $t4
	
	li $v0, 4				
	la $a0, multiplyLine
	syscall
	
	jal matrix_multiply
	
	j end

			#TRANSPOSE        t0(t1 x t2)  =>  a1(t1 x t2)
######################################################################################################
matrix_transpose:
	la $v0,C				#deger
	li $t3,0				#outer index / sat?r index / i / row index
transposeMatricesOuterLoop:
	bge $t3, $t6, transposeMatricesLoopOuterEnd
	li $t4,0				#inner index / sütun index / j / col  index
transposeMatricesInnerLoop:
	bge $t4, $t7, transposeMatricesLoopInnerEnd
	mul $t8, $t2, $t3     			## address geni?lik *  row index ???  
	add $t8, $t8, $t4			# + col index
	mul $t8, $t8, DATA_SIZE			
	add $t8, $t8, $t5			# t5 = address + base address
	lw $t9, ($t8)				
	sub $t8, $t8, $t8			
	mul $t8, $t6, $t4			
	add $t8, $t8, $t3			
	mul $t8, $t8, DATA_SIZE			
	add $t8, $t8, $v0			
	sw $t9, ($t8)			
	addi $t4, $t4, 1			
	b transposeMatricesInnerLoop
transposeMatricesLoopInnerEnd:
	addiu $t3, $t3, 1
	b transposeMatricesOuterLoop
transposeMatricesLoopOuterEnd:
	move $a0, $t6
	move $t6, $t7
	move $t7, $a0
	move $t5, $v0				# ????????????
	sub $t3,$t3,$t3				# outer index / sat?r index / i / row index
	sub $t4,$t4,$t4
	jr $ra
#########################################################################################################
					#PRINT a1 t1 t2 => t5 t6 t7 
#########################################################################################################
matrix_print:
	li $t3,0				#outer index / sat?r index / i / row index
printMatrixOuterLoop:
	bge $t3, $t6, printMatrixLoopOuterEnd
	li $t4,0				#inner index / sütun index / j / col  index
printMatrixInnerLoop:
	bge $t4, $t7, printMatrixLoopInnerEnd
	mul $t8, $t7, $t3     			# #address geni?lik *  row index ??? 
	add $t8, $t8, $t4			# + col index
	mul $t8, $t8, DATA_SIZE			
	add $t8, $t8, $t5			# t5 = address + base address
	lw $t9, ($t8)
					
	li $v0, 1				# print the number
	move $a0, $t9				
	syscall
	
	li $v0, 4				
	la $a0, tab
	syscall
	
	addi $t4, $t4, 1
	b printMatrixInnerLoop
printMatrixLoopInnerEnd:
	addiu $t3, $t3, 1
	li $v0, 4				#print new line
	la $a0, newLine
	syscall
	b printMatrixOuterLoop
printMatrixLoopOuterEnd:
	sub $t3,$t3,$t3				# outer index / sat?r index / i / row index
	sub $t4,$t4,$t4
	jr $ra
#########################################################################################################################
	#MULTIPLE t0 t1 t2 * t5 t6 t7 = s0 s1 s2 (t3,t4,s7 = row index,col index, multiply index) free = t1,t6
#########################################################################################################################
matrix_multiply:
	la $s0, V					# deger
	add $s1, $zero, $t1				# new row / yukseklik
	add $s2, $zero, $t6				# new column / genislik
	sub $t1, $t1, $t1
	sub $t6, $t6, $t6
	li $t3, 0					# outer index / sat?r index / i / row index 
multiplyMatricesOuterLoop:
	bge $t3, $s1, multiplyMatricesLoopOuterEnd 	# 2. matrisin transpozunun rowu
	li $t4, 0					# inner index / sütun index / j / col  index
multiplyMatricesInnerLoop:
	bge $t4, $s2, multiplyMatricesLoopInnerEnd 
	li $s7, 0
multiplyMatricesMultiplyLoop:
	bge $s7, $t2, multiplyMatricesMultiplyLoopEnd 	# s7 = t2 ya da t7 olana kadar loop
	mul $t8, $s2, $t3				# #t3-s7 geni?lik *  row index ???
	add $t8, $t8, $s7				# + col index
	mul $t8, $t8, DATA_SIZE				# t5 = address + base address
	add $t8, $t8, $t0	
	lw $v0, ($t8)
	sub $t8, $t8, $t8
	mul $t8, $s2, $t4				# t4-s7
	add $t8, $t8, $s7
	mul $t8, $t8, DATA_SIZE
	add $t8, $t8, $t5
	lw $v1, ($t8) 
	sub $t8, $t8, $t8
	mul $t8, $v0, $v1				# carpim + toplam
	add $t1, $t1, $t8
	sub $t8, $t8, $t8
	addi $s7, $s7, 1				# multply index increase
	b multiplyMatricesMultiplyLoop
multiplyMatricesMultiplyLoopEnd:
	li $v0, 1					# print the number
	move $a0, $t1
	syscall	
	
	li $v0, 4				#print new line
	la $a0, tab
	syscall
	
	sub $t8, $t8, $t8
	mul $t8, $s2, $t3				# kayit = t3-t4
	add $t8, $t8, $t4
	mul $t8, $t8, DATA_SIZE
	add $t8, $t8, $s0
	sw $t1, ($t8)
	sub $t1, $t1, $t1
	sub $t8, $t8, $t8
	addiu $t4, $t4, 1
	b multiplyMatricesInnerLoop
multiplyMatricesLoopInnerEnd:
	addiu $t3, $t3, 1
	li $v0, 4					# print new line
	la $a0, newLine
	syscall
	b multiplyMatricesOuterLoop
multiplyMatricesLoopOuterEnd:
	jr $ra
	
controlFunc:
	bne $t2 ,$t6, errorMessage
	jr $ra
errorMessage:
	li $v0, 4				
	la $a0, printError
	syscall
end:
