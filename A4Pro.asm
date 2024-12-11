# Jingwen Xiao 260885501
# TODO: ADD OTHER COMMENTS YOU HAVE HERE AT THE TOP OF THIS FILE
# TODO: SEE LABELS FOR PROCEDURES YOU MUST IMPLEMENT AT THE BOTTOM OF THIS FILE

.data
TestNumber:	.word 0		# TODO: Which test to run!
				# 0 compare matrices stored in files Afname and Bfname
				# 1 test Proc using files A through D named below
				# 2 compare MADD1 and MADD2 with random matrices of size Size
				
Proc:		MADD1		# Procedure used by test 1, set to MADD1 or MADD2		
				
Size:		.word 64	# matrix size (MUST match size of matrix loaded for test 0 and 1)

Afname: 		.asciiz "A64.bin"  # 64 = 2^6   64x64x4 = 2^(6+6+2) = 2^14 = 8K?
Bfname: 		.asciiz "B64.bin"
Cfname:		.asciiz "C64.bin"
Dfname:	 	.asciiz "D64.bin"

#################################################################
# Main function for testing assignment objectives.
# Modify this function as needed to complete your assignment.
# Note that the TA will ultimately use a different testing program.
.text
main:	la $t0 TestNumber
		lw $t0 ($t0)
		beq $t0 0 compareMatrix
		beq $t0 1 testFromFile
		beq $t0 2 compareMADD
		li $v0 10 # exit if the test number is out of range
		syscall	

compareMatrix:	
		la $s7 Size	
		lw $s7 ($s7)		# Let $s7 be the matrix size n

		move $a0 $s7
		jal mallocMatrix	# allocate heap memory and load matrix A
		move $s0 $v0		# $s0 is a pointer to matrix A
		la $a0 Afname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s0
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix	# allocate heap memory and load matrix B
		move $s1 $v0		# $s1 is a pointer to matrix B
		la $a0 Bfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s1
		jal loadMatrix
	
		move $a0 $s0
		move $a1 $s1
		move $a2 $s7
		jal check
		
		li $v0 10      		# load exit call code 10 into $v0
		syscall         	# call operating system to exit	

testFromFile:	
		la $s7 Size	
		lw $s7 ($s7)		# Let $s7 be the matrix size n

		move $a0 $s7
		jal mallocMatrix	# allocate heap memory and load matrix A
		move $s0 $v0		# $s0 is a pointer to matrix A
		la $a0 Afname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s0
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix	# allocate heap memory and load matrix B
		move $s1 $v0		# $s1 is a pointer to matrix B
		la $a0 Bfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s1
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix	# allocate heap memory and load matrix C
		move $s2 $v0		# $s2 is a pointer to matrix C
		la $a0 Cfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s2
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix	# allocate heap memory and load matrix A
		move $s3 $v0		# $s3 is a pointer to matrix D
		la $a0 Dfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s3
		jal loadMatrix		# D is the answer, i.e., D = AB+C 
	
		# TODO: add your testing code here
		move $a0, $s0		# A
		move $a1, $s1		# B
		move $a2, $s2		# C
		move $a3, $s7		# n
		
		la $ra ReturnHere
		la $t0 Proc			# function pointer
		lw $t0 ($t0)	
		jr $t0				# like a jal to MADD1 or MADD2 depending on Proc definition

ReturnHere:	
		move $a0 $s2		# C
		move $a1 $s3		# D
		move $a2 $s7		# n
		jal check			# check the answer

		li $v0, 10      	# load exit call code 10 into $v0
		syscall         	# call operating system to exit	

compareMADD:	
		la $s7 Size
		lw $s7 ($s7)	# n is loaded from Size
		mul $s4 $s7 $s7	# n^2
		sll $s5 $s4 2	# n^2 * 4

		move $a0 $s5
		li   $v0 9	# malloc A
		syscall	
		move $s0 $v0
		move $a0 $s5	# malloc B
		li   $v0 9
		syscall
		move $s1 $v0
		move $a0 $s5	# malloc C1
		li   $v0 9
		syscall
		move $s2 $v0
		move $a0 $s5	# malloc C2
		li   $v0 9
		syscall
		move $s3 $v0	
	
		move $a0 $s0	# A
		move $a1 $s4	# n^2
		jal  fillRandom	# fill A with random floats
		move $a0 $s1	# B
		move $a1 $s4	# n^2
		jal  fillRandom	# fill A with random floats
		move $a0 $s2	# C1
		move $a1 $s4	# n^2
		jal  fillZero	# fill A with random floats
		move $a0 $s3	# C2
		move $a1 $s4	# n^2
		jal  fillZero	# fill A with random floats

		move $a0 $s0	# A
		move $a1 $s1	# B
		move $a2 $s2	# C1	# note that we assume C1 to contain zeros !
		move $a3 $s7	# n
		jal MADD1

		move $a0 $s0	# A
		move $a1 $s1	# B
		move $a2 $s3	# C2	# note that we assume C2 to contain zeros !
		move $a3 $s7	# n
		jal MADD2

		move $a0 $s2	# C1
		move $a1 $s3	# C2
		move $a2 $s7	# n
		jal check	# check that they match
	
		li $v0 10      	# load exit call code 10 into $v0
		syscall         	# call operating system to exit	

###############################################################
# mallocMatrix( int N )
# Allocates memory for an N by N matrix of floats
# The pointer to the memory is returned in $v0	
mallocMatrix: 	
		mul  $a0, $a0, $a0		# Let $s5 be n squared
		sll  $a0, $a0, 2		# Let $s4 be 4 n^2 bytes
		li   $v0, 9		
		syscall					# malloc A
		jr $ra
	
###############################################################
# loadMatrix( char* filename, int width, int height, float* buffer )
.data
errorMessage: .asciiz "FILE NOT FOUND" 
.text
loadMatrix:	
		mul $t0 $a1 $a2 	# words to read (width x height) in a2
		sll $t0 $t0  2	  	# multiply by 4 to get bytes to read
		li $a1  0     		# flags (0: read, 1: write)
		li $a2  0     		# mode (unused)
		li $v0  13    		# open file, $a0 is null-terminated string of file name
		syscall
		slti $t1 $v0 0
		beq $t1 $0 fileFound
		la $a0 errorMessage
		li $v0 4
		syscall		  		# print error message
		li $v0 10         	# and then exit
		syscall		
fileFound:	
		move $a0 $v0     	# file descriptor (negative if error) as argument for read
  		move $a1 $a3     	# address of buffer in which to write
		move $a2 $t0	  	# number of bytes to read
		li  $v0 14       	# system call for read from file
		syscall           	# read from file
		# $v0 contains number of characters read (0 if end-of-file, negative if error).
		# We'll assume that we do not need to be checking for errors!
		# Note, the bitmap display doesn't update properly on load, 
		# so let's go touch each memory address to refresh it!
		move $t0 $a3		# start address
		add $t1 $a3 $a2  	# end address
loadloop:	
		lw $t2 ($t0)
		sw $t2 ($t0)
		addi $t0 $t0 4
		bne $t0 $t1 loadloop		
		li $v0 16			# close file ($a0 should still be the file descriptor)
		syscall
		jr $ra	

##########################################################
# Fills the matrix $a0, which has $a1 entries, with random numbers
fillRandom:	
		li $v0 43
		syscall				# random float, and assume $a0 unmodified!!
		swc1 $f0 0($a0)
		addi $a0 $a0 4
		addi $a1 $a1 -1
		bne  $a1 $zero fillRandom
		jr $ra

##########################################################
# Fills the matrix $a0 , which has $a1 entries, with zero
fillZero:	
		sw $zero 0($a0)		# $zero is zero single precision float
		addi $a0 $a0 4
		addi $a1 $a1 -1
		bne  $a1 $zero fillZero
		jr $ra



######################################################
# TODO: void subtract( float* A, float* B, float* C, int N )  C = A - B 
subtract: 	
		#a0 store ADDRESS, which is NOT FLOAT
		#load element from that ADDRESS
		#do subtract
		#load result back to that ADDRESS
		#increment the ADDRESS by 4
		addi $sp $sp -4
		sw $ra 0($sp)	
		mul $t0 $a3 $a3 #n^2
		li $t1 0 # iniatilize counter as 0
		
		move $t2 $a0 # store the address to temp register
		move $t3 $a1
		move $t4 $a2  
		
loop:
		beq $t1 $t0 end # if t1 equals n^2 loop ends 
		lwc1 $f6 ($t2)
		lwc1 $f8 ($t3) 
		lwc1 $f10 ($t4)
		sub.s $f10 $f6 $f8#store the result of a-b to c
		swc1 $f10 ($t4)
		
		addi $t2 $t2 4# move the pointer to the next element
		addi $t3 $t3 4
		addi $t4 $t4 4
		
		addi $t1 $t1 1 # increment counter by 1
		j loop
end:
		lw $ra 0($sp)
		addi $sp $sp 4
		jr $ra


#################################################
# TODO: float frobeneousNorm( float* A, int N )
frobeneousNorm: 	
				addi $sp $sp -4
				sw $ra 0($sp) 
				
				
				mtc1 $zero, $f16 		# inialize f16 with 0 as the sum
				li $t5 0 				# counter
				mul $t6 $a1 $a1 		# n^2
				move $t7 $a0 			# load a0 address to temp register
				
				
squareloop:
				beq $t5 $t6 end1
				
				lwc1 $f18 0($t7) 		#load the float value from address a0
				mul.s $f18 $f18 $f18	# squre each element
				add.s $f16 $f16 $f18	# add each elements to get the sum
				 
				addi $t7 $t7 4 			# increment the pointer
				addi $t5 $t5 1 			# increment coutner by 1
				j squareloop
end1:
				
				sqrt.s $f0 $f16 		# get the root of the sum
				
				lw $ra 0($sp)
				addi $sp $sp 4
				jr $ra

#################################################
# TODO: void check ( float* C, float* D, int N )
# Print the forbeneous norm of the difference of C and D
check: 
		addi $sp $sp -4
		sw $ra 0($sp) 
		move $a3 $a2
		move $a2 $a0		# load a's content to the third matrix
	
		jal subtract 		# do the substraction
		
		move $a1 $a3 		# load the n to the second input
		jal frobeneousNorm 	# do the Norm calculation
		mov.s $f12 $f0
		li $v0 2
		syscall  			# print the result	
		lw $ra 0($sp)
		addi $sp $sp 4		
		jr $ra

##############################################################
# TODO: void MADD1( float*A, float* B, float* C, N )

MADD1:
		addi $sp $sp -24 
		sw $ra 0($sp) 
		sw $s0 4($sp)
		sw $s1 8($sp)
		sw $s2 12($sp)
		sw $s3 16($sp)
		sw $s4 20($sp)		

		move $t6 $a3 #n
		
		li $t7 0 # initialize i as 0
		
		move $t0 $a0 #load address of a into temp register
		move $t1 $a1
		move $t2 $a2
		outerloop:
			bge $t7 $t6 outerEnd #if i euquals n, outerloop ends
			li $t8 0 # initialize j as 0
			
		middleloop:
			bge $t8 $t6 middleEnd #if j euquals n, outerloop ends
			li $t9 0 # initialize k as 0
			#add $t5 $0 $a3 #n
			
		innerloop:
			bge $t9 $t6 innerEnd 		#if k euquals n, outerloop ends 
			
			li $s4 4
			# The address of A(i,j) is A + i �� n + j,
			mul $t3 $t7 $a3 			# ixn
			mul $t3 $s4 $t3  			# 4x ix n
			
			mul $s0 $t8 $s4 			# 4j
			add $s3 $t3 $s0 			# 4x i x n +4j C
			
			mul $s1 $t9 $s4				# 4k
			add $t4 $t3 $s1 			# 4x i x n +4k A
			
			mul $t5 $t9 $a3 			# k x n
			mul $t5 $t5 $s4 			# 4 xk xn
			add $s2 $t5 $s0 			# 4x k x n +4j    B
			
			add $t0 $a0 $t4
			add $t1 $a1 $s2
			add $t2 $a2 $s3
			
			lwc1 $f4 ($t0) 				#load value of a at the first address
			lwc1 $f6 ($t1)
			lwc1 $f8 ($t2)
			mul.s $f10 $f4 $f6  		# a0 times a1 and store the results in a2
			add.s $f8 $f8 $f10
			swc1 $f8 ($t2)
			
			addi $t9 $t9 1 				# k++
			j innerloop
		innerEnd:
			addi $t8 $t8 1 				# j++
			j middleloop
		middleEnd:
			addi $t7 $t7 1 				# i++
			j outerloop
		outerEnd:	
		lw $ra 0($sp)
		lw $s0 4($sp)
		lw $s1 8($sp)
		lw $s2 12($sp)
		lw $s3 16($sp)
		lw $s4 20($sp)		
		addi $sp $sp 24
		jr $ra

#########################################################
# TODO: void MADD2( float*A, float* B, float* C, N )
MADD2: 	
		addi $sp $sp -12
		sw $s0 0($sp)
		sw $s1 4($sp)
		sw $s2 8($sp)
		move $t0,$0				# jj = 0
madd2_loop1:
		move $t1,$0				# kk = 0
madd2_loop2:
		move $t2,$0 			# i = 0
madd2_loop3:
		move $t3,$t0			# j = jj
madd2_loop4:
		mtc1 $0,$f3				# sum = 0
		move $t4,$t1			# k = kk
		move $t5,$a3
		sll $t5,$t5,2
		mul $t5,$t5,$t2
		move $s2,$t3 
		sll $s2,$s2,2
		add $s2,$s2,$t5
		move $s0,$t1
		sll $s0,$s0,2
		add $s0,$s0,$t5
		move $t5,$a3
		sll $t5,$t5,2
		mul $t5,$t5,$t1
		move $s1,$t3 
		sll $s1,$s1,2
		add $s1,$s1,$t5
		add $s0,$s0,$a0
		add $s1,$s1,$a1
		add $s2,$s2,$a2
madd2_loop5:
		lwc1 $f0,($s0) 
		lwc1 $f1,($s1)
		mul.s $f0,$f0,$f1 
		add.s $f3,$f3,$f0			# sum += a[i][k] * b[k][j];
		
		addi $t4,$t4,1 				# k++
		addi $s0,$s0,4
		move $t5,$a3
		sll $t5,$t5,2
		add $s1,$s1,$t5
		
		move $t5,$t1
		addi $t5,$t5,4				# kk+bsize
		slt $t6,$t4,$t5 
		slt $t7,$t4,$a3
		add $t6,$t6,$t7
		bge $t6,2,madd2_loop5	# loop for k
		
		lwc1 $f2,($s2)
		add.s $f3,$f3,$f2 
		swc1 $f3,($s2)			#c[i][j] += sum;

		addi $t3,$t3,1				# j++
		move $t4,$t0 
		addi $t4,$t4,4				# jj+bsize
		slt $t5,$t3,$t4
		slt $t6,$t3,$a3 
		add $t5,$t5,$t6 
		bge $t5,2,madd2_loop4	# loop for j
		

		addi $t2,$t2,1			# i++
		sll $t3,$a3,2
		blt $t2,$a3,madd2_loop3	# loop for i
		
		
		addi $t1,$t1,4			# kk += bsize
		blt $t1,$a3,madd2_loop2	# loop for kk
		
		addi $t0,$t0,4			# jj += bsize
		blt $t0,$a3,madd2_loop1	# loop for jj
		
		lw $s0 0($sp)
		lw $s1 4($sp)
		lw $s2 8($sp)	
		addi $sp $sp 12	

		jr   $ra                # Return




