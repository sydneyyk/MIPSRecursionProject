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
	
	lb $s0, ($t0) # loads the bit that $t0 is pointing to
	lw $ra, 0($sp)					
	beq $s0, 0, insubstring# check if the bit is null					
	addi $sp, $sp, 4						
	beq $s0, 10, insubstring #checks if the bit is a new line 	
	addi $t0,$t0,1 #move the $t0 to the next element of the array	
	beq $s0, 44, insubstring #check if bit is a comma
	
	

