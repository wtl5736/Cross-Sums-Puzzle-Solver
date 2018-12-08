#
# FILE:                 cross_sums_helper.asm
# AUTHOR:               W. Lee
# CREATION DATE:        October 26, 2018
# LAST MODIFIED:        November 26, 2018
#
#
# DESCRIPTION:
#       This program contains helper functions for main program
#
# ARGUMENTS:
#       None
#
# INPUT:
#       An array to either be converted from an array to a struct or
#       a struct to an array.
#
# OUTPUT:
#       Stores array to struct into temp_board; or
#       Stores struct to array into solved_array
#

        .text
        .align  2

        # Global Variables
        .globl  board_size_doubled
        .globl  input_array
        .globl  solved_array
        .globl  temp_board
        .globl  Pointer_to_Cell
        .globl  Curr_Cell
        .globl  First_Cell


        # Function to take array and put it into the structure
        .globl  array_to_struct
        .globl  struct_to_array
        .globl  is_solved
        .globl  init_temp_registers
        .globl  get_prev_cell
        .globl  reset_cell
        .globl  get_next_cell
        .globl  get_quotient
        .globl  get_remainder

################################################################################
#
# Name:		array_to_struct
#
# Description:	Converts an array to a node structure
#
# Arguments:	input_array
# Returns:	temp_board
#
array_to_struct:
        addi 	$sp, $sp, -16  	# allocate space for the return address
        sw 	$ra, 12($sp)	# store the ra on the stack
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

        la      $s0, input_array        # Loads addr of input_array
        la      $s1, temp_board         # Loads addr of temp_board
        la      $s2, board_size_doubled # Loads addr of board_size_doubled

        li      $t8, 0                  # Loads imm val (counter)
        lw      $t9, 0($s2)             # Loads board_size_doubled val
        add     $t9, $t9, $t9           # $t9 = board_size_doubled * 2

array_to_struct_loop:
        beq     $t8, $t9, array_to_struct_done  # if counter == $t9
        lw      $t0, 0($s0)     # Loads curr index of input_array


        sw      $t0, 0($s1)     # Stores the val into temp_board
        #li      $t1, 1
        #sw      $t1, 4($s1)   # Inits guess val with a 0
        sw      $zero, 4($s1)   # Inits guess val with a 0

        addi    $s0, $s0, 4     # Adds 4 to $s0 to move up input_array
        addi    $s1, $s1, 8     # Adds 4 to $s1 to move up temp_board
        addi    $t8, $t8, 2     # Adds 2 to counter
        j       array_to_struct_loop    # Jumps back to loop

array_to_struct_done:
        lw 	$ra, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 16   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
#
# Name:		is_solved
#
# Description:	Checks if board is solved
#
# Arguments:	temp_board
# Returns:	0 if not solved and 1 if board is solved
#
is_solved:
        la      $t0, temp_board               # Loads addr of temp_board
        la      $t9, board_size_doubled       # Loads addr of board_size_doubled
        lw      $t9, 0($t9)                   # Loads board_size_doubled

is_solved_loop:
        beq     $t9, $zero, is_solved_verified  # if counter == 0
        lw      $t1, 0($t0)                     # Loads Input Value
        lw      $t2, 4($t0)                     # Loads Guess Value

        beq     $t1, $zero, check_cell      # If input val == 0, goto check_cell
        bne     $t1, $zero, next_cell       # If input val != 0, goto next_cell

next_cell:
        addi    $t9, $t9, -1                # Add -1 to counter
        addi    $t0, $t0, 8                 # Adds 8 to move to next cell
        j       is_solved_loop              # Jumps back to is_solved_loop

check_cell:
        beq     $t2, $zero, is_not_solved   # If guess value == 0
        j       next_cell                   # Jumps to next_cell

is_solved_verified:
        li      $v0, 1          # Loads $v0 = 1, is_solved = True
        j       is_solved_done  # Jumps to is_solved_done

is_not_solved:
        add     $v0, $zero, $zero       # Loads $v0 = 0, is_solved = False

is_solved_done:
        jr 	$ra		# Returns to solve_board_loop

################################################################################
#
# Name:		init_solve
#
# Description:	Initiates values before starting the solve function
#
# Arguments:	None
# Returns:	None
#
init_solve:
        addi 	$sp, $sp, -4  	# allocate space for the return address
        sw 	$ra, 0($sp)	# store the ra on the stack

        jal     init_temp_registers     # Sets all of the temp registers to zero
        jal     get_next_cell           # Gets the "first" cell

        la      $t0, Curr_Cell          # Loads the addr of the current node
        lw      $t0, 0($t0)             # Loads the current node into $t0

        la      $t1, First_Cell         # Loads the addr of the first node
        sw      $t0, 0($t1)             # Stores the current node into
                                                # First_Cell

init_solve_done:
        lw 	$ra, 0($sp)
        addi 	$sp, $sp, 4   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
#
# Name:		reset_cell
#
# Description:	Resets the cell to 0
#
# Arguments:	None
# Returns:	None
#
reset_cell:
        addi 	$sp, $sp, -4  	# allocate space for the return address
        sw 	$ra, 0($sp)	# store the ra on the stack

        la      $t2, Pointer_to_Cell    # Loads the addr of the Pointer_to_Cell
        lw      $t2, 0($t2)             # Stores the val into $t2
        addi    $t2, $t2, 4             # Adds 4 to move up struct
        add     $t3, $zero, $zero       # $t3 = 0
        sw      $t3, 0($t2)             # Resets guess val to zero
        addi    $t2, $t2, -4            # Resets position
        la      $t4, Pointer_to_Cell       # Loads addr of Pointer_to_Cell
        sw      $t2, 0($t4)             # Stores the reset cell position
        jal     get_prev_cell           # Gets the previous cell

reset_cell_done:
        lw 	$ra, 0($sp)
        addi 	$sp, $sp, 4   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
#
# Name:		struct_to_array
#
# Description:	Converts node structure to an array
#
# Arguments:	temp_board
# Returns:	solved_array
#
struct_to_array:
        addi 	$sp, $sp, -16  	# allocate space for the return address
        sw 	$ra, 12($sp)	# store the ra on the stack
        sw 	$s2, 8($sp)
        sw 	$s1, 4($sp)
        sw 	$s0, 0($sp)

        la      $s0, temp_board         # Loads addr of temp_board
        la      $s1, solved_array       # Loads addr of solved_array
        la      $s2, board_size_doubled # Loads addr of board_size_doubled

        li      $t8, 0          # Loads imm val (counter)
        lw      $t9, 0($s2)     # Loads board_size_doubled val
        add     $t9, $t9, $t9   # $t9 = board_size_doubled * 2

struct_to_array_loop:
        beq     $t8, $t9, struct_to_array_done  # If counter == $t9
        lw      $t0, 0($s0)     # Curr index of temp_board

        beq     $t0, $zero, store_guessed_val   # If input_array val == 0
                                                # store the guessed val

        sw      $t0, 0($s1)     # Store the val into solved_array

        addi    $s0, $s0, 8     # Adds 8 to $s0 to move up two indexes
                                        # in temp_board
        addi    $s1, $s1, 4     # Adds 4 to $s1 to move up the solved_array
        addi    $t8, $t8, 2     # Adds 2 to the counter, since only the
                                        # init val was stored and not the
                                        # guessed val

        j       struct_to_array_loop    # Jumps back to loop

store_guessed_val:
        addi    $s0, $s0, 4     # Adds 4 to $s0 to get the guessed val
        lw      $t0, 0($s0)     # Loads the guessed val
        sw      $t0, 0($s1)     # Stores the guessed val into solved_array

        addi    $s0, $s0, 4     # Adds 4 to $s0 to move up temp_board
        addi    $s1, $s1, 4     # Adds 4 to $s1 to move up solved_array
        addi    $t8, $t8, 2     # Adds 2 to the counter
        j       struct_to_array_loop    # Jumps back to loop

struct_to_array_done:
        lw 	$ra, 12($sp)
        lw 	$s2, 8($sp)
        lw 	$s1, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 16   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
#
# Name:		init_temp_registers
#
# Description:	Initiates temporary registers to zero
#
# Arguments:	None
# Returns:	None
#
init_temp_registers:
        add     $t0, $zero, $zero
        add     $t1, $zero, $zero
        add     $t2, $zero, $zero
        add     $t3, $zero, $zero
        add     $t4, $zero, $zero
        add     $t5, $zero, $zero
        add     $t6, $zero, $zero
        add     $t7, $zero, $zero
        add     $t8, $zero, $zero
        add     $t9, $zero, $zero
        jr      $ra

################################################################################
#
# Name:		get_quotient
#
# Description:	Get the quotient of two numbers
#
# Arguments:	$a0         Numerator
#               $a1         Denomenator
#
# Returns:	$v0         Quotient
#
get_quotient:
        div     $a0, $a1
        mflo    $v0             # Quotient
        jr      $ra

################################################################################
#
# Name:		get_remainder
#
# Description:	Get the remainder of two numbers
#
# Arguments:	$a0         Numerator
#               $a1         Denomenator
#
# Returns:	$v0         Remainder
#
get_remainder:
        div     $a0, $a1
        mfhi    $v0             # Remainder
        jr      $ra
