#####################################################################################
#
#	Name:			Barros, Mark
#	Course:			CS2640 - Computer Organization and Assembly Programming
#	Description:	This program prompts the user for the coefficients a, b, 
#					and c of a quadratic equation ax^2 + bx + c = 0 and prints
#					out the solutions.
#
#####################################################################################
#
				.data
					
header:			.asciiz			"Quadratic Equation Solver by M. Barros.\n\n"
a_prompt:		.asciiz			"Enter value for a? "
b_prompt:		.asciiz			"Enter value for b? "
c_prompt:		.asciiz			"Enter value for c? "
not_quad:		.asciiz			"Not a quadratic equation.\n"
imagine:		.asciiz			"Roots are imaginary.\n"
sol_x:			.asciiz			"x = "
sol_x1:			.asciiz			"x1 = "				
sol_x2:			.asciiz			"x2 = "

				.text
					
main:

	# output header to console
	la			$a0, header
	li			$v0, 4
	syscall
		
	# prompt for a value
	la			$a0, a_prompt
	li			$v0, 4
	syscall
	li			$v0, 6
	syscall
	mov.s		$f12, $f0
				
	# prompt for b value
	la			$a0, b_prompt
	li			$v0, 4
	syscall
	li			$v0, 6
	syscall
	mov.s		$f13, $f0
		
	# prompt for c value
	la			$a0, c_prompt
	li			$v0, 4
	syscall
	li			$v0, 6
	syscall
	mov.s		$f14, $f0
		
	# output a new line
	li			$a0, '\n'
	li			$v0, 11
	syscall
		
	# call solve equation
	jal			solveque

	# switch for output answer to console		
	beqz		$v0, not_quadratic
	li			$t0, 1						
	beq			$v0, $t0, linear
	li			$t0, -1
	beq			$v0, $t0, imaginary
	li			$t0, 2
	beq			$v0, $t0, quadratic
		
	# output if not a quadratic equation
not_quadratic:

	la			$a0, not_quad
	li			$v0, 4
	syscall
	b			end
	
	# output if a linear equation
linear:

	la			$a0, sol_x
	li			$v0, 4
	syscall
	mov.s		$f12, $f0
	li			$v0, 2
	syscall
	
	li			$a0, '\n'
	li			$v0, 11
	syscall
	
	b			end
	
	# output if roots are imaginary
imaginary:

	la			$a0, imagine
	li			$v0, 4
	syscall
	b			end
	
	# output if roots are quadratic
quadratic:

	la			$a0, sol_x1
	li			$v0, 4
	syscall
	mov.s		$f12, $f0
	li			$v0, 2
	syscall
	
	# output a new line
	li			$a0, '\n'
	li			$v0, 11
	syscall
	
	la			$a0, sol_x2
	li			$v0, 4
	syscall
	mov.s		$f12, $f1
	li			$v0, 2
	syscall
	
end:
		
	# exit program
	li			$v0, 10
	syscall

#
#####################################################################################
#
#	solveqe($f12, $f13, $f14)
#		finds status of quadratic equation and
# 		possibly solves for its solutions
#	parameters:
#		$f12: value of a
#		$f13: value of b
#		$f14: value of c
#	return:
#		$v0: status
#		$f0: single solution
#		$f1: first double solution
#		$f2: second double solution
#	

solveque:

	# return status 0 if not a quadratic equation
	li.s		$f4, 0.0
	c.eq.s		$f12, $f4			# is a < 0 ?
	bc1f		a_not_zero
	c.eq.s		$f13, $f4			# is b < 0 ?
	bc1f		b_not_zero
	move		$v0, $zero			# return status
	jr			$ra
		
b_not_zero:
		
	# return status 1 if single solution and the solution itself 
	neg.s		$f14, $f14			# -c
	div.s		$f0, $f14, $f13		# -c/b (solution)
	li			$v0, 1				# return status
	jr			$ra
	
a_not_zero:

	# compute discriminant
	mul.s		$f5, $f13, $f13		# b^2
	mul.s		$f6, $f12, $f14		# ac
	li.s		$f7, 4.0
	mul.s		$f7, $f7, $f6		# 4ac
	sub.s		$f8, $f5, $f7		# b^2-4ac

	# return status -1 if imaginary
	c.lt.s		$f8, $f4
	bc1f		d_gt_zero
	li			$v0, -1				# return status
	jr			$ra

d_gt_zero:

	# return status 2 and the two solutions
	sqrt.s		$f8, $f8			# sqrt(b^2-4ac)
	neg.s		$f13, $f13			# -b
	add.s		$f9, $f13, $f8		# -b + sqrt(b^2-4ac)
	sub.s		$f10, $f13, $f8		# -b - sqrt(b^2-4ac)
	li.s 		$f11, 2.0
	mul.s 		$f11, $f11, $f12	# 2a
	div.s 		$f0, $f9, $f11		# (-b + sqrt(b^2-4ac)/(2a)) (first solution)
	div.s 		$f1, $f10, $f11 	# (-b - sqrt(b^2-4ac)/(2a))(second solution)
	li			$v0, 2				# return status
	jr			$ra
