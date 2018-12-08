#
# FILE:                 cross_sums_printer.asm
# AUTHOR:               W. Lee
# CREATION DATE:        October 25, 2018
# LAST MODIFIED:        November 26, 2018
#
#
# DESCRIPTION:
#       This program contains all of the necessary code to print out the initia;
#       cross sum board and solution.
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

# CONSTANTS
#
# syscall codes
PRINT_INT = 	1
PRINT_STRING = 	4
READ_INT = 	5

        .data
        .align  0

main_banner:
        .ascii  "******************\n"
        .ascii  "**  CROSS SUMS  **\n"
        .asciiz "******************\n\n"

init_banner:
        .asciiz "Initial Puzzle\n\n"

final_banner:
        .asciiz "Final Puzzle\n\n"

top_bot_cell:
        .asciiz   "+---+"

top_bot_cell_cont:
        .asciiz   "---+"

top_bot_cell_end:
        .asciiz   "---+\n"

newline:
        .asciiz   "\n"

blocking_clue_top:
        .asciiz   "\\##"

blocking_clue_mid:
        .asciiz   "#\\#"

blocking_clue_bot:
        .asciiz   "##\\"

across_clue_one:
        .asciiz   "\\#"

back_slash:
        .asciiz   "\\"

hashtag:
        .asciiz   "#"

divider:
        .asciiz   "|"

single_space:
        .asciiz   " "

triple_space:
        .asciiz   "   "

        .text
        .align  2

        # Characters/Strings to print
        .globl  blocking_clue_top
        .globl  blocking_clue_mid
        .globl  blocking_clue_bot
        .globl  across_clue_one
        .globl  back_slash
        .globl  hashtag
        .globl  single_space
        .globl  triple_space

        # Functions to print
        .globl  print_banner
        .globl  print_init_banner
        .globl  print_final_banner
        .globl  print_newline
        .globl  print_single_space
        .globl  print_divider
        .globl  print_border

################################################################################
#
# Name:		print_banner
#
# Description:	Prints the banner
#
# Arguments:	None
# Returns:	None
#
print_banner:
        li      $v0, PRINT_STRING       # Loads const to print string
        la      $a0, main_banner        # Loads the main_banner
        syscall
        jr      $ra

################################################################################
#
# Name:		print_init_banner
#
# Description:	Prints the initial board banner
#
# Arguments:	None
# Returns:	None
#
print_init_banner:
        li      $v0, PRINT_STRING       # Loads const to print string
        la      $a0, init_banner        # Loads init banner
        syscall
        jr      $ra

################################################################################
#
# Name:		print_final_banner
#
# Description:	Prints the final puzzel banner
#
# Arguments:	None
# Returns:	None
#
print_final_banner:
        li      $v0, PRINT_STRING       # Loads const to print string
        la      $a0, final_banner       # Loads the final banner
        syscall
        jr      $ra

################################################################################
#
# Name:		print_newline
#
# Description:	Prints a newline
#
# Arguments:	None
# Returns:	None
#
print_newline:
        li      $v0, PRINT_STRING       # Loads const to print string
        la      $a0, newline            # Loads newline
        syscall
        jr      $ra

################################################################################
#
# Name:		print_single_space
#
# Description:	Prints a single space
#
# Arguments:	None
# Returns:	None
#
print_single_space:
        li      $v0, PRINT_STRING       # Loads const to print string
        la      $a0, single_space       # Loads single_space
        syscall
        jr      $ra

################################################################################
#
# Name:		print_divider
#
# Description:	Prints a divider -> |
#
# Arguments:	None
# Returns:	None
#
print_divider:
        li      $v0, PRINT_STRING       # Loads const to print string
        la      $a0, divider            # Loads divider
        syscall
        jr      $ra

################################################################################
#
# Name:		print_boarder
#
# Description:	Prints the boarder of the board
#
# Arguments:	None
# Returns:	None
#
print_border:
        addi 	$sp, $sp, -8  	# allocate space for the return address
        sw 	$ra, 4($sp)	# store the ra on the stack
        sw 	$s0, 0($sp)

        add     $s0, $zero, $a0         # $s0 = $a0
        addi    $s0, $s0, -1            # Subs 1 from counter
        li      $v0, PRINT_STRING       # Loads const to print string
        la      $a0, top_bot_cell       # Loads top_bot_cell
        syscall

pb_loop:
        addi    $s0, $s0, -1            # Subs 1 from counter
        beq     $s0, $zero, pb_done     # If $s0 == 0, done
        li      $v0, PRINT_STRING       # Loads const to print string
        la      $a0, top_bot_cell_cont  # Loads top_bot_cell_cont
        syscall

        j       pb_loop                 # Goes back to loop

pb_done:
        li      $v0, PRINT_STRING       # Loads const to print string
        la      $a0, top_bot_cell_end   # Loads top_bot_cell_end
        syscall

        lw 	$ra, 4($sp)
        lw 	$s0, 0($sp)
        addi 	$sp, $sp, 8   	# deallocate space for the return address
        jr 	$ra		# return from main and exit

################################################################################
