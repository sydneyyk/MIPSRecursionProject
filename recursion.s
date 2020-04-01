# Howard ID = 02878236
# N = 26 + (02878236 % 11)
# N = 35 
# Base 35
# M = N - 10
# M = 35 - 10
# M = 25 (The range is through the 25th letter of the alphabet, Y)

.data
maxSize:	.space 101
invalidInput:	.asciiz "Invalid input"

.text
.global main

main:
	li $v0, 8				#System call reads string
	la $a0, maxSize				#The users input is moved to the $a0 reg
	syscall
	
	li $t0, 32				#Storing the available space (32 bits) into $t3
	li $t1, 0 				#Counter (x = 0)
	li $s0, 0				#Keeps track of of the previous character being passed in
	la $t3, maxSize				#Loading the input from user into address of register
	li $t4, 0				#Number of characters equals zero
	li $t5, 10				#Puts new line character into $t5 reg
	li $t6, 0				#This counter keeps track of the number of empty spaces before characters in string.
	
LoopingFunc:
	lb $t7, 0($t3)				#Retrieves user input
	beq $t7, $t5, breakFunc			#Branches to break function if there is newline
	beq $t7, $t0, skipSpaces		#Current character is a space
	bne $s0, $t0, skipSpaces		#Previous character is a space
	beq $t4, $0, skipSpaces			#There are still characters left(prev num of characters != 0)
	beq $t7, $0, skipSpaces			#Character is empty space
	beq $t7, $t5, skipSpaces		#Character is newline
	
	sub $t3, $t1, $t6			#Subtracts the counter from address of the the pointer
	addi $t3, $t3, 1			#Adds one to current register
	li $t7, 4				#Loads the characters that are valid from the input
	ble $t3, $t7, notValidFunc		#The input is within range but is still not valid
	
	li $v0, 4				#System call prints 
	la $a0, invalidInput			#Loads the prompt message
	syscall
	jr $ra
	
notValidFunc:
	li $v0, 4				#System call prints
	la $a0, invalidInput			#Loads the prompt message
	syscall	
		
	li $v0, 10
	syscall
	
skipSpaces:
	beq $t7, $t0, spaceFunc			#Branch condition if the character is a space
	addi $t4, $t4, 1			#Add 1 to the address of the register
	
spaceFunc:
	bne $t7, $t0, spaceCounterFunc		#If current chacter is a space then move to the space fucntion	
	bne $t4, $0, spaceCounterFunc		#If current character a new line the same as above
	addi $t6, $t6, 1
	
spaceCounterFunc:
	move $s0, $t7				#Sets the previous chracter with the first one
	addi $t3, $t3, 1			#Increments the address of register $t3
	addi $t1, $t1, 1			#Increments the counter	
	
breakFunc:
	li $t7, 4
	ble $t4, $t7, longInputFunc		#Checks to see if the user input is more than 4 bytes	
		
	li $v0, 4
	la $a0, invalidInput			#Prints the invalid prompt if the the characters are more than 4 bytes
	syscall					
	li $v0, 10
	syscall
	
longInputFunc: 
	bne $t4, $zero, emptyStringFunc   	#Branch conditition to go to an empty line if user input is empty	
	beq $t7, $t5, emptyStringFunc     	#Branch comparison condition to check if user input is new line character
	li $v0, 4
	la $a0, invalidInput
      	syscall
	li $v0, 10
	syscall
	
emptyStringFunc: 
	la $s0, maxInput			#Loads the users input into the reg to read
	add $s0, $s0, $t6			#Gets the address of the start of the number
	
	addi $sp, $sp, -4			#Allocates space for the value to go in register
	sw $ra, 0($sp)						

	addi $sp, $sp, -8
	
	sw $s0, 0($sp)				#Sets address of start of the iinputed number
	sw $t4, 4($sp)				#Sets length of number
	jal conversionFunc

	lw $t3, 0($sp)
	addi $sp, $sp, 4
	
	li $v0, 1									
	move $a0, $t3
	syscall	
	
	lw $ra, 0($sp)									
	addi $sp, $sp, 4						
	jr $ra
	
conversionFunc:

	lw $a0, 0($sp)
	lw $a1, 4($sp)
	addi $sp, $sp, 8
	
	addi $sp, $sp, -20							
	sw $ra, 0($sp)								
	sw $s0, 4($sp)				#$s0 stores the addresss of the string		
	sw $s1, 8($sp)							
	sw $s2, 12($sp)
	sw $s3, 16($sp)	
	
	move $s0, $a0							
	move $s1, $a1

	li $t3, 1
	bne $s1, $t3, PassFunc			#If the length of the string is 1
	lb $t7, 0($s0)				#Loads the first element of the string into the reg
	
	move $a0, $t7				#Sets character to argument for charToDeci function
	jal charToDeci
	move $t7, $v0				#Gets result of the conversion
	move $t3, $t7				#Put the first element in $t3 before it's in stack for the return

	j conversionExit
	
PassFunc:
	addi $s1, $s1, -1							
	
	move $a0, $s1					#Sets arguments for exponentFunc
	jal exponentFunc
	move $s3, $v0	
	
	lb $t3, 0($s0)					#Loads the first element of the string
	move $a0, $t3
	jal charToDeci
	move $t3, $v0
	mul $s2, $t3, $s3
	addi $s0, $s0, 1				#Increments counter to start of string
	
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $s1, 4($sp)

	jal conversionFunc

	lw $t3, 0($sp)
	addi $sp, $sp, 4	
	add $t3, $s2, $t3
	
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
		addi $a0, $a0, -55						#subtract 55 to get the decimal equivalent of A-y
		move $v0, $a0									
		jr $ra
		
CapitalFunc:
	#lowercase to decimal
		li $t1, 97												
		li $t0, 121							#least and largest ascii value for lowercase a - y
		blt $a0, $t1, LowercaseFunc		#if value >= 85 and
		bgt $a0, $t0, LowercaseFunc		#if value <= 121
		addi $a0, $a0, -87										
		move $v0, $a0
		jr $ra
		
		
LowercaseFunc:
		li $t1, 48													
		li $t0, 57							#least and largest ascii value for integers 0-9
		blt $a0, $t1, charToIntFunc	#convert if ascii[value] >= 48 and
		bgt $a0, $t0, charToIntFunc	#if ascii[value] <= 57
		addi $a0, $a0, -48						#get the decimal value of ascii number
		move $v0, $a0
		jr $ra	
		
charToIntFunc:
		li $v0, 4
		la $a0, invalidInput
		syscall
		li $v0, 10
		syscall
