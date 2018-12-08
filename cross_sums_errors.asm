#
# FILE:                 cross_sums_errors.asm
# AUTHOR:               W. Lee
# CREATION DATE:        October 26, 2018
# LAST MODIFIED:        November 26, 2018
#
#
# DESCRIPTION:
#       This program checks for errors in the input_array before
#       printing or solving the cross sums board
#
# ARGUMENTS:
#       None
#
# INPUT:
#       None
#
# OUTPUT:
#       If there are errors it will print the error message and exit the program
#       If there are no errors it will continue to print init board and solve it
#

# CONSTANTS
#
# syscall codes
PRINT_STRING = 	4
EXIT = 		10

        .data
        .align  0

invalid_board_size:
        .asciiz  "Invalid board size, Cross Sums terminating\n"

illegal_input:
        .asciiz "Illegal input value, Cross Sums terminating\n"

impossible_puzzle:
        .asciiz  "Impossible Puzzle\n"

        .text
        .align  2

        # Characters/Strings to check
        .globl  board_size
        .globl  board_size_doubled
        .globl  input_array
        .globl  invalid_board_size

        # Functions
        .globl  initial_error_checking
        .globl  print_newline
        .globl  print_impossible_puzzle

#
# Name:		initial_error_checking
#
# Description:	Loads input from the input_array and checks if
#               the board size and input values are valid
#
# Arguments:	None
# Returns:	If board size or input value os invalid or illegal, it
#               prints an error statment and exits the program
#
initial_error_checking:
        addi 	$sp, $sp, -8  	# allocate space for the return address
        sw 	$ra, 4($sp)	# store the ra on the stack
        sw 	$s0, 0($sp)

        jal     board_size_check        # Function to check board_size
        jal     illegal_input_check     # Function to check input

initial_error_checking_done:
        lw 	$ra, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 8   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

board_size_check:
        la      $s0, board_size         # Loads addr of board_size
        lw      $s0, 0($s0)             # Loads board size val into $s0

        li      $t0, 1                  # Loads temp val
        slt     $t1, $t0, $s0           # If 1 <= board size; set $t1 = 1
        beq     $t1, $zero, print_invalid_board_size  # If $t1 == 0; goto
                                                      # print_invalid_board_size

        li      $t0, 13                 # Loads temp val
        slt     $t1, $s0, $t0           # If board size <= 13; set $t1 = 1
        beq     $t1, $zero, print_invalid_board_size  # If $t1 == 0; goto
                                                      # print_invalid_board_size

board_size_check_done:
        jr      $ra

illegal_input_check:
        la      $s0, input_array        # Loads addr of input_array
        la      $s1, board_size_doubled # Loads addr of board_size_doubled
        lw      $t9, 0($s1)             # Loads board_size_doubled val (counter)
                                                # Ex. board_size = 8;
                                                # board_size_doubled = 8^2; 64
        addi    $t9, $t9, 1             # Adds 1 to the counter

illegal_input_check_loop:
        beq     $t9, $zero, initial_error_checking_done # If cnt == 0; goto
                                                   # initial_error_checking_done
        lw      $t0, 0($s0)     # Loads curr index of array

        li      $t1, 100        # Loads temp val
        div     $t0, $t1        # Divides curr val / 100
        mflo    $t2             # Quotient (Ex. 1234 / 100 -> 12)
        mfhi    $t3             # Remainder (Ex. 1234 % 100 = 23)

        ### Check if num is 0, 99, or 1-45 here ###
        add    $a0, $zero, $t2  # Loads Quotient into $a0 for valid_number_check
        jal     valid_number_check      # Jump and link to valid_number_check

        add    $a0, $zero, $t3 # Loads Remainder into $a0 for valid_number_check
        jal     valid_number_check      # Jump and link to valid_number_check

        addi    $t9, $t9, -1                    # Adds -1 to counter
        addi    $s0, $s0, 4                     # Adds 4 to move up input_array
        j       illegal_input_check_loop        # Jumps back to the loop

valid_number_check:
        # $a0 is the curr number to check
        beq     $a0, $zero, valid_number_check_done    # If $a0 == 0; goto done
        li      $t1, 99                                # Loads temp val
        beq     $a0, $t1, valid_number_check_done      # If $a0 == 99; goto done

        slt     $t1, $zero, $a0           # If 0 <= board size; set $t1 = 1
        beq     $t1, $zero, print_illegal_input  # If $t1 == 0; goto
                                                      # print_invalid_board_size

        li      $t0, 46                 # Loads temp val
        slt     $t1, $a0, $t0           # If board size <= 46; set $t1 = 1
        beq     $t1, $zero, print_illegal_input  # If $t1 == 0; goto
                                                      # print_illegal_input

valid_number_check_done:
        jr      $ra

################################################################################
#
# Name:		print_invalid_board_size
#
# Description:	Prints the invalid board size error and exits
#
# Arguments:	None
# Returns:	None
#
print_invalid_board_size:
        li      $v0, PRINT_STRING       # Loads const to print str
        la      $a0, invalid_board_size # Loads addr of invalid_board_size
        syscall

        li      $v0, EXIT               # Loads const to exit program
        syscall

################################################################################
#
# Name:		print_illegal_input
#
# Description:	Prints the illegal input error and exits
#
# Arguments:	None
# Returns:	None
#
print_illegal_input:
        add    $t9, $zero, $a0          # Stores $a0 into $t9
        li      $v0, PRINT_STRING       # Loads const to print str
        la      $a0, illegal_input      # Loads addr of illegal_input
        syscall

        li      $v0, EXIT               # Loads const to exit program
        syscall

################################################################################
#
# Name:		print_impossible_puzzle
#
# Description:	Prints the impossible puzzle error and exits
#
# Arguments:	None
# Returns:	None
#
print_impossible_puzzle:
        li      $v0, PRINT_STRING       # Loads const to print string
        la      $a0, impossible_puzzle  # Loads impossible_puzzle
        syscall

        li      $v0, EXIT               # Loads const to exit
        syscall 
