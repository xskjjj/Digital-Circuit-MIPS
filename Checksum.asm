# Jingwen Xiao 260885501
# TODO: ADD OTHER COMMENTS YOU HAVE HERE AT THE TOP OF THIS FILE
# TODO: SEE LABELS FOR PROCEDURES YOU MUST IMPLEMENT AT THE BOTTOM OF THIS FILE
# TODO: NOTICE THE TODO IN THE .DATA SEGMENT
# TODO: RENAME THIS FILE AS PER THE SUBMISSION REQUIREMENTS

# Menu options
# r - read text buffer from file 
# g - generate checksum
# v - validate checksum
# w - write text buffer to file
# c - get most common letter in text buffer
# q - quit

.data
MENU:              .asciiz "Commands (read, generate, validate, write, quit):"
REQUEST_FILENAME:  .asciiz "Enter file name:"
REQUEST_ALGORITHM: .asciiz "Choose checksum algorithm (1- Sum Complement, 2- Odd Parity Byte:"
ERROR:	 	 .asciiz "There was an error.\n"
ALGORITHM_ERROR: .asciiz "Algorithm should 1 or 2"

FILE_NAME: 	.space 256	# maximum file name length, should not be exceeded
ALGORITHM_NUMBER: .word 1 	# maximum length of algorithm number, should not be exceeded

.align 2		# ensure word alignment in memory for text buffer (not important)
TEXT_BUFFER:  	.space 10000
.align 2		# ensure word alignment in memory for other data (probably important)


# TODO: define any other spaces you need
#add the display message for vaildate function
PASS:		.asciiz "Checksum validated"
FAIL:		.asciiz "Checksum not validated"


##############################################################
.text
		move $s1 $0 	# Keep track of the buffer length (starts at zero)
MainLoop:	li $v0 4		# print string
		la $a0 MENU
		syscall
		li $v0 12	# read char into $v0
		syscall
		move $s0 $v0	# store command in $s0			
		jal PrintNewLine

		beq $s0 'r' read
		beq $s0 'g' generate
		beq $s0 'w' write
		beq $s0 'v' validate
		beq $s0 'q' exit
		b MainLoop

read:		jal GetFileName
		li $v0 13	# open file
		la $a0 FILE_NAME 
		li $a1 0		# flags (read)
		li $a2 0		# mode (set to zero)
		syscall
		move $s0 $v0
		bge $s0 0 read2	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		b MainLoop
read2:		li $v0 14	# read file
		move $a0 $s0
		la $a1 TEXT_BUFFER
		li $a2 9999
		syscall
		move $s1 $v0	# save the input buffer length
		bge $s0 0 read3	# negative means error (error or not? should judge $s1?)
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		move $s1 $0	# set buffer length to zero
		la $t0 TEXT_BUFFER
		sb $0 ($t0) 	# null terminate the buffer 
		addi $t0, $t0, 1
		sb $0 ($t0) 	# add extra null termination to accomodate extra checksum character
		b MainLoop
read3:		la $t0 TEXT_BUFFER
		add $t0 $t0 $s1
		sb $0 ($t0) 	# null terminate the buffer that was read
		li $v0 16	# close file
		move $a0 $s0
		syscall
		la $a0 TEXT_BUFFER
		#jal ToUpperCase
print:		la $a0 TEXT_BUFFER
		jal PrintBuffer
		b MainLoop	

write:		jal GetFileName
		li $v0 13	# open file
		la $a0 FILE_NAME 
		li $a1 1		# flags (write)
		li $a2 0		# mode (set to zero)
		syscall
		move $s0 $v0
		bge $s0 0 write2	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		b MainLoop
write2:		li $v0 15	# write file
		move $a0 $s0
		la $a1 TEXT_BUFFER
		move $a2 $s1	# set number of bytes to write
		add $a2, $a2, 1 # add 1 for checksum at end of file
		syscall
		bge $v0 0 write3	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		b MainLoop
		write3:
		li $v0 16	# close file
		move $a0 $s0
		syscall
		b MainLoop

generate:	jal GetAlgorithm
		la $a0 TEXT_BUFFER
		move $a1 $v0 # which algorithm to use
		jal GenerateChecksum
		move $a0, $v0 # prints checksum character
		li $v0, 11
    		syscall
    		jal PrintNewLine
		la $a0 TEXT_BUFFER
		b MainLoop
		
validate: 	jal GetAlgorithm
		la $a0 TEXT_BUFFER
		move $a1 $v0	# which algorithm to use
		jal ValidateChecksum
		la $a0 TEXT_BUFFER
		b MainLoop

		
exit:		li $v0 10 	# exit
		syscall

###########################################################
PrintBuffer:	li $v0 4          # print contents of a0
		syscall
		li $v0 11	# print newline character
		li $a0 '\n'
		syscall
		jr $ra

###########################################################
PrintNewLine:	li $v0 11	# print char
		li $a0 '\n'
		syscall
		jr $ra

###########################################################
PrintSpace:	li $v0 11	# print char
		li $a0 ' '
		syscall
		jr $ra

#######################################################
GetFileName:	addi $sp $sp -4
		sw $ra ($sp)
		li $v0 4		# print string
		la $a0 REQUEST_FILENAME
		syscall
		li $v0 8		# read string
		la $a0 FILE_NAME  # up to 256 characters into this memory
		li $a1 256
		syscall
		la $a0 FILE_NAME 
		jal TrimNewline
		lw $ra ($sp)
		addi $sp $sp 4
		jr $ra

###########################################################
GetAlgorithm:	addi $sp $sp -4
		sw $ra ($sp)
		li $v0 4		# print string
		la $a0 REQUEST_ALGORITHM
		syscall
		li $v0 5		# read integer
		la $a0 ALGORITHM_NUMBER  # only 1 integer into this memory
		li $a1 1
		syscall
		la $a0 ALGORITHM_NUMBER
		jal TrimNewline 	#(really need this?)
		la $a0 ALGORITHM_NUMBER
		lw $ra ($sp)
		addi $sp $sp 4
		jr $ra

###########################################################
# Given a null terminated text string pointer in $a0, if it contains a newline
# then the buffer will instead be terminated at the first newline
TrimNewline:	lb $t0 ($a0)
		beq $t0 '\n' TNLExit
		beq $t0 $0 TNLExit	# also exit if find null termination
		addi $a0 $a0 1
		b TrimNewline
		
TNLExit:	sb $0 ($a0)
		jr $ra

###################################################
# END OF PROVIDED CODE... 
# TODO: use this space below to implement required procedures
###################################################

##################################################
# null terminated buffer is in $a0
# algorithm number is in $a1 (1 = complement, 2 = odd parity)
GenerateChecksum:	# TODO: Implement this function!
	addi $sp,$sp,-12
	sw $ra,($sp)	#store return address
	sw $a0,4($sp)	#store $a0(buffer pointer)
	sw $s1,8($sp)  # save the input buffer length, as the code provided at the above, s1 has the buffer length
	li $t0,1
	li $t1,2
	beq $a1,$t0,GenerateComplementChecksum
	beq $a1,$t1,GenerateParityChecksum
	li $v0 4		# print string
	la $a0 ALGORITHM_ERROR
	syscall
GenerateChecksumExit:
	lw $ra,($sp)
	addi $sp,$sp,12
	jr $ra
GenerateComplementChecksum:
	move $a1,$s1 #load the input length to a1
	jal CalcComplementChecksum
	lw $a0,4($sp)
	lw $s1,8($sp)
	add $a0,$a0,$a1
	sb $v0,($a0)
	j GenerateChecksumExit
GenerateParityChecksum:
	move $a1,$s1  #load the input length to a1
	jal CalcParityChecksum
	lw $a0,4($sp)
	lw $s1,8($sp)
	add $a0,$a0,$a1
	sb $v0,($a0)
	j GenerateChecksumExit
	
	
	
CalcComplementChecksum:
	# claculate compelemnt checksum
	# data start from $a0 and length is $a1
	# return at $v0
	move $t0,$a0	#pointer to current processing data
	move $t1,$0	#sum value
	add $t2,$t0,$a1	#pointer to the end of buffer
	ble $a1,$0,ComplementChecksumLoopExit #less or 0 to the length, don't enter the loop
ComplementChecksumLoop:
	lbu $t3,($t0)
	addi $t0,$t0,1 #increment pointer
	addu $t1,$t1,$t3
	blt $t0,$t2,ComplementChecksumLoop
ComplementChecksumLoopExit:
	not $v0,$t1 #opposite value plus1 get the 2s complement
	addi $v0,$v0,1
	andi $v0,0xff #32bit register, only want 8 bits
	jr $ra


CalcParityChecksum:
	# claculate parity checksum
	# data start from $a0 and length is $a1
	# return at $v0
	move $t0,$a0	#pointer to current processing data
	move $t1,$0	#sum value
	add $t2,$t0,$a1	#pointer to the end of buffer
	ble $a1,$0,ParityChecksumLoopExit
ParityChecksumLoop:
	lbu $t3,($t0)
	addi $t0,$t0,1
	xor $t1,$t1,$t3
	blt $t0,$t2,ParityChecksumLoop
ParityChecksumLoopExit:
	not $v0,$t1 
	andi $v0,0xff  #32bit register, only want 8 bits
	jr $ra


 
##################################################
# null terminated buffer is in $a0
# algorithm number is in $a1 (1 = complement, 2 = parity)
ValidateChecksum: # TODO: Implement this function!
	addi $sp,$sp,-8
	sw $ra,($sp)	#store return address
	sw $s1,4($sp) # save the input buffer length, as the code provided at the above, s1 has the buffer length
	li $t0,1
	li $t1,2
	beq $a1,$t0,ValidateComplementChecksum
	beq $a1,$t1,ValidateParityChecksum
	li $v0 4		# print string
	la $a0 ALGORITHM_ERROR
	syscall
ValidateChecksumExit:
	lw $ra,($sp)
	lw $s1,4($sp)
	addi $sp,$sp,8
	jr $ra
ValidateComplementChecksum:
	move $a1,$s1 #load the input length to a1
	addi $a1,$a1,1
	jal CalcComplementChecksum
	beq $v0,$0,ValidateChecksumPass
	j ValidateChecksumFail
ValidateParityChecksum:
	move $a1,$s1 #load the input length to a1
	addi $a1,$a1,1
	jal CalcParityChecksum
	beq $v0,$0,ValidateChecksumPass
	j ValidateChecksumFail
ValidateChecksumPass:
	li $v0,4
	la $a0, PASS
	syscall
	jal PrintNewLine
	j ValidateChecksumExit
ValidateChecksumFail:
	li $v0,4
	la $a0, FAIL
	syscall
	jal PrintNewLine
	j ValidateChecksumExit



