#
# FILE:                 cross_sums_algorithm.asm
# AUTHOR:               W. Lee
# CREATION DATE:        October 25, 2018
# LAST MODIFIED:        November 26, 2018
#
#
# DESCRIPTION:
#       This program contains all of the necessary code to solve the board read
#       in from the file.
#
# ARGUMENTS:
#       None
#
# INPUT:
#       The input read in from a file.
#
# OUTPUT:
#       Prints out an initial and solved cross sum board.
#


#
# Name:		puzzle_solver
#
# Description:	Solves the puzzle
#
# Arguments:	None
# Returns:	Solves the puzzle and stores it in solved_array.
#

        .data
        .align  2

# Temp board holding both input value and guessed value
# Node (Cell) Structure:
#       Input Value = 4 bytes
#       Guessed Value = 4 bytes
temp_board:
        .space  12 * 12 * 8 + 4 # Max Size * Max Size * 8 (8 bytes = 2 Words)
                                #        + 4 (Padding)

Curr_Cell:
        .word   0               # Keeps the current cell values

        .text
        .align  2

        # Characters/Strings to use to solve
        .globl  board_size
        .globl  board_size_doubled
        .globl  input_array
        .globl  solved_array
        .globl  temp_board
        .globl  Pointer_to_Cell
        .globl  First_Cell
        .globl  impossible_puzzle

        # Functions to solve puzzle
        .globl  puzzle_solver_main
        .globl  array_to_struct
        .globl  struct_to_array
        .globl  is_solved
        .globl  init_solve
        .globl  print_impossible_puzzle
        .globl  get_prev_cell
        .globl  reset_cell
        .globl  get_quotient
        .globl  get_remainder

#
# Name:		puzzle_solver_main
#
# Description:	Loads input from the input_array and trys to solve the puzzle,
#               converts to Node Structure and tries to solve the puzzle. If the
#               puzzle can be solved, it is converted back to an array to be
#               printed.
#
# Arguments:	None
# Returns:	Solved board (solved_array)
#
puzzle_solver_main:
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

        jal     array_to_struct # Converts array to the Node Struct
                                # input_array -> temp_board

        jal     init_solve      # Initiates solving process
        jal     solve           # Jump and links to solve function

        jal     struct_to_array # Converts Node Struct to array
                                # temp_board -> solved_array
puzzle_solver_done:
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
# Name:		solve
#
# Description:	Tries to solve the puzzle
#
# Arguments:	None
# Returns:	None
#
solve:
        addi 	$sp, $sp, -8  	# allocate space for the return address
        sw 	$ra, 4($sp)	# store the ra on the stack
        sw      $s0, 0($sp)

solve_loop:
        jal     is_solved             # Checks if the puzzle is solved, 1 = True
        bne     $v0, $zero, solve_done  # If $v0 != 0; goto solve_done
        j       failed_solution         # Else: Jump to failed_solution

failed_solution:
        jal     guess_val               # Attempts a guess on the current cell
        j       solve_loop              # Jumps back to solve_loop

solve_done:
        lw 	$ra, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 8   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
#
# Name:		get_next_cell
#
# Description:	Gets the next cell to be looked at
#
# Arguments:	None
# Returns:	None
#
get_next_cell:
        addi 	$sp, $sp, -16  	# allocate space for the return address
        sw 	$ra, 12($sp)	# store the ra on the stack
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

        la      $s0, temp_board    # Loads addr of temp_board
        lw      $s1, 0($s0)        # Loads the curr index into $s1 (Input Value)
        addi    $s0, $s0, 4        # Adds 4 to move up the node struct
        lw      $s2, 0($s0)        # Loads the guessed value
        addi    $s0, $s0, -4       # Adds -4 to go back to starting position
        add     $t9, $zero, $zero  # $t9 = 0

get_next_cell_loop:
        beq     $s1, $s2, store_next_cell       # If Input Val == Guessed val
        li      $t0, 8                          # $t0 = 8
        add     $s0, $s0, $t0                   # Adds 8 to move to next cell
        li      $t0, 1                          # $t0 = 1
        add     $t9, $t9, $t0                   # Adds 1 to the counter

        lw      $s1, 0($s0)             # Loads the input val into $s1
        addi    $s0, $s0, 4             # Adds 4 to get the guess value
        lw      $s2, 0($s0)             # Loads the guess val for that cell
        addi    $s0, $s0, -4            # Goes back to beginning of cell
        j       get_next_cell_loop      # Jumps to get_next_cell_loop

store_next_cell:
        la      $s1, Pointer_to_Cell       # Loads addr of Pointer_to_Cell
        la      $s2, Curr_Cell          # Loads addr of Curr_Cell
        sw      $s0, 0($s1)             # Stores addr of the next cell
        sw      $t9, 0($s2)             # Stores the cell number

get_next_cell_done:
        lw 	$ra, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 16   	# deallocate space for the return address
        jr 	$ra		# return from main and exit


################################################################################
#
# Name:		guess_val
#
# Description:	Makes a guess in the cell
#
# Arguments:	None
# Returns:	None
#
guess_val:
        addi 	$sp, $sp, -16  	# allocate space for the return address
        sw 	$ra, 12($sp)	# store the ra on the stack
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

guess_val_loop:
        la      $s0, Pointer_to_Cell    # Loads addr of Pointer_to_Cell
        lw      $s0, 0($s0)             # Loads Pointer_to_Cell val into $s0
        addi    $s0, $s0, 4             # Adds 4 to get val
        lw      $s1, 0($s0)             # Stores val into $s1
        li      $t9, 4                  # $t9 = 4
        sub     $s0, $s0, $t9           # Subs 4 to go back to initial position

        addi    $t0, $zero, 9           # $t0 = 9
        bne     $s1, $t0, store_val     # If val != 9, store the val
        jal     reset_cell              # Else: reset the cell
        j       guess_val_loop          # and jump back to guess val loop

store_val:
        li      $t0, 1          # $t0 = 1
        add     $s1, $s1, $t0   # Adds 1 to val
        addi    $s0, $s0, 4     # Adds 4 to move up struct
        sw      $s1, 0($s0)     # Stores new pointer location addr
        addi    $s0, $s0, -4    # Resets to initial positon on the current cell
        la      $s6, Pointer_to_Cell    # Loads addr of Pointer_to_Cell
        sw      $s0, 0($s6)       # Stores addr of position into Pointer_to_Cell

        ### Start Validation Here ###
        jal     puzzle_validator       # Checks and Validates the puzzle

        bne     $v0, $zero, guess_val_done  # If the return val != 0; goto next
        j       guess_val_loop              # Else: Jump to guess_val_loop

guess_val_done:
        jal     get_next_cell   # Get the next cell

        lw 	$ra, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 16   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
#
# Name:		get_prev_cell
#
# Description:	Gets the previous cell of the current cell
#
# Arguments:	None
# Returns:	None
#
get_prev_cell:
        addi 	$sp, $sp, -20  	# allocate space for the return address
        sw 	$ra, 16($sp)	# store the ra on the stack
        sw 	$s3, 12($sp)
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

        la      $s0, Pointer_to_Cell       # Loads addr of Pointer_to_Cell
        lw      $s0, 0($s0)             # Loads the Pointer_to_Cell val into $s0
        li      $t9, 8                  # $t9 = 8
        sub     $s0, $s0, $t9           # Subs 8 from addr to get previous cell
        lw      $s1, 0($s0)             # Loads previous cell into $s1

        la      $s2, Curr_Cell          # Loads addr of Curr_Cell into $s2
        lw      $s2, 0($s2)             # Loads the current node value into $s2
        li      $t9, 1                  # $t9 = 1
        sub     $s2, $s2, $t9           # Subs 1 from Curr_Cell

        la      $s3, First_Cell         # Loads addr of First_Cell into $s3
        lw      $s3, 0($s3)             # Loads val of First_Cell into $s3
        sub     $s3, $s3, $t9           # Subs 1 from first node val
        bne     $s3, $s2, get_prev_cell_loop    # If $s3 != $s2, loop

                                                  # First_Node, then the puzzle
                                                  # is impossible to solve
puzzle_error:
        j       print_impossible_puzzle # Jumps to print_impossible_puzzle

get_prev_cell_loop:
        bne     $s1, $zero, go_back_a_cell      # If $s1 != 0, go back one cell

        add     $t0, $zero, $s0         # $t0 = $s0
        add     $t1, $zero, $s2         # $t1 = $s2

        j       store_prev_cell         # Jumps to store prev cell

go_back_a_cell:
        li      $t9, 8             # $t9 = 8
        sub     $s0, $s0, $t9      # Subs 8 from curr poisiton to go back a cell
        lw      $s1, 0($s0)        # Loads the prev cell into $s1

        li      $t9, 1                  # $t9 = 1
        sub     $s2, $s2, $t9           # Subs 1 from Curr_Cell val

        j       get_prev_cell_loop      # Jumps back to get_prev_cell_loop

store_prev_cell:
        la      $s0, Pointer_to_Cell    # Loads addr of Pointer_to_Cell
        la      $s1, Curr_Cell          # Loads addr of Curr_Cell
        sw      $t0, 0($s0)             # Stores $t0 into Pointer_to_Cell
        sw      $t1, 0($s1)             # Stores $t1 into Curr_Cell
        j       get_prev_cell_done      # Jumps to get_prev_cell_done

get_prev_cell_done:
        lw 	$ra, 16($sp)
        lw 	$s3, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 20   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
#
# Name:		puzzle_validator
#
# Description:	Validates the puzzle has no errors.
#
# Arguments:	None
# Returns:	Returns a solved puzzle or prints "Impossible Puzzle" if it
#               can't be solved.
#
puzzle_validator:
        addi 	$sp, $sp, -12  	# allocate space for the return address
        sw 	$ra, 8($sp)	# store the ra on the stack
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

        jal     validate_across_clue    # Validates acorss clues
        add     $s0, $zero, $v0         # $s0 = 0 or 1 from
                                                # validate_across_clue

        jal     validate_down_clue      # Validates down clues
        add     $a1, $zero, $v0         # $a1 = returns 0 or 1 from
                                                # validate_down_clue

        add     $a0, $s0, $zero         # Moves $s0 into $a0
        jal     validation_check        # Checks validation
        add     $s0, $zero, $v0         # $s0 = returns 0 or 1 from
                                                # validation_check

        jal     is_across_clue_duplicates # Validates if there are duplicates in
                                                # across clues
        add     $a1, $zero, $v0           # $a1 = returns 0 or 1 from
                                                # is_across_clue_duplicates

        add     $a0, $s0, $zero         # Moves $s0 into $a0
        jal     validation_check          # Checks validation
        add     $s0, $zero, $v0           # $s0 = returns 0 or 1 from
                                                # validation_check

        jal     is_down_clue_duplicates   # Validates if there are duplicates in
                                                # across clues
        add     $a1, $zero, $v0           # $a1 = returns 0 or 1 from
                                                # is_across_clue_duplicates

        add     $a0, $s0, $zero         # Moves $s0 into $a0
        jal     validation_check        # Checks validation
        add     $s0, $zero, $v0         # $s0 = returns 0 or 1 from
                                                # validation_check

        beq     $s0, $zero, failed_validation      # If $s0 == 0, failed
        bne     $s0, $zero, succeeded_validation   # If $s0 != 0, succeeded

validation_check:
        and     $v0, $a0, $a1   # $v0 = $a0 AND $a1
        jr      $ra             # Returns

failed_validation:
        add     $v0, $zero, $zero       # $v0 = 0
        j       puzzle_validator_done   # Jumps to puzzle_validator_done

succeeded_validation:
        addi    $v0, $zero, 1           # $v0 = 1

puzzle_validator_done:
        lw 	$ra, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 12   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
#
# Name:		validate_across_clue
#
# Description:	Subroutine of puzzle_validator. Validates if across clues are
#               valid.
#
# Arguments:	None
# Returns:	Returns 0 if not valid, 1 if valid
#
validate_across_clue:
        addi 	$sp, $sp, -24  	# allocate space for the return address
        sw 	$ra, 20($sp)	# store the ra on the stack
        sw 	$s4, 16($sp)
        sw 	$s3, 12($sp)
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

        la      $s0, Pointer_to_Cell    # Loads addr of Pointer_to_Cell into $s0
        la      $s1, Curr_Cell          # Loads addr of Curr_Cell into $s1

        lw      $s0, 0($s0)             # Dereferences Pointer_to_Cell
        lw      $s1, 0($s1)             # Loads Curr_Cell val into $s1
        add     $s2, $zero, $zero       # $s2 = 0 (Current Guessed Val)

validate_across_clue_loop:
        lw      $s3, 0($s0)     # Loads Input val into $s3
        addi    $s0, $s0, 4     # Adds 4 to move up struct to get guessed val
        lw      $s4, 0($s0)     # Loads Guessed val into $s4
        addi    $s0, $s0, -4    # Adds -4 to go back to original position
        add     $s2, $s2, $s4   # Adds up the guessed values

        addi    $s0, $s0, -8    # Adds -8 to get prev across clue cell
        lw      $a0, 0($s0)     # Loads prev cell input val into $a0
        addi    $s0, $s0, 8     # Adds 8 to go back to original position
        jal     is_zero_cell    # Checks if its a clue cell or a empty cell

        bne     $v0, $zero, validate_across_clue_init_done # If $v0 != 0

        addi    $t9, $zero, 8              # $t9 = 8
        sub     $s0, $s0, $t9              # Subs 8 to go back a cell
        j       validate_across_clue_loop  # Jumps back to
                                                # validate_across_clue_loop

validate_across_clue_init_done:
        jal     is_final_across_cell    # Checks if curr cell is the last cell
                                                # in curr across clue
        add     $s4, $v0, $zero         # $s4 = $v0 (returned value)

        addi    $s0, $s0, -8            # Adds -8 to $s0 to get prev cell
        lw      $a0, 0($s0)             # Loads input val into $a0
        addi    $s0, $s0, 8             # Adds 8 to go back to original positon
        li      $a1, 100                # Loads 100 into $a1
        jal     get_quotient            # Gets quotient ($v0 = $a0 / $a1)
        add     $s3, $zero, $v0         # $s3 = quotient

        beq     $s4, $zero, validate_across_clue_finish_init_done
        bne     $s4, $zero, is_correct_across_sum       # If $s4 != 0

validate_across_clue_finish_init_done:
        slt     $s2, $s2, $s3                           # If $s2 < $s3
        bne     $s2, $zero, validate_across_clue_true   # If $s2 != 0, true
        beq     $s2, $zero, validate_across_clue_false  # If $s2 == 0, false

#############################
is_final_across_cell:
        addi 	$sp, $sp, -24  	# allocate space for the return address
        sw 	$ra, 20($sp)	# store the ra on the stack
        sw 	$s4, 16($sp)
        sw 	$s3, 12($sp)
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

        la      $s0, Pointer_to_Cell    # Loads addr of Pointer_to_Cell
        lw      $s0, 0($s0)             # Dereferences Pointer_to_Cell

        lw      $s1, 0($s0)             # Loads curr cell input val into $s1
        addi    $s0, $s0, 8             # Adds 8 to get next cell
        lw      $s2, 0($s0)             # Loads next cells input val into $s2
        addi    $s0, $s0, -8            # Adds -8 to go back to original positon

        beq     $s2, $zero, set_zero    # If $s2 == 0, set_zero
        bne     $s2, $zero, set_one     # If $s2 != 0, set_one

set_zero:
        add     $s4, $zero, $zero               # Sets $s4 = 0
        j       is_final_across_cell_init_done  # Jumps to
                                                # is_final_across_cell_init_done

set_one:
        addi    $s4, $zero, 1   # Sets $s4 = 1

is_final_across_cell_init_done:
        la      $s3, Curr_Cell  # Loads addr of Curr_Cell
        lw      $a0, 0($s3)     # Loads Curr_Cell input val into $a0

        add     $a1, $zero, $zero       # Sets $a1 to 0 for right barrier check
        jal     is_barrier              # Checks if there is a barrier
        or      $v0, $s4, $v0           # $v0 = $s4 OR $v0

is_final_across_cell_done:
        lw 	$ra, 20($sp)
        lw 	$s4, 16($sp)
        lw 	$s3, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 24   	# deallocate space for the return address
        jr 	$ra		# return from main and exit
#############################

is_correct_across_sum:
        bne     $s2, $s3, validate_across_clue_false    # If $s2 != $s3, false
        beq     $s2, $s3, validate_across_clue_true     # If $s2 == $s3, true

validate_across_clue_false:
        add     $v0, $zero, $zero               # Returns false
        j       validate_across_clue_done       # Jumps to
                                                   # validate_across_clue_done

validate_across_clue_true:
        addi    $v0, $zero, 1   # Returns true

validate_across_clue_done:
        lw 	$ra, 20($sp)
        lw 	$s4, 16($sp)
        lw 	$s3, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 24   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
#
# Name:		validate_down_clue
#
# Description:	Subroutine of puzzle_validator. Validates if down clues are
#               valid.
#
# Arguments:	None
# Returns:	Returns 0 if not valid, 1 if valid
#
validate_down_clue:
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

        la      $s0, Pointer_to_Cell    # Loads addr of Pointer_to_Cell
        la      $s1, Curr_Cell          # Loads addr of Curr_Cell

        lw      $s0, 0($s0)             # Dereferences Pointer_to_Cell
        lw      $s1, 0($s1)             # Loads curr cell val into $s1
        add     $s2, $zero, $zero       # $s2 = 0 (Current Guessed Val)

validate_down_clue_loop:
        lw      $s3, 0($s0)     # Loads cell input val
        addi    $s0, $s0, 4     # Adds 4 to move up structure to get guess val
        lw      $s4, 0($s0)     # Loads guess val into $s4
        addi    $s0, $s0, -4    # Adds -4 to go back to original positon
        add     $s2, $s2, $s4   # Adds up the guessed values

        la      $t8, board_size # Loads addr of board_size
        lw      $t8, 0($t8)     # Loads board_size val into $t8
        addi    $t9, $zero, 8   # $t9 = 8
        mul     $t8, $t8, $t9   # board_size * 8 (4 Bytes a word, 2 words)

        add     $s5, $s0, $zero # $s5 = $s0
        sub     $s5, $s5, $t8   # Sub $t8 from $s5 to get prev down cell
        lw      $s5, 0($s5)     # Loads val into $s5
        add     $a0, $s5, $zero # $a0 = $s5
        jal     is_zero_cell    # Check if prev cell is a clue or not

        add     $s5, $v0, $zero # $s5 = $v0
        beq     $s5, $zero, go_to_next_down_clue_cell   # If $s5 == 0
        bne     $s5, $zero, validate_down_clue_init_done  # If $s5 != 0

validate_down_clue_init_done:
        jal     is_final_down_cell      # Check if curr curr cell is final cell
                                                # in curr down clue
        add     $t2, $v0, $zero         # $t2 = $v0

        la      $t8, board_size         # Loads addr of board_size into $t8
        lw      $t8, 0($t8)             # Loads board_size val into $t8
        addi    $t9, $zero, 8           # $t9 = 8
        mul     $t8, $t8, $t9           # board_size * 8

        add     $s6, $t8, $zero         # $s6 = $t8
        add     $s7, $s0, $zero         # $s7 = $s0
        sub     $s7, $s7, $s6           # Sub $s6 from $s7 to get prev down cell

        lw      $a0, 0($s7)             # Loads prev down cell into $a0
        addi    $a1, $zero, 100         # $a1 = 100
        jal     get_remainder           # returns the remainder
        add     $t4, $v0, $zero         # $t4 = $v0

        bne     $t2, $zero, is_correct_down_sum # If $t2 != 0
        slt     $s2, $s2, $t4                   # If $s2 < $t4
        bne     $s2, $zero, validate_down_clue_true     # If $s2 != 0, true
        beq     $s2, $zero, validate_down_clue_false    # If $s2 == 0, false

go_to_next_down_clue_cell:
        sub     $s0, $s0, $t8           # Sub $t8 from $s0 to get prev down cell
        j       validate_down_clue_loop # Jumps back to validate_down_clue_loop

#############################
is_final_down_cell:
        addi 	$sp, $sp, -16  	# allocate space for the return address
        sw 	$ra, 12($sp)	# store the ra on the stack
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

        la      $s0, Pointer_to_Cell    # Loads addr of Pointer_to_Cell
        la      $s1, board_size         # Loads addr of board_size
        lw      $s0, 0($s0)             # Dereferences Pointer_to_Cell into $s0
        lw      $s1, 0($s1)             # Loads board_size val into $s1

        addi    $t9, $zero, 8         # # $t9 = 8
        mul     $s1, $s1, $t9         # board_size * 8 (4 Bytes a word, 2 words)
        add     $s0, $s0, $s1         # Subs $s1 from $s0 to get prev down cell
        lw      $s0, 0($s0)           # Loads curr Pointer_to_Cell into $s0

        beq     $s0, $zero, set_zero_3  # If $s0 == 0, set $s2 = 0
        bne     $s0, $zero, set_one_3   # If $s0 != 0, set $s2 = 1

set_zero_3:
        add     $s2, $zero, $zero         # $s2 = 0
        j       is_final_down_cell_init_done
                                          # Jump to is_final_down_cell_init_done

set_one_3:
        addi    $s2, $zero, 1             # $s2 = 1

is_final_down_cell_init_done:
        la      $s1, Curr_Cell  # Loads addr of Curr_Cell into $s1
        lw      $a0, 0($s1)     # Loads Curr_Cell val into $a0

        addi    $a1, $zero, 1   # $a1 = 1 (To check for bottom barrier)
        jal     is_barrier      # Check if there is a barrier
        or      $v0, $s2, $v0   # $v0 = $s2 OR $v0

is_final_down_cell_done:
        lw 	$ra, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 16  	# deallocate space for the return address
        jr 	$ra		# return from main and exit
#############################

is_correct_down_sum:
        bne     $s2, $t4, validate_down_clue_false # If $s2 == $t4, return false
        beq     $s2, $t4, validate_down_clue_true  # If $s2 != $t4, return true

validate_down_clue_false:
        add     $v0, $zero, $zero              # $v0 = 0
        j       validate_down_clue_done        # Jump to validate_down_clue_done

validate_down_clue_true:
        addi    $v0, $zero, 1                  # $v1 = 1

validate_down_clue_done:
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
# Name:		is_across_clue_duplicates
#
# Description:	Subroutine of puzzle_validator. Validates if there are
#               duplicates in the puzzles across clues valid.
#
# Arguments:	None
# Returns:	Returns 0 if not valid, 1 if valid
#
is_across_clue_duplicates:
        addi 	$sp, $sp, -24  	# allocate space for the return address
        sw 	$ra, 20($sp)	# store the ra on the stack
        sw 	$s4, 16($sp)
        sw 	$s3, 12($sp)
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

        la      $s0, Pointer_to_Cell    # Loads addr of Pointer_to_Cell
        lw      $s1, 0($s0)             # Dereferences Pointer_to_Cell into $s1
        lw      $s2, 0($s0)             # Dereferences Pointer_to_Cell into $s2

is_across_clue_duplicates_loop1:
        lw      $s3, 0($s1)             # Loads curr cell input val into $s3
        add     $s2, $zero, $s1         # Stores curr addr of $s1 into $s2
        addi    $t9, $zero, 8           # $t9 = 8
        sub     $s2, $s2, $t9           # Adds up the guessed values

        add     $a0, $s3, $zero         # $a0 = curr cell input val
        jal     is_zero_cell            # Checks if clue cell or empty cell

        addi    $s1, $s1, 4             # Adds 4 to $s1 to get guess val
        lw      $s3, 0($s1)             # Loads guess val into $s3
        addi    $s1, $s1, -4            # Adds -4 to go back to original positon
        bne     $v0, $zero, is_across_clue_duplicates_true      # If $v0 != 0
        beq     $v0, $zero, is_across_clue_duplicates_loop2     # If $v0 == 0

is_across_clue_duplicates_loop2:
        lw      $s4, 0($s2)             # Loads next cell input val
        add     $a0, $zero, $s4         # Stores into $a0
        jal     is_zero_cell            # Checks if next cell is a clue cell
        add     $t9, $zero, $v0
        bne     $t9, $zero, is_across_clue_duplicates_next      # If $v0 != 0

        addi    $s2, $s2, 4             # Adds 4 to get next cell guess val
        lw      $s4, 0($s2)             # Loads next cell guess val into $s4
        addi    $s2, $s2, -4            # Adds -4 to go back to original positon
        beq     $s3, $s4, is_across_clue_duplicates_false   # If $s3 == $s4

        addi    $t9, $zero, 8           # $t9 = 8
        sub     $s2, $s2, $t9           # Subs 8 from $s2
        j       is_across_clue_duplicates_loop2
                                # Jumps to is_across_clue_duplicates_loop2

is_across_clue_duplicates_next:
        addi    $t9, $zero, 8   # $t9 = 8
        sub     $s1, $s1, $t9   # Subs 8 from $s1
        j       is_across_clue_duplicates_loop1
                                      # Jumps to is_across_clue_duplicates_loop1

is_across_clue_duplicates_true:
        addi    $v0, $zero, 1          # Returns True
        j       is_across_clue_duplicates_done
                                       # Jumps to is_across_clue_duplicates_done

is_across_clue_duplicates_false:
        add     $v0, $zero, $zero       # Returns False

is_across_clue_duplicates_done:
        lw 	$ra, 20($sp)
        lw 	$s4, 16($sp)
        lw 	$s3, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 24   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
#
# Name:		is_down_clue_duplicates
#
# Description:	Subroutine of puzzle_validator. Validates if there are
#               duplicates in the puzzles down clues valid.
#
# Arguments:	None
# Returns:	Returns 0 if not valid, 1 if valid
#
is_down_clue_duplicates:
        addi 	$sp, $sp, -24  	# allocate space for the return address
        sw 	$ra, 20($sp)	# store the ra on the stack
        sw 	$s4, 16($sp)
        sw 	$s3, 12($sp)
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

        la      $s0, Pointer_to_Cell    # Loads addr of Pointer_to_Cell
        la      $s1, board_size         # Loads addr of board_size
        lw      $s0, 0($s0)             # Dereferences Pointer_to_Cell into $s0
        lw      $s1, 0($s1)             # Loads board size val into $s1

        addi    $t9, $zero, -8          # $t9 = -8
        mul     $s1, $s1, $t9           # $s1 = $s1 * -8 to get prev down cell

is_down_clue_duplicates_loop1:
        lw      $s2, 0($s0)             # Loads curr cell input val into $s2
        add     $s3, $zero, $s0         # Stores $s0 into $s3

        add     $s3, $s3, $s1           # Adds the board_size to $s3
        add     $a0, $zero, $s2         # $a0 = curr cell input val
        jal     is_zero_cell            # Checks if the cell is a clue

        add     $s0, $s0, 4        # Adds 4 to get next cell guess val
        lw      $s2, 0($s0)        # Loads guess val into $s2
        addi    $s0, $s0, -4       # Adds -4 to go back to the original position
        bne     $v0, $zero, is_down_clue_duplicates_true     # If $v0 != 0, true
        beq     $v0, $zero, is_down_clue_duplicates_loop2    # If $v0 == 0

is_down_clue_duplicates_loop2:
        lw      $s4, 0($s3)             # Loads next cell in down clue
        add     $a0, $zero, $s4         # $a0 = next cell
        jal     is_zero_cell            # Checks if cell is a clue
        add     $t9, $zero, $v0

        bne     $t9, $zero, is_down_clue_duplicates_next   # If $v0 != 0

        addi    $s3, $s3, 4             # Adds 4 to get guess val
        lw      $s4, 0($s3)             # Loads guess val into $s4
        addi    $s3, $s3, -4
        beq     $s2, $s4, is_down_clue_duplicates_false # If $s2 == $s4, false
        add     $s4, $s4, $s1           # Adds $s1 to get prev cell in down clue

is_down_clue_duplicates_next:
        add     $s0, $s0, $s1           # Adds $s1 to get next down clue cell
        j       is_down_clue_duplicates_loop1
                                        # Jumps to is_down_clue_duplicates_loop1

is_down_clue_duplicates_true:
        addi    $v0, $zero, 1           # $v0 = 1 (True)
        j       is_down_clue_duplicates_done
                                        # Jump to is_down_clue_duplicates_done

is_down_clue_duplicates_false:
        add     $v0, $zero, $zero       # $v0 = 0 (False)

is_down_clue_duplicates_done:
        lw 	$ra, 20($sp)
        lw 	$s4, 16($sp)
        lw 	$s3, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 24   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
#
# Name:		is_zero_cell
#
# Description:	Checks to see if the given cell is a clue block or not.
#
# Arguments:	a0         Given cell
# Returns:	Returns 0 if not valid, 1 if valid
#
is_zero_cell:
        bne     $a0, $zero, is_zero_cell_true   # If $a0 != 0, true
        beq     $a0, $zero, is_zero_cell_false  # If $a0 == 0, false

is_zero_cell_false:
        add    $v0, $zero, $zero        # $v0 = 0, returns false
        j      is_zero_cell_done        # Jumps to is_zero_cell_done

is_zero_cell_true:
        addi    $v0, $zero, 1           # $v0 = 1, returns true

is_zero_cell_done:
        jr 	$ra		# return back to function

###########################################################################
################################################################################
#
# Name:		is_barrier
#
# Description:	Subroutine of puzzle_validator. Checks to see if the curr cell
#               is up against a barrier.
#
# Arguments:	a0         curr cell
#               a1         0 (right barrier) or 1 (bottom barrier)
# Returns:	Returns 0 if not valid, 1 if valid
#
is_barrier:
        addi 	$sp, $sp, -24  	# allocate space for the return address
        sw 	$ra, 20($sp)	# store the ra on the stack
        sw 	$s4, 16($sp)
        sw 	$s3, 12($sp)
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)


        beq     $a1, $zero, right_barrier       # If $a1 == 0, right_barrier
        bne     $a1, $zero, bottom_barrier      # If $a1 != 0, bottom_barrier

right_barrier:
        la      $s0, Curr_Cell          # Loads addr Curr_Cell
        la      $s1, board_size         # Loads addr of board_size
        lw      $s0, 0($s0)             # Loads cell into $s0
        lw      $s1, 0($s1)             # Loads board size into $s1
        add     $s2, $zero, $s1         # $s2 = $s1

        add     $a0, $zero, $s0         # $a0 = $s0
        add     $a1, $zero, $s1         # $a1 = $s1
        jal     get_remainder           # Gets the remainder
        add     $s3, $zero, $v0         # $s3 = $v0

        addi    $t9, $zero, 1           # $t9 = 1
        sub     $s2, $s2, $t9           # Sub 1 from $s2
        beq     $s3, $s2, set_one_2     # If $s3 == $s2, return true
        bne     $s3, $s2, set_zero_2    # If $s3 != $s2, return false

bottom_barrier:
        la      $s0, board_size            # Loads addr of board_size
        la      $s1, board_size_doubled    # Loads addr of board_size_doubled
        lw      $s0, 0($s0)                # Loads board_size into $s0
        lw      $s1, 0($s1)                # Loads board_size_doubled into $s1
        add     $s2, $a0, $zero            # $s2 = $a0

        sub     $s1, $s1, $s0              # Subs $s0 from $s1
        slt     $t6, $s2, $s1              # If $s2 < $s1, set $t6 = 1
        bne     $t6, $zero, set_zero_2     # If $t6 != 0, return false
        beq     $t6, $zero, set_one_2      # If $t6 == 0, return true

set_zero_2:
        add     $v0, $zero, $zero       # $v0 = 0
        j       is_barrier_done         # Jumps to is_barrier_done

set_one_2:
        addi    $v0, $zero, 1           # $v0 = 1

is_barrier_done:
        lw 	$ra, 20($sp)
        lw 	$s4, 16($sp)
        lw 	$s3, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 24   	# deallocate space for the return address
        jr 	$ra		# return from main and exit
