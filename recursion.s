.data		
#Invalid Messages
maxInput:				.space 101
invalidInput:			.asciiz "Invalid input"


.text				
.globl main

main:
		li $v0, 8					#System call reads string
		la $a0, maxInput				#The users input is moved to the $a0 reg
		syscall
		li $t0, 32					#Storing the available space (32 bits) into $t3
		li $t1, 0					#Counter (x = 0)					
		li $s0, 0					#
		la $t3, maxInput				#
		li $t4, 0					#
		li $t5, 10					#loaded new line into $t5
		li $t6, 0					#second counter to track number of spaces before actual input

LoopingFunc:
		lb $t7, 0($t3)					#get string input
		beq $t7, $t5, breakFunc				#break if character is a newline char
		beq $t7, $t0, skipSpaces        		#
		bne $s0, $t0, skipSpaces        		#
		beq $t4, $0, skipSpaces         		#
		beq $t7, $0, skipSpaces         		#
		beq $t7, $t5, skipSpaces        		#
	#if input is invalidInput && invalidInput, choose invalidInput 
		
		sub $t3, $t1, $t6								
		addi $t3, $t3, 1				#increment register by 1
		li $t7, 4										
		ble $t3, $t7, notValidFunc     
		
		li $v0, 4
		la $a0,invalidInput
		
		syscall									
		jr $ra	
	
notValidFunc:

		li $v0, 4
		la $a0, invalidInput
		syscall	
		
		li $v0, 10
		syscall
		
skipSpaces:
		beq $t7, $t0, spaceFunc				#branch if current character is a space else proceed
		addi $t4, $t4, 1				

spaceFunc:

		bne $t7, $t0, spaceCounterFunc			#if current character is a space
		bne $t4, $0, spaceCounterFunc			
		addi $t6, $t6, 1
		
spaceCounterFunc:
		move $s0, $t7					#set previous character with current one
		addi $t3, $t3, 1				#incremented the address
		addi $t1, $t1, 1				#incremented i
		j LoopingFunc
		
breakFunc:
		li $t7, 4
		ble $t4, $t7, longInputFunc			#checks if userInput is more than 4
		
		li $v0, 4
		la $a0, invalidInput
		syscall						#print invalidInput if char>4
		li $v0, 10
		syscall
		
longInputFunc: 
		bne $t4, $zero, emptyStringFunc   		#if user input is empty, and
		beq $t7, $t5, emptyStringFunc     		#if user input is a newline
		li $v0, 4
		la $a0, invalidInput
      	syscall
		li $v0, 10
		syscall
		
emptyStringFunc:
	#overwriting registers 
		la $s0, maxInput
		add $s0, $s0, $t6				#got the address of the start of the number
		
		addi $sp, $sp, -4				#allocate space
		sw $ra, 0($sp)						

		addi $sp, $sp, -8
		
		sw $s0, 0($sp)					#set address of start of number
		sw $t4, 4($sp)					#set length of number
		jal conversionFunc

		lw $t3, 0($sp)
		addi $sp, $sp, 4
		
		li $v0, 1									
		move $a0, $t3
		syscall						#display result
		
		lw $ra, 0($sp)					#restore return address
		addi $sp, $sp, 4						
		jr $ra
		
conversionFunc:

		lw $a0, 0($sp)
		lw $a1, 4($sp)
		addi $sp, $sp, 8	
		
		#store parameters of arrays
		addi $sp, $sp, -20							
		sw $ra, 0($sp)								
		sw $s0, 4($sp)					#s0  = used for address of array			
		sw $s1, 8($sp)							
		sw $s2, 12($sp)
		sw $s3, 16($sp)								

#transfer arguments to s-registers
		move $s0, $a0							
		move $s1, $a1		

		#base
		li $t3, 1
		bne $s1, $t3, PassFunc				#if length is equal 1
		lb $t7, 0($s0)					#load the first element of the array
		
		move $a0, $t7					#set character to argument for charToDeci function
		jal charToDeci
		move $t7, $v0					#get result
	
		move $t3, $t7					#put the first element in $t3, before it's put on the stack to be returned

		j conversionExit
		
PassFunc:
		addi $s1, $s1, -1							
	
		move $a0, $s1					#set arguments for exponentFunc
		jal exponentFunc
		move $s3, $v0								
	
		lb $t3, 0($s0)					#loads the first element of the array
		move $a0, $t3
		jal charToDeci
		move $t3, $v0
		mul $s2, $t3, $s3
		addi $s0, $s0, 1				#increment ptr to start of array
	

	#recursion
		addi $sp, $sp, -8
		sw $s0, 0($sp)
		sw $s1, 4($sp)

		jal conversionFunc

		lw $t3, 0($sp)
		addi $sp, $sp, 4
		
		add $t3, $s2, $t3				#conversion result + first number and put the return value in $t3

conversionExit:

		lw $ra, 0($sp)								
		lw $s0, 4($sp)						
		lw $s1, 8($sp)								
		lw $s2, 12($sp)							
		lw $s3, 16($sp)
		addi $sp, $sp, 20							

		addi $sp, $sp, -4
		sw $t3, 0($sp)

		jr $ra
		
exponentFunc:
		addi $sp, $sp, -4				#allocate space
		sw $ra, 0($sp)					#store returning address
		
		li $t3, 0
		bne $a0, $t3, ignoreExponent
		li $v0, 1
		j leaveNumFunc
		
ignoreExponent:

		addi $a0, $a0, -1				#setting argument for recursion call
		jal exponentFunc
		move $t7, $v0
		li $t1,35									
		mul $v0, $t1, $t7				#put multiplication result into $v0

leaveNumFunc:
		lw $ra, 0($sp)					#restore address
		addi $sp, $sp, 4				
		
		jr $ra
		
charToDeci:
		
		li $t1, 65
		li $t0, 90

	#convert uppercase letter to decimal
		blt $a0, $t1, CapitalFunc			#if ascii of char >= 65 and
		bgt $a0, $t0, CapitalFunc			#if char <= 85
		addi $a0, $a0, -55				#subtract 55 to get the decimal equivalent of A-y
		move $v0, $a0									
		jr $ra
		
CapitalFunc:
	#lowercase to decimal
		li $t1, 97												
		li $t0, 121					#least and largest ascii value for lowercase a - y
		blt $a0, $t1, LowercaseFunc			#if value >= 85 and
		bgt $a0, $t0, LowercaseFunc			#if value <= 121
		addi $a0, $a0, -87										
		move $v0, $a0
		jr $ra
		
		
LowercaseFunc:
		li $t1, 48													
		li $t0, 57					#least and largest ascii value for integers 0-9
		blt $a0, $t1, charToIntFunc			#convert if ascii[value] >= 48 and
		bgt $a0, $t0, charToIntFunc			#if ascii[value] <= 57
		addi $a0, $a0, -48				#get the decimal value of ascii number
		move $v0, $a0
		jr $ra	
		
charToIntFunc:
		li $v0, 4
		la $a0, invalidInput
		syscall
		li $v0, 10
		syscall
