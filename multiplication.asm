
# @author: Xinqian Li 

# This program uses the optimized version to implement multiplication. To start, we find out if the LSB of multiplier is 1 or 0.
# When the LSB is 0, no addition is performed, and we shift the product right 1 bit.
# When the LSB is 1, we add the multiplicand to the left half of the product. To do this, we need to shift the multiplicand 
# left 16 bits first, and then we can add it to the product register. Once again, we need to shift the product right 1 bit.
# The above steps are repeated 16 times since we assume we have two 16-bit integers as input.
# One problem that we encouter is the overflow issue. The product register should really be 33 bits to hold the carry out
# of the adder, and that's why we might lose the leading bit 1 from the bit shifting. In order to solve this problem,
# we need to make sure that in the last iteration, if the leading bit is 1, we will have to add it back into the final product. 

# main
# ask for input
# call opt_multiply()
# print out the result
# terminate program

# Subroutine
# opt_multiply()
# 
#   unsigned int multiplier = 8881;		$s1 = multiplier
#   unsigned int multiplicand = 4138;		$s0 = multiplicand
#
#   unsigned int low = multiplier;
#   unsigned int up = 0;
#   int i = 0;
#
#   for (i = 0; i<16; i++){			label: loop, $s4 = i
#       if ((low&1) == 1)			label: LSBisONE, $t0 = low & 1
#       {
#           up = multiplicand << 16;		$s3 = upper register
#           low += up;				$s2 = lower register
#       }
#       low >>= 1;
#
#	if (i==15)				label: IFLast
#	{
#	    if ((multiplicand>>15)==1)		$t1 = multiplicand >> 15
#	    {
#		low || 0x80000000		$s2 = $s2 || 0x80000000
#	    }
#	}
#    }
#

.data	# Data declaration section
	multiplicand:	.asciiz "Multiplicand? "
	multiplier: 	.asciiz "Multiplier? "
	product: 	.asciiz "Product: "
	
.text

main:	# Assembly language instructions go in text segment
	li $v0, 4		# ask for multiplicand
	la $a0, multiplicand	# load address of string to be printed into $a0
	syscall			# call operating system to perform operation
	
	li $v0, 5		# get the user's number
	syscall
	
	move $s0, $v0		# move result to $s0

	li $v0, 4		# ask for multiplier
	la $a0, multiplier	
	syscall	
	
	li $v0, 5		
	syscall
	
	move $a1, $v0		# move multiplier to second argument
	move $a0, $s0		# move multiplicand to first argument
	
	jal opt_multiply	# call subroutine
	
	move $s0, $v0		# save return value
	
	li $v0, 4
	la $a0, product
	syscall 
	
	li $v0, 36  		# print unsigned int
	move $a0, $s0
	syscall 
	
	li $v0, 10		# terminate program
	syscall
	
					
# Start of subroutine
opt_multiply:			# opt_multiply(multiplicand, multiplier)
	add $s0, $a0, $zero	# $s0 = multiplicand
	add $s1, $a1, $zero	# $s1 = multiplier
	add $s2, $s1, $zero	# $s2 = lower register
	add $s3, $zero, $zero	# $s3 = 0 = upper register
	add $s4, $zero, $zero	# $s4 = 0 = i
	addi $s5, $zero, 15	# loop limit

loop:	
	bgt $s4, $s5, exit	# start while loop (i<16)
	andi $t0, $s2, 1	# $t0 = low & 1
	beq $t0, 1, LSBisONE	# when $t0 = 1 jump
	srl $s2, $s2, 1		# lower >> 1
	addi $s4, $s4, 1	# i++

	j loop

LSBisONE: 
	sll $s3, $s0, 16	# upper = multiplicand << 16
	addu $s2, $s2, $s3	# lower += upper;
	
	add $t5, $s3, $zero	# make a copy of $s3
	srl $t5, $t5, 16	# shift t5 >> 16
	srl $s2, $s2, 1		# lower >> 1
	blt $t5, 32768, NoOverflow
	ori $s2, $s2, 0x80000000
NoOverflow:
	
		
	
	beq $s4, 15, IFLast	# if this is the last iteration, check MSB
	addi $s4, $s4, 1	# i++
	
	j loop

IFLast:
	srl $t1, $s0, 15	# $t1 = multiplicand >> 15
	beq $t1, 1, OR		# is MSB is one, need to keep it
	
	j loop
	
OR:
	ori $s2, $s2, 0x80000000 # make the MSB into 1

exit:	add $v0, $s2, $zero	# set return value to the product
	jr $ra
# end of subroutine
