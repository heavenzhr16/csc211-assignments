# MIPS Procedures
# CSC 211
# Original main (and stubs) and macros written by Jerod Weinman

# Because MARS does not heed the .ent directive to specify the entry point,
# we must put the "main" routine first. Otherwise, we'd include main in the
# .globl symbols below and uncomment the following line:
#.ent main

# Ensure the following procedure labels are globally visible
.globl remainder, gcd, gcdtail, count, reverse

.data                             # Arrays and strings for global processing

# The following array has 100 random numbers in [0-10]
numbers: .word 9, 6, 2, 2, 1, 5, 5, 10, 1, 7, 8, 2, 4, 0, 3, 9, 3, 4, 8, 4, 6,
               8, 4, 9, 8, 4, 0, 7, 6, 5, 5, 0, 0, 1, 9, 6, 6, 5, 7, 6, 1, 7,
               7, 2, 8, 0, 0, 2, 0, 4, 2, 6, 8, 4, 0, 4, 8, 6, 2, 10, 6, 6, 0,
               7, 4, 10, 5, 5, 1, 1, 3, 7, 4, 4, 8, 5, 8, 8, 8, 10, 8, 5, 6, 3,
               5, 3, 0, 2, 2, 0, 4, 3, 3, 6, 6, 1, 0, 6, 9, 7

message: .asciiz "Hello, world!"
        
.text                             # Start generating instructions

# Parameterized macros for text output
.macro print_str (%addr)
  la   $a0, %addr                 # Load argument (string pointer) into register
  li   $v0, 4                     # Load "print string" SYSCALL service number
  syscall                         # Make system call (printing string)
.end_macro

.macro putchar (%ch)
  li   $a0, %ch                   # Load argument (ASCII char) into register
  li   $v0, 11                    # Load "print char" SYSCALL service number
  syscall
.end_macro

        
# main        
# Run the assignment procedure(s).
# You may edit anything within main for testing, as it will not be graded
main:
  # Problem 1 (Remainder)
  li   $a0, 24                    # Load arguments into registers
  li   $a1, 7
  jal  remainder                  # Call the procedure
  move $s2, $v0                   # Copy result into saved registers

  # Problem 2 (GCD)
  li   $a0, 66                    # Load arguments into registers
  li   $a1, 24
  jal  gcdtail                        # Call the procedure
  move $s3, $v0
        
  # Problem 3 (Frequency Count)
  la   $a0, numbers               # Load argument (array pointer, beginning)
  addi $a0, $a0, 32               # Example: shift pointer 8 ints into array
  li   $a1, 10                    # Load argument for length
  li   $a2, 5                     # Load argument for sought      
  jal  count                      # Call the procedure (result is in $v0)

  # Problem 4 (String Reverse)
  print_str(message)              # Invoke macro for output
  putchar('\n')                   # Invoke macro to separate lines ('\n'=0xA)
        
  la   $a0, message               # Load argument (string pointer) into register
  jal  reverse                    # Call the procedure

  print_str(message)              # Invoke macro for output (reversed)
        
        
  li   $v0, 10                    # Load exit SYSCALL service number
  syscall                         # Make system call (terminating program)
# END MAIN



# Problem 1
# Calculates the remainder of two 32-bit integers
remainder:
  addi   $sp, $sp, -12 		  # Initializes stack with three spaces
  sw     $s1, 8($sp)              # Pushes (saves) $s1 on to the stack
  sw     $ra, 4($sp) 		  # Pushes (saves) the return address on to the stack
  sw     $s0, 0($sp) 		  # Pushes (saves) $s0 on to the stack

  move   $s0, $a0 		  # Copies a into $s0

remainder_loop:
  beq    $a1, $s0, subtract       # If $a1 == $s0, go to subtract
  nop				  # Delay Slot
  slt    $s1, $a1, $s0            # If a >= b, set $s1 = 1
  beqz   $s1, remainder_exit      # If $s1 = 0 (a < b), go to remainder_exit
  nop				  # Delay Slot

subtract:
  sub    $s0, $s0, $a1            # a = a - b
  j      remainder_loop           # Repeat reaminder_loop
  nop				  # Delay slot

remainder_exit:
  move   $v0, $s0		  # Copies $s0 to $v0 (the remainder)
  lw     $s0, 0($sp) 		  # Restore $s0 from the stack
  lw     $ra, 4($sp) 		  # Restore the return address ($ra) from the stack
  lw     $s1, 8($sp) 		  # Restore $s1 from the stack
  addi   $sp, $sp, 12 		  # Restore the stack pointer 
  
  jr     $ra                      # Return to caller
  nop				  # Delay slot
  
#END remainder

        
# Problem 2
# Returns the greatest common divisor between two numbers
gcd:
# $a0 = m, $a1 = n
  addi   $sp, $sp, -4    	  # Initalize stack for one variable
  sw     $ra, 0($sp)     	  # Pushes (saves) $ra on to the stack

  beqz   $a1, gcd_base   	  # Base case : If n == 0, go to gcd_base
  nop				  # Delay Slot
  jal    remainder       	  # If not, calculate remainder(m,n), the result is stored in $s2
  nop
  move   $a0, $a1		  # Set m to n
  move   $a1, $v0	  	  # Set n to remainder(m,n)
  jal    gcd             	  # Recursive call on gcd(n, remainder(m,n))
  nop

gcd_base:
  move   $v0, $a0        	  # If it is the base case (n==0), return m

gcd_exit:
  lw     $ra, 0($sp)     	  # Restore the return address ($ra) from the stack
  addi   $sp, $sp, 4     	  # Restore the stack pointer
  jr     $ra             	  # Return to caller
  nop				  # Delay slot
    
#END gcd

# Returns the greatest divisor between two numbers through tail recursion
gcdtail:
  beqz   $a1, gcdtail_base        # Base case : If n == 0, go to gcdtail_base
  nop				  # Delay slot
  rem    $t0, $a0, $a1      	  # If not, calculate remainder(m,n), and store it in $t0
  move   $a0, $a1           	  # Set m to n
  move   $a1, $t0           	  # Set n to remainder(m,n)
  j      gcdtail            	  # Do the tail recursion: jump to start of gcdtail
  nop				  # Delay slot

gcdtail_base:
  move   $v0, $a0           	  # If it is the base case, return m
  jr     $ra                      # Return to caller
  nop				  # Delay slot
#END gcdtail


# Problem 3
# Returns the frequency of the value k in the array of n items starting at p
count:
  addi   $sp, $sp, -8     	  # Initialize stack for two items
  sw     $ra, 4($sp)       	  # Pushes (saves) $ra on to the stack
  sw     $s0, 0($sp)        	  # Pushes (saves) $s0 on to the stack

  move   $s0, $a0          	  # $s0 takes the pointer *p
  li     $t0, 0            	  # $t0 = count of how many times the value k is in the array

count_loop:
  beqz   $a1, count_exit   	  # If n == 0, go to count_exit
  nop				  # Delay slot
  lw     $t1, 0($s0)       	  # $t1 takes the value of what the pointer is pointing at
  beq    $t1, $a2, count_detect   # If *p == k, jump to count_detect
  nop				  # Delay slot
  addi   $s0, $s0, 4       	  # Increment pointer
  addi   $a1, $a1, -1      	  # Decrement n
  j    count_loop                 # Repeat count_loop
  nop				  # Delay slot

count_detect:
  addi   $t0, $t0, 1       	  # Increment count (means that we have detected k in the array)
  addi   $s0, $s0, 4       	  # Increment pointer
  addi   $a1, $a1, -1      	  # Decrement n
  j    count_loop                 # Repeat count_loop
  nop				  # Delay slot

count_exit:
  lw     $ra, 4($sp)       	  # Restore $ra from the stack
  lw     $s0, 0($sp)       	  # Restore $s0 from the stack
  addi   $sp, $sp, 8      	  # Restore the stack pointer
  move   $v0, $t0          	  # Return count
  jr     $ra               	  # Return to caller
  nop				  # Delay slot

#END count


# Problem 4
# Takes a null-terminated string and reverses that string in place
# $s0 == pointer to the [j]th character of the string, $s1 == pointer to the [i]th character of the string
# $t0 == first character of the string, $t1 == the index [i], $t2 == the index [j] -> length before the null-terminator
reverse:
  addi 	 $sp, $sp, -12      	  # Initialize stack for three items
  sw 	 $s1, 8($sp)          	  # Pushes (saves) $s1 on to the stack
  sw 	 $s0, 4($sp)          	  # Pushes (saves) $s0 on to the stack
  sw 	 $ra, 0($sp)          	  # Pushes (saves) $ra on to the stack

  
  add 	 $s0, $a0, $zero      	  # Copy pointer to $s0
  add 	 $s1, $a0, $zero     	  # Copy pointer to $s1
  lb 	 $t0, ($s0)           	  # Loads the first character to $t0
  beqz 	 $t0, reverse_done        # If the first character == null terminator, go to done.
  nop				  # Delay Slot
  
  addi 	 $t1, $zero, 0      	  # Initialize the first index  [i]
  addi 	 $t2, $zero, 0      	  # Initialize the second index [j], counts the length
  
reverse_length:
  lb 	 $t0, ($s0)           	  # Load the current character to $t0
  beqz 	 $t0, reverse_swap    	  # If $t0 == null terminator (0), go to reverse_swap
  nop				  # Delay Slot
  
  addi 	 $s0, $s0, 1        	  # Increments pointer to the next character
  addi   $t2, $t2, 1        	  # Increments length
  
  j      reverse_length           # Loop reverse_length again
  nop				  # Delay Slot
  
reverse_swap:
  addi   $t2, $t2, -1       	  # Decrement the length by 1 to remove the null terminator
  srl    $t2, $t2, 1         	  # Divide length by 2 to get the number of swaps needed
  addi   $s0, $s0, -1        	  # Decrement the pointer by 1 to remove the null terminator
  
reverse_loop:
  blt 	 $t2, $t1, reverse_done   # If i >= n/2, go to reverse_done
  nop				  # Delay Slot
  
  lb 	 $t3, ($s1)           	  # Load ith character to $t3
  lb 	 $t4, ($s0)           	  # Load jth character to $t4
  sb 	 $t4, ($s1)           	  # Store jth character in ith position
  sb 	 $t3, ($s0)           	  # Store ith character in jth position
  
  addi 	 $s1, $s1, 1        	  # Increment pointer of ith character to next character
  addi 	 $s0, $s0, -1       	  # Decrement pointer of jth character to previous character
  addi 	 $t1, $t1, 1        	  # Increment index i
  
  j 	 reverse_loop             # Loop through reverse_loop
  nop				  # Delay Slot
  
reverse_done:
  lw 	 $ra, 0($sp)          	  # Restore $ra from the stack
  lw 	 $s0, 4($sp)          	  # Restore $s0 from the stack
  lw 	 $s1, 8($sp)          	  # Restore $s1 from the stack
  addi 	 $sp, $sp, 12        	  # Restore stack pointer
  
  jr 	 $ra			  # Return to caller
  nop				  # Delay Slot
#END reverse
