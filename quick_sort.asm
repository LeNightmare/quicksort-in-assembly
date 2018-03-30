.globl 	main

.data 
		.align 5
	array:	
		.asciiz "Joe"
		.align 5
		.asciiz "Jenny"
		.align 5
		.asciiz "Jill"
		.align 5
		.asciiz "John"
		.align 5
		.asciiz "Jeff"
		.align 5
		.asciiz "Joyce"
		.align 5
		.asciiz "Jerry"
		.align 5
		.asciiz "Janice"
		.align 5
		.asciiz "Jake"
		.align 5
		.asciiz "Jonna"
		.align 5
		.asciiz "Jack"
		.align 5
		.asciiz "Jocelyn"
		.align 5
		.asciiz "Jessie"
		.align 5
		.asciiz "Jess"
		.align 5
		.asciiz "Janet"
		.align 5
		.asciiz "Jane"
		
		
		.align 2
	dataAddr:
		.space 64
	size: 	
		.word 16
	x: 	
		.word 0
	str: 	
		.word str_before, str_after
	str_before: 	
		.asciiz "Initial array:\n"
	str_after: 	
		.asciiz "Sorted array:\n"
	
	mark: 
		.word lp, rp
	lp:
		.asciiz "["
	rp:	
		.asciiz " ]\n"
	
	space:
		.word sp
	sp:
		.asciiz " "
.text
	main:
		#const char* data[] = {...}
		move $s0, $ra
		jal pointer 
		move $ra, $s0
		
		la $t0, str
		# printf("Initial array:\n")
		lw $a0, 0($t0)
		move $s0, $ra
		jal print_string
		move $ra, $s0
		
		# print_array(data, size)
		la $a0, dataAddr
		lw $a1, size
		move $s0, $ra
		jal print_array
		move $ra, $s0


		# quick_sort(data, size)
		la $a0, dataAddr
		lw $a1, size
		jal quick_sort
		
		# printf("sorted array:\n")
		la $t0, str
		lw $a0, 4($t0)
		move $s0, $ra
		jal print_string
		move $ra, $s0
					
		# print_array(data, size)	
		la $a0, dataAddr
		lw $a1, size
		move $s0, $ra
		jal print_array
		move $ra, $s0
		
		# exit(0)
		sw $v0, x($zero)
		li $v0, 10
		li $a0, 0
		syscall

		# printf function
	print_string:			
		li $v0, 4
		syscall
		li $v0, 0
		jr $ra
		
		#print_array function
	print_array:
		la $t1, mark

		move $t2, $a0
		move $t3, $a1
		
		# printf("[")
		lw $a0, 0($t1)
		move $s0, $ra
		jal print_string
		move $ra, $s0
		
		move $a0, $t2
		move $a1, $t3
		# printf elements, the for loop		
		move $s1, $ra
		jal print_element
		move $ra, $s1
		
		# printf(" ]\n")
		# printf rp
		la $t1, mark
		lw $a0, 4($t1)
		move $s0, $ra
		jal print_string
		move $ra, $s0

		jr $ra

	print_element:
	
		la $t0, space
		move $t1, $a1
		#la $t2, array
		move $t4, $a0
		# int i = 0
		li $t3, 0

		loop:
			# i >= size, end_loop
			bge $t3, $t1, end_loop
			
			# printf(" ")
			lw $a0, 0($t0)
			move $s0, $ra
			jal print_string
			move $ra, $s0
			
			# printf("%s", a[i])
			lw $a0, 0($t4)
			move $s0, $ra
			jal print_string
			move $ra, $s0
			
			# i++, a[i+1]
			addi $t3, $t3, 1
			add $t4, $t4, 4
			j loop

	end_loop:
		jr $ra
		
	quick_sort:
	
		addi $sp, $sp, -44
		sw $ra, 36($sp)
		sw $fp, 32($sp) 
		sw $s0, 28($sp) # a
		sw $s1, 24($sp)	# pivot			
		sw $s2, 20($sp)	# a + pivot + 1			
		sw $s3, 16($sp) # len - pivot - 1

		# true
		li $t3, 1	# 
		# int i = 0
		li $t2, 0	
		# pivot = 0
		li $s4, 0 	
		
		# len > 1, end_if
		bgt $a1, $t3, do_sort
		# return
		b return
		
	do_sort:
		# len - 1	
		move $s5, $a1
		addi $s5, $s5, -1	
		# a[i]	
		move $s0, $a0	
		# a[len - 1]			
		mul $t5, $s5, 4 
		add $t5, $a0, $t5
		quick_sort_loop:
			# i > len - 1, end loop
			bgt $t2, $s5, end_sort_loop

			# str_lt(a[i], a[len - 1])
			move $a1, $t5	# a[len - 1]
			jal str_lt						
			move $t6, $v0
			# if str_lt(a[i], a[len - 1]) != 1, end_if
			bne $t6, $t3, end_if
	
			# a[pivot]
			mul $t6, $s4, 4
			add $a1, $s0, $t6	
			# swap_str_ptrs(&a[i], &a[pivot])
			jal swap_str_ptrs
			# pivot ++
			addi $s4, $s4, 1
			# i ++
			addi $t2, $t2, 1
			
			# a[pivot]
			addi $a0, $a0, 4
			b quick_sort_loop
			
			
		end_if:
			# i ++
			addi $t2, $t2, 1
			# a[pivot]			
			addi $a0, $a0, 4
			b quick_sort_loop
			
		end_sort_loop:
			
			# a[pivot]
			mul $a0, $s4, 4
			add $a0, $a0, $s0 
			# a[len - 1]
			move $a1, $t5			 
			
			# swap_str_ptrs(&a[pivot], &a[len - 1])
			jal swap_str_ptrs
	
		# recurrency
			
			# a 
			move $a0, $s0
			# pivot
			move $s1, $s4
			move $a1, $s4	
			
			# a + pivot + 1
			addi $s2, $s0, 4
			mul $t5, $s1, 4
			add $s2, $s2, $t5	
			# len - pivot - 1
			sub $s3, $s5, $a1

			# quick_sort(a, pivot)
			jal quick_sort
			
			# quick_sort(a + pivot + 1, len - pivot - 1)
			move $a0, $s2
			move $a1, $s3
			jal quick_sort			
	
	# quick_sort return		
	return: 
		lw $ra, 36($sp)
		lw $fp, 32($sp)
		lw $s0, 28($sp)
		lw $s1, 24($sp)
		lw $s2, 20($sp)
		lw $s3, 16($sp)
		addi $sp, $sp, 44	
		jr $ra
	
	
	str_lt:
		addi $sp, $sp, -4
		sw $ra, 0($sp)	
		# *x
		lw $t6, 0($a0)
		# *y
		lw $t7, 0($a1)
		# '\0'
		li $t4, '\0'
		str_loop:
			# *x = '\0' || *y = '\0', end_loop
			lb $t0, ($t6)
			lb $t1, ($t7)
			beq $t0, $t4, end_str_loop
			beq $t1, $t4, end_str_loop
			# if(*x < *y) return 1
			blt $t0, $t1, return_one
			# if(*y < *x) return 0
			blt $t1, $t0, return_zero
			# x++, y++
			addi $t6, $t6, 1
			addi $t7, $t7, 1
			j str_loop
			
	end_str_loop:
		# if(*y == '\0') return 0		
		beq $t1, $t4, return_zero
		# return 1
		j return_one
		
	# return 0	
	return_zero:
		li $v0, 0
		lw $ra, 0($sp)
		addi $sp, $sp, 4	
		jr $ra
	# return 1
	return_one:
		li $v0, 1
		lw $ra, 0($sp)
		addi $sp, $sp, 4	
		jr $ra

	
	swap_str_ptrs:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		# tmp1 = *s1
		lw $t0, 0($a0)
		# tmp2 = *s2
		lw $t1, 0($a1)
		# *s1 = tmp2
		sw $t1, 0($a0)
		# *s2 = tmp1
		sw $t0, 0($a1)
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4		
		jr $ra
	
	# char * data[]
	pointer:
		la $t0, array
		lw $t1, size
		la $t2, dataAddr
		li $t3, 0
		li $t5, 0
		pointer_loop:
			bge $t3, $t1, end_loop			
			sw $t0, 0($t2)
			addi $t3, $t3, 1
			add $t2, $t2, 4
			add $t0, $t0, 32
			j pointer_loop

		 
