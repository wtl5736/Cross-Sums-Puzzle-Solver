#
# FILE:                 cross_sums.asm
# AUTHOR:               W. Lee
# CREATION DATE:        October 25, 2018
# LAST MODIFIED:        November 26, 2018
#
#
# DESCRIPTION:
#       Main file that performs or calls all necessary functions to solve the
#       cross sums board.
#
# ARGUMENTS:
#       Reads in board from file.
#
# INPUT:
#       The input is read in from a file
#
# OUTPUT:
#       Prints out an initial and solved cross sum board.
#

# CONSTANTS
#
# syscall codes
PRINT_INT = 	1
PRINT_STRING = 	4
READ_INT = 	5
EXIT = 		10

        .data
        .align  2

board_size:
        .space  4               # First Number in file

board_size_doubled:
        .space  4               # First Number in file doubled N*N

input_array:
        .space  12*12*4         # Max Size * Max Size * 4 (Word)

solved_array:
        .space  12*12*4         # Max Size * Max Size * 4 (Word)

current_value:
        .byte   2               # Current value in the array being prcoessed

# Pointer to board struct
Pointer_to_Cell:
        .word   temp_board

First_Cell:
        .word   0               # Keeps the first cell of the board

        .text
        .align  2

        # Characters/Strings to print
        .globl  board_size
        .globl  board_size_doubled
        .globl  blocking_clue_top
        .globl  blocking_clue_mid
        .globl  blocking_clue_bot
        .globl  across_clue_one
        .globl  back_slash
        .globl  hashtag
        .globl  single_space
        .globl  triple_space
        .globl  temp_board
        .globl  Pointer_to_Cell
        .globl  First_Cell

        # Functions to print
        .globl  print_banner
        .globl  print_init_banner
        .globl  print_final_banner
        .globl  print_newline
        .globl  print_single_space
        .globl  print_divider
        .globl  print_border

        # Functions to solve the puzzle
        .globl  puzzle_solver_main

        # Functions for error checking
        .globl  initial_error_checking
        .globl  invalid_board_size

main:
        addi 	$sp, $sp, -40  	# allocate space for the return address
        sw 	$ra, 32($sp)	# store the ra on the stack
        sw 	$s7, 28($sp)
        sw 	$s6, 24($sp)
        sw 	$s5, 20($sp)
        sw 	$s4, 16($sp)
        sw 	$s3, 12($sp)
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

        jal     print_newline
        jal     print_banner            # Prints the main banner
        jal     read_cells              # Reads in input
        jal     initial_error_checking  # Checks board size and input values

        li      $a0, 0
        jal     print_board     # Prints the initial board

        jal     puzzle_solver_main      # Tries to solve the puzzle

        li      $a0, 1
        jal     print_board     # Prints the solved board

main_done:
        lw 	$ra, 32($sp)
        lw 	$s7, 28($sp)
        lw 	$s6, 24($sp)
        lw 	$s5, 20($sp)
        lw 	$s4, 16($sp)
        lw 	$s3, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 40   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################

#
# Name:		read_cells
#
# Description:	Reads in input from file and stores it in an array
#
# Arguments:	None
# Returns:	Returns input_array with stored values from file
#
read_cells:
        addi 	$sp, $sp, -8  	# allocate space for the return address
        sw 	$ra, 4($sp)	# store the ra on the stack
        sw 	$s0, 0($sp)

        la      $s0, board_size        # Loads addr of input_array
        li      $v0, READ_INT           # Loads const to read in int from file
        syscall
        sw      $v0, 0($s0)             # Stores read in int into input array
        beq     $v0, $zero, zero_board_size     # Checks if board size = 0

        la      $s0, board_size_doubled # Loads board size doubled (N*N)
        mul     $v0, $v0, $v0           # N*N
        sw      $v0, 0($s0)             # Stores the doubled board size

        la      $s0, input_array        # Loads the array to store the read in
                                                # values

        add     $t0, $zero, $v0         # Moves the board size into $t0

read_cells_loop:
        beq     $zero, $t0, read_cells_done  # Checks if counter = 0

        li      $v0, READ_INT           # Loads const to read in int val
        syscall
        sw      $v0, 0($s0)             # Stores read in int into input_array

        addi    $t0, $t0, -1            # Adds -1 to counter
        addi    $s0, $s0, 4             # Adds 4 to move up input_array

        j       read_cells_loop         # Jumps back to top of read_cells_loop

zero_board_size:
        li      $v0, PRINT_STRING              # Loads const to print str
        la      $a0, invalid_board_size        # Loads addr to be printed
        syscall

        li      $v0, EXIT                      # Loads const to exit program
        syscall

read_cells_done:
        lw 	$ra, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 8   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################

#
# Name:		print_board
#
# Description:	Reads values in from array and prints the board
#
# Arguments:	None
#               a0     0 (init array) or 0 (solved array)
# Returns:	Prints init or solved board
#
print_board:
        addi 	$sp, $sp, -40  	# allocate space for the return address
        sw 	$ra, 32($sp)	# store the ra on the stack
        sw 	$s7, 28($sp)
        sw 	$s6, 24($sp)
        sw 	$s5, 20($sp)
        sw 	$s4, 16($sp)
        sw 	$s3, 12($sp)
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

        la      $s0, board_size         # Loads addr of board_size
        lw      $s1, 0($s0)             # Loads the board size
        add     $t9, $zero, $s1         # Board size (ex. 8, 7, 12)

        la      $s0, board_size_doubled # Loads addr of board_size
        lw      $s2, 0($s0)             # Loads the board size (N*N)
                                        # (ex. 8*8 = 64)

        li      $t8, 1
        addi    $s7, $zero, 1           # Row Count

        beq     $a0, $zero, load_init_array       # If $a0 == $t0
        bne     $a0, $zero, load_solved_array       # If $a0 == $t0

load_init_array:
        jal     print_init_banner
        add     $a0, $zero, $s1         # Move into $a0 for print_border func
        jal     print_border            # Prints the boarder
        la      $s0, input_array        # Array of numbers with cell info
        la      $s5, input_array        # Array of numbers with cell info
        la      $s6, input_array        # Array of numbers with cell info
        j       print_board_loop

load_solved_array:
        jal     print_final_banner
        add     $a0, $zero, $s1         # Move into $a0 for print_border func
        jal     print_border            # Prints the boarder
        la      $s0, solved_array        # Array of numbers with cell info
        la      $s5, solved_array        # Array of numbers with cell info
        la      $s6, solved_array        # Array of numbers with cell info
        j       print_board_loop

print_board_loop:
        beq     $t9, $zero, reset_counters  # Checks if counter has readched
                                                # zero

        lw      $s3, 0($s0)             # Loads curr index of array
        jal     print_divider           # Prints a divider

        addi    $t9, $t9, -1            # Adds -1 to counter
        addi    $s0, $s0, 4             # Adds 4 to move up input_array

        ### Do board cell building here###
        li      $t0, 1                  # Loads temp val
        beq     $t8, $t0, top_check     # Checks if its the top row of the cell
        li      $t0, 2                  # Loads temp val
        beq     $t8, $t0, mid_check     # Checks if its the mid row of the cell
        li      $t0, 3                  # Loads temp val
        beq     $t8, $t0, bot_check     # Checks if its the bot row of the cell

top_check:
                                        # # Checks for top row in cell
        li      $t1, 9999               # Loads temp val
        beq     $s3, $t1, print_blocking_clue_top   # Checks if curr val == 9999
        beq     $s3, $zero, print_triple_space_init # Checks if curr val == 0

        li      $t1, 10                         # Loads temp val
        slt     $t4, $s3, $t1                   # If curr val < 10; sets $t4 = 1
        bne     $t4, $zero, solved_num_top      # If $t4 != zero
                                                        # goto solved_num_top

        li      $t1, 100        # Loads temp val
        div     $s3, $t1        # divides the current val from array by 100
        mflo    $t3             # Quotient (Ex. 1234 / 100 -> 12)
        mfhi    $t2             # Remainder (Ex. 1234 % 100 = 23)

        # across_clue_check
        li      $t1, 99         # Loads temp val
        beq     $t3, $t1, down_clue_check_top     # Checks if Quotient = 99
        beq     $t2, $t1, across_clue_check_top   # Checks if Remainder = 99
        j       down_and_across_clue_check_top    # Else it jumps to both
                                                        # down_and_across_clue

mid_check:
                                        # Checks for middle row in cell
        li      $t1, 9999                           # Loads temp val
        beq     $s3, $t1, print_blocking_clue_mid   # Checks if curr val == 9999
        beq     $s3, $zero, print_triple_space_init # Checks if curr val == 0

        li      $t1, 10                         # Loads temp val
        slt     $t4, $s3, $t1                   # If curr val < 10; sets $t4 = 1
        bne     $t4, $zero, solved_num_mid      # If $t4 != zero
                                                        # goto solved_num_mid

        j       print_blocking_clue_mid             # Else it jumps to both
                                                        # down_and_across_clue

bot_check:
                                        # Checks for bottom row in cell
        li      $t1, 9999                           # Loads temp val
        beq     $s3, $t1, print_blocking_clue_bot   # Checks if curr val == 9999
        beq     $s3, $zero, print_triple_space_init # Checks if curr val == 0

        li      $t1, 10                         # Loads temp val
        slt     $t4, $s3, $t1                   # If curr val < 10; sets $t4 = 1
        bne     $t4, $zero, solved_num_bot      # If $t4 != zero
                                                        # goto solved_num_bot

        li      $t1, 100        # Loads temp val
        div     $s3, $t1        # Divides the current val from array by 100
        mflo    $t3             # Quotient
        mfhi    $t2             # Remainder

        # across_clue_check
        li      $t1, 99                           # Loads temp val
        beq     $t3, $t1, down_clue_check_bot     # Checks if Quotient = 99
        beq     $t2, $t1, across_clue_check_bot   # Checks if Remainder = 99
        j       down_and_across_clue_check_bot    # Else it jumps to both
                                                        # down_and_across_clue

solved_num_top:
        j       print_triple_space_init         # Prints a triple space

solved_num_mid:
        jal     print_single_space              # Prints a single space

        li      $v0, PRINT_INT                  # Loads conts to print int
        add     $a0, $zero, $s3                 # $a0 = int to print
        syscall

        jal     print_single_space              # Prints a single space
        j       print_board_loop                # Jumps back to print_board_loop

solved_num_bot:
        j       print_triple_space_init         # Prints a triple space

across_clue_check_top:
                                # Across clue for top row
        li      $t1, 99                                  # Loads temp val
        beq     $t2, $t1, down_and_across_clue_check_top # Checks for across and
                                                                # down clues

                                # $t3 = Quotient of curr val from input_array
        li      $t0, 10         # Loads temp val
        div     $t3, $t0        # Divides $t3 by 10
        mflo    $t4             # Quotient (Ex. 12 % 10 -> 1)
        mfhi    $t3             # Remainder  (Ex. 12 / 10 -> 2)

        la      $t5, current_value      # Loads addr of current_value
        sb      $t4, 0($t5)             # Stores Quotient
        addi    $t5, $t5, 1             # Adds 1 to move up char array
        sb      $t3, 0($t5)             # Stores Remainder

        la      $t5, current_value      # Loads addr of current_value
        lb      $a0, 0($t5)             # Loads the Quotient into $a0
        addi    $t5, $t5, 1             # Adds 1 to go to next index in array
        lb      $a1, 0($t5)             # Loads the Remainder into $a1

        bne     $a0, $zero, print_across_clue_two  # Checks if $a0 != 0
        beq     $a0, $zero, print_across_clue_one  # Checks if $a0 == 0
                                        # Zero meaning a single digit number or
                                        # a double digit number
                                        # Single Digit = 07
                                        # Double Digit = 19

across_clue_check_bot:
                                # Across clue for bot row
        li      $t1, 99                                  # Loads temp val
        beq     $t3, $t1, down_and_across_clue_check_bot # Checks if
                                                             # curr val == 9999
        j       print_blocking_clue_bot         # Prints blocking clue to the
                                                        # bottom cell of the row

down_clue_check_top:
                                                # Down clue for top row
        li      $t1, 99                         # Loads temp val
        beq     $t2, $t1, down_and_across_clue_check_top # Checks for across and
                                                                # down clues
        j       print_blocking_clue_top         # Prints blocking clue to the
                                                        # top cell of the row

down_clue_check_bot:
                                # Down clue for bot row
        li      $t1, 99                                  # Loads temp val
        beq     $t2, $t1, down_and_across_clue_check_bot # Checks for across and
                                                                # down clues

                                # $t2 = Remainder of curr val from input_array
        li      $t0, 10         # Loads temp val
        div     $t2, $t0        # Divides $t2 by 10
        mflo    $t4             # Quotient (Ex. 12 / 10 -> 2)
        mfhi    $t3             # Remainder (Ex. 12 % 10 -> 1)

        la      $t5, current_value      # Loads addr of current_value
        sb      $t4, 0($t5)             # Stores Quotient
        addi    $t5, $t5, 1             # Adds 1 to move up char array
        sb      $t3, 0($t5)             # Stores Remainder

        la      $t5, current_value      # Loads the addr of current_value
        lb      $a0, 0($t5)             # Loads the Quotient into $a0
        addi    $t5, $t5, 1             # Adds 1 to move up char array
        lb      $a1, 0($t5)             # Loads the Remainder into $a1

        bne     $a0, $zero, print_down_clue_two # Checks if Quoteient != 0
        beq     $a0, $zero, print_down_clue_one # Checks if Quoteient == 0
                                        # Zero meaning a single digit number or
                                        # a double digit number
                                        # Single Digit = 07
                                        # Double Digit = 19

down_and_across_clue_check_top:
                        # Has both across and down clues (top row)
        li      $t0, 10         # Loads temp val
        div     $t3, $t0        # Divides $t3 by 10
        mflo    $t4             # Quotient (Ex. 12 / 10 -> 2)
        mfhi    $t3             # Remainder (Ex. 12 % 10 -> 1)

        la      $t5, current_value      # Loads addr of current_value
        sb      $t4, 0($t5)             # Stores Quotient
        addi    $t5, $t5, 1             # Adds 1 to move up char array
        sb      $t3, 0($t5)             # Stores Remainder

        la      $t5, current_value      # Loads the addr of current_value
        lb      $a0, 0($t5)             # Loads the Quotient into $a0
        addi    $t5, $t5, 1             # Adds 1 to move up char array
        lb      $a1, 0($t5)             # Loads the Remainder into $a1

        bne     $a0, $zero, print_across_clue_two # Checks if Quoteient != 0
        beq     $a0, $zero, print_across_clue_one # Checks if Quoteient == 0
                                        # Zero meaning a single digit number or
                                        # a double digit number
                                        # Single Digit = 07
                                        # Double Digit = 19

down_and_across_clue_check_bot:
                        # Has both across and down clues (bot row)
        li      $t0, 10         # Loads temp val
        div     $t2, $t0        # Divides $t2 by 10
        mflo    $t4             # Quotient (Ex. 12 / 10 -> 2)
        mfhi    $t3             # Remainder (Ex. 12 % 10 -> 1)

        la      $t5, current_value      # Loads addr of current_value
        sb      $t4, 0($t5)             # Stores Quoteient
        addi    $t5, $t5, 1             # Adds 1 to move up char array
        sb      $t3, 0($t5)             # Stores Remainder

        la      $t5, current_value      # Loads addr of current_value
        lb      $a0, 0($t5)             # Loads the Quotient in to $a0
        addi    $t5, $t5, 1             # Adds 1 to move up char array
        lb      $a1, 0($t5)             # Loads the Remainder into $a1

        bne     $a0, $zero, print_down_clue_two # Checks if Quoteient != 0
        beq     $a0, $zero, print_down_clue_one # Checks if Quoteient == 0
                                        # Zero meaning a single digit number or
                                        # a double digit number
                                        # Single Digit = 07
                                        # Double Digit = 19

reset_counters:
        addi    $t8, $t8, 1             # Row within row counter (max = 3)
        add     $t9, $zero, $s1         # Resets

        jal     print_divider           # Prints cell divider
        jal     print_newline           # Prints a newline

        add     $s5, $zero, $s0         # Saves the current position into $s5
        add     $s0, $zero, $s6         # resets back to starting position of
                                        # that row to print the 2nd and 3rd row
                                        # within that entire row.

        li      $t7, 4                  # Loads temp val
        beq     $t8, $t7, row_done      # Checks if cell has reached max height
        j       print_board_loop        # Jumps back to print_board_loop

row_done:             # Goes here when num of cells in row reached max size = 3
        beq     $s1, $s7, print_init_board_done # Checks if its reached max
                                                        # board size length
        add     $a0, $zero, $s1         # Moves board size as arg to
                                                # print_boarder
        jal     print_border            # Prints the borders

        add     $t9, $zero, $s1         # Moves board size into $t9
        li      $t8, 1                  # Loads 1 into $t8

        add     $s6, $zero, $s5         # Moves curr position into $s6
        add     $s0, $zero, $s5         # Loads curr position into $s6
        add     $t9, $zero, $s1         # Loads board size into $t9
        addi    $s7, $s7, 1             # Increment Number of rows added
        j       print_board_loop        # Jumps to the top loop for print init

print_triple_space_init:
        li      $v0, PRINT_STRING       # Loads code to print str
        la      $a0, triple_space       # Loads addr of val to print
        syscall
        j       print_board_loop   # Jumps to top of print_board_loop

print_blocking_clue_top:
        li      $v0, PRINT_STRING       # Loads code to print str
        la      $a0, blocking_clue_top  # Loads addr of val to print
        syscall
        j       print_board_loop   # Jumps to top of print_board_loop

print_blocking_clue_mid:
        li      $v0, PRINT_STRING       # Loads code to print str
        la      $a0, blocking_clue_mid  # Loads addr of val to print
        syscall
        j       print_board_loop   # Jumps to top of print_board_loop

print_blocking_clue_bot:
        li      $v0, PRINT_STRING       # Loads code to print str
        la      $a0, blocking_clue_bot  # Loads addr of val to print
        syscall
        j       print_board_loop   # Jumps to top of print_board_loop

print_across_clue_one:
                                        # $a0 = Quotient, $a1 = Remainder
        li      $v0, PRINT_STRING       # Loads code to print str
        la      $a0, across_clue_one    # Loads addr of val to print
        syscall

        li      $v0, PRINT_INT          # Loads code to print int
        add     $a0, $zero, $a1         # Moves $a1 -> $a0 to print
        syscall
        j       print_board_loop   # Jumps to top of print_board_loop

print_across_clue_two:
                                        # $a0 = Quotient, $a1 = Remainder
        add     $t0, $zero, $a0         # Stores $a0 -> $t0 to use later
        li      $v0, PRINT_STRING       # Loads code to print str
        la      $a0, back_slash         # Loads addr of val to print
        syscall

        li      $v0, PRINT_INT          # Loads code to print int
        add     $a0, $zero, $t0         # Moves $t0 -> $a0 to print
        syscall

        add     $a0, $zero, $a1         # Moves $a1 -> $a0 to print
        syscall

        j       print_board_loop   # Jumps to top of print_board_loop

print_down_clue_one:
                                        # $a0 = Quotient, $a1 = Remainder
        li      $v0, PRINT_STRING       # Loads code to print str
        la      $a0, hashtag            # Loads code to print str
        syscall

        li      $v0, PRINT_INT          # Loads code to print int
        add     $a0, $zero, $a1         # Moves $a1 -> $a0 to print
        syscall

        li      $v0, PRINT_STRING       # Loads code to print str
        la      $a0, back_slash         # Loads code to print str
        syscall

        j       print_board_loop   # Jumps to top of print_board_loop

print_down_clue_two:
                                        # $a0 = Quotient, $a1 = Remainder
        add     $t0, $zero, $a0         # Stores $a0 -> $t0 to use later
        li      $v0, PRINT_INT          # Loads code to print int
        add     $a0, $zero, $t0         # Moves $t0 -> $a0 to print
        syscall

        add     $a0, $zero, $a1         # Moves $a1 -> $a0 to print
        syscall

        li      $v0, PRINT_STRING       # Loads code to print str
        la      $a0, back_slash         # Loads code to print str
        syscall

        j       print_board_loop   # Jumps to top of print_board_loop

print_init_board_done:
        add    $a0, $zero, $s1          # Moves board size as arg for
                                                # for print_boarder
        jal     print_border            # Prints the boarders
        jal     print_newline           # Prints a new line

        lw 	$ra, 32($sp)
        lw 	$s7, 28($sp)
        lw 	$s6, 24($sp)
        lw 	$s5, 20($sp)
        lw 	$s4, 16($sp)
        lw 	$s3, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 40   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
