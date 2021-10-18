
.data
.balign 4

len:
	.word 3000
format_string:
	.asciz "%d "
format_string_new_line:
	.asciz "%d\n"

.text
.global main

@ Function which actually sorts the array
@ param array base ptr : r0
@ param arrayLen: r1
quicksort:
	
	@ if (len < 1) return;
	cmp r1, #1
	@ bxle => branch and change instruction set if less or equal
	bxle lr

	push {r4, r5, r6, r7, r8, r9, lr}
	@ choose pivot
	@ TODO: Random pivot
	@ move pivot to the right

	@ load pivot value
	sub r4, r1, #1
	add r4, r0, r4, lsl #2
	ldr r4, [r4]
	
	@ left and right index
	mov r5, #0
	@ right should exclude the pivot element
	sub r6, r1, #2

	@ put every element lower than pivot element to left side
	@ every element greater than pivot to right side

	cmp r5, r6
	bge .outerLoopEnd

.outerLoopBody:
.leftLoopBody:
	@ bounds check
	add r9, r5, #1
	cmp r9, r1
	bge .rightLoopBody
	
	@ skip this element at offset r5 if value is less than pivot element
	add r7, r0, r5, lsl #2
	ldr r7, [r7]
	
	@ if(arr[r5] >= pivotElement) break
	cmp r7, r4
	bgt .rightLoopBody

	@ skip to next element
	add r5, #1
	
	b .leftLoopBody
.rightLoopBody:
	@ bounds check
	cmp r6, #0
	blt .Swap

	@ compare to pivot element
	add r8, r0, r6, lsl #2
	ldr r8, [r8]

	@ if(arr[r6] < pivotElement) break
	cmp r8, r4
	blt .Swap

	sub r6, #1
	b .rightLoopBody

.Swap:
	@ compare left and right. If right is smaller than left don't swap -> terminating condition met
	cmp r5, r6
	bge .outerLoopEnd


	@ swap elements (arr[left]: r7, arr[right]: r8)
	str r8, [r0, r5, lsl #2]
	str r7, [r0, r6, lsl #2]

	@ back to start of outer loop
	@ condition that left < right if the program reaches this point because it's checked before swapping elements
	@ another comparision is therefore not necessary
	b .outerLoopBody
	
.outerLoopEnd:
	@ put pivot element in the right position (right position = left because when the "outerLoop" finishes left is greater or equal to right)

	ldr r7, [r0, +r5, lsl #2]
	@ calculate pivot idx
	sub r8, r1, #1

	@ swap arr[left] and arr[len - 1] === pivotElem (r4)
	str r7, [r0, +r8, lsl #2]
	str r4, [r0, +r5, lsl #2]


	@ make recursive call to quicksort helper on new sub arrays
	push {r0, r5}
	add r5, #1 @ pivot doesn't need to be resorted again. This is the reason for adding one
	sub r1, r5
	add r0, r5, lsl #2
	bl quicksort

	pop {r0, r5}
	mov r1, r5
	bl quicksort

	pop {r4, r5, r6, r7, r8, r9, lr}
	bx lr

@ param base addr: r0
@ param len: r1
print:
	push {r4, r5, r6, lr}
	
	mov r4, r0
	mov r5, r1
	mov r6, #0
.printLoopBody:
	cmp r6, r5
	bge .printLoopEnd
	ldr r0, format_string_addr
	ldr r1, [r4, r6, lsl #2]
	bl printf

	add r6, #1
	b .printLoopBody
.printLoopEnd:
	@ print new line by putting a null byte on the stack and printing that to the console using puts
	mov r1, #0
	push {r1}
	mov r0, sp
	bl puts
	pop {r1}

	pop {r4, r5, r6, lr}
	bx lr
main:
	push {r4, r5, r6, r7, lr}
	
	@ random seed for rand() function
	mov r0, #0
	bl time
	bl srand

	@ allocate memory for len ints
	@ calculate number of bytes needed for array
	ldr r0, addr_len
	ldr r0, [r0]
	mov r5, r0 @ len = r5
	lsl r0, #2
	@ allocate memory. pointer will be stored in r0
	bl malloc
	@ base address of array on the stack
	push {r0}
	mov r7, r0

	@ Initialize the array with random values

	mov r4, #0 @ i = 0
.InitLoopBody:
	cmp r4, r5 @ compare i and length (i < len)
	bge .InitLoopEnd 
	
	add r6, r7, r4, lsl #2
	bl rand
	and r0, r0, #0xFF
	str r0, [r6]
	
	add r4, #1
	b .InitLoopBody
.InitLoopEnd:
	
	
	mov r0, r7
	mov r1, r5
	bl print	
	
	mov r0, #0 @ new line
	push {r0}
	mov r0, sp
	bl puts
	pop {r0}
	
	@ prepare for function call to quicksort(arrayptr, len)
	mov r0, r7 @ array ptr
	mov r1, r5 @ len
	bl quicksort
	
	mov r0, r7
	mov r1, r5
	bl print	

	@ pop address of array of the stack
	pop {r0}
	bl free
	pop {r4, r5, r6, r7, lr}
	mov r0, #0
	bx lr

addr_len: .word len
format_string_addr: .word format_string
format_string_new_line_addr: .word format_string_new_line
