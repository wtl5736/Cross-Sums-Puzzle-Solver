#
# Makefile for CompOrg Project 1 - Cross Sums
#

#
# Location of the processing programs
#
RASM  = /home/fac/wrc/bin/rasm
RLINK = /home/fac/wrc/bin/rlink
RSIM  = /home/fac/wrc/bin/rsim

#
# Suffixes to be used or created
#
.SUFFIXES:	.asm .obj .lst .out

#
# Object files to be created
#
OBJECTS = cross_sums.obj cross_sums_algorithm.obj cross_sums_printer.obj cross_sums_helper.obj cross_sums_errors.obj

#
# Transformation rule: .asm into .obj
#
.asm.obj:
	$(RASM) -l $*.asm > $*.lst

#
# Transformation rule: .obj into .out
#
.obj.out:
	$(RLINK) -o $*.out $*.obj

#
# Main target
#
cross_sum.out:	$(OBJECTS)
	$(RLINK) -m -o cross_sums.out $(OBJECTS) > cross_sums.map

run:	cross_sums.out
	$(RSIM) cross_sums.out
