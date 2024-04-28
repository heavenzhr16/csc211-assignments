# MIPS Procedures
# CSC 211
# Original main (and stubs) and macros written by Jerod Weinman

# Because MARS does not heed the .ent directive to specify the entry point,
# we must put the "main" routine first. Otherwise, we'd include main in the
# .globl symbols below and uncomment the following line:
#.ent main

# Ensure the following procedure labels are globally visible
.globl swap, byteflip, extremes, product

.data                             # Global values stored in memory

ramanujan: .word 1729
simerka:   .word  561

.text                             # Start generating instructions

        
# main
# Run the assignment procedure(s).
# (main is not a special name in MARS, but we label it anyway for familiarity.)
# You may edit anything within main for testing, as it will not be autograded
main:
  # Problem 1 (Swap)
  la   $a0, ramanujan             # Load arguments (addresses) into registers
  la   $a1, simerka      
  jal  swap                       # Call the procedure
  la   $t0, ramanujan             # (Re)load addresses into registers, because
  la   $t1, simerka               # argument registers are not preserved
  lw   $s0, 0($t0)                # Dereference pointers into saved registers
  lw   $s1, 0($t1)

  # Problem 2 
  la  $a0, 0xBA5EBA77
  jal byteflip
  
  # Problem 3 (Extremes)
  li   $a0, 4                     # Load arguments into registers
  li   $a1, 1               
  li   $a2, 3
  li   $a3, 2
  jal  extremes                   # Call the procedure
  move $s2, $v0                   # Copy results into saved registers
  move $s3, $v1
  
  # Problem 4 (Product)
  li   $a0, 2
  li   $a1, 4
  jal  product
        
  # Exit/Terminate       
  li   $v0, 10                    # Load SYSCALL service number for exit
  syscall                         # Make system call (terminating program)
# END MAIN


# Problem 1
# Procedure that transposes the values at the memory addresses stored in its two argument registers $a0 and $a1
swap:
  lw   $t0, 0($a0)		  # Load the value in $a0 into $t0
  lw   $t1, 0($a1)		  # Load the value in $a1 into $t1 
  sw   $t0, 0($a1)		  # Store the original value from the memory address stored in $a0 into $a1
  sw   $t1, 0($a0)		  # Store the original value from the memory address stored in $a1 into $a0
  jr   $ra                        # Return to caller
#END swap


# Problem 2
# Transposes the single 32-bit integer in register $a0 and returns the value in register $v0 with the bytes reversed

byteflip:
  move $t0, $a0			 # Copy the value in $a0 to $t0
  andi $t1, $t0, 0x000000FF 	 # Extract the right-most byte of the original value and store it in $t1
  sll  $t1, $t1, 24    		 # Shift the fourth byte to the left-most position
  srl  $t2, $t0, 8       	 # Extract the left-most three bytes of the original value and store it in $t2
  andi $t2, $t2, 0x00FF0000 	 # Mask the third byte (leaving only the third byte)
  srl  $t3, $t0, 16   		 # Extract the left-most two bytes of the original value and store it in $t3
  andi $t3, $t3, 0x00FF		 # Mask the second byte (leaving only the second byte)
  sll  $t3, $t3, 8    	         # Shift the masked second byte to the second position from the right
  srl  $t4, $t0, 24      	 # Extract the left-most byte of the original value and store it in $t4
  
  # Combine the bytes in reverse order
  or   $v0, $t1, $t2      	 # Combine the left-most byte and the second byte from the left into the result value $v0
  or   $v0, $v0, $t3		 # Combine the thrid byte from the left into the result value $v0
  or   $v0, $v0, $t4		 # Combine the right-most byte into the result value $v0
  jr   $ra                       # Return to caller
#END byteflip


# Problem 3
# Procedure extremes that takes four 32-bit signed integers in registers $a0, $a1, $a2, and $a3 and returns the smallest of the four values in register $v0 and the largest of the four values in $v1..

extremes:
  move $v0, $a0			 # Initialize $v0 with $a0
  move $v1, $a1			 # Initialize $v1 with $a1

# Compare $a0 with $v1
  slt  $t0, $a0, $v1		 # Compare $a0 with $v1
  beqz $t0, update_max0		 # If $a0 is equal to or larger than $v1, branch to update_max0
  j    check_a1			 # Else, jump to check_a1
  
update_max0:
  move $v1, $a0			 # Change the value of $v1 to $a0 (meaning that $a0 is the largest value for now)

# Compare $a1 with $v0
check_a1:
  slt  $t0, $a1, $v0		 # Compare $a1 with $v0
  bnez $t0, update_min0		 # If $a1 is smaller than $v0, branch to update_min0
  j    check_a2			 # Else, jump to check_a2
update_min0:
  move $v0, $a1			 # Change the value of $v0 to $a1 (meaning that $a1 is the smallest value for now)

# Compare $a2 with $v0 and $v1
check_a2:
  slt  $t0, $a2, $v0		 # Compare $a2 with $v0
  bnez $t0, update_min1	  	 # If $a2 is smaller than the value of $v0, branch to update_min1
  slt  $t0, $a2, $v1		 # Compare $a2 with $v1
  beqz $t0, update_max1  	 # If $a2 is larger than or eqaul to the value of $v1, branch to update_max1
  j    check_a3			 # Else, jump to check_a3.

update_min1:
  move $v0, $a2			 # Change the value of $v0 to $a2 (meaning that $a2 is the smallest value for now)
  j    check_a3			 # Jump to check_a3
update_max1:
  move $v1, $a2			 # Change the value of $v1 to $a2 (meaning that $a2 is the largest value for now)
  
# Compare $a3 with $v0 and $v1
check_a3:
  slt  $t0, $a3, $v0		 # Compare $a3 with $v0
  bnez $t0, update_min2		 # If $a3 is smaller than the value of $v0, branch to update_min2
  slt  $t0, $a3, $v1		 # Compare $a3 with $v1
  beqz $t0, update_max2		 # If $a3 is larger than or eqaul to the value of $v1, branch to update_max2
  j    exit			 # Else, jump to exit

update_min2:
  move $v0, $a3			 # Change the value of $v0 to $a3 (meaning that $a3 is the smallest value)
  j    exit			 # Jump to exit
update_max2:
  move $v1, $a3			 # Change the value of $v1 to $a3 (meaning that $a3 is the largest value)

# Exit
exit:
  jr   $ra                       # Return to caller
#END extremes

        
# Problem 4
# Procedure that multiplies the multiplicand value in register $a0 by the multiplier value in register $a1, using the elementary strategy of repeated addition.
product:
  li   $v0, 0			 # Initialize $v0 to 0
  move $t0, $a1			 # Initialize $t0 to $a1 (which will be used as a loop counter)
loop:
  beq  $t0, $zero, exit2	 # When the loop counter reaches 0, jump to exit2
  add  $v0, $v0, $a0		 # Add the multiplicand value ($a0) to $v0
  addi $t0, $t0, -1		 # Decrement the loop counter by 1
  j    loop			 # Jump back to the loop
exit2:
  jr   $ra                        # Return to caller
#END product
