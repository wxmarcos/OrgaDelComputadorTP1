section .data
    filename db 'input.txt',0
    mode     db 'r',0

    ; Buffer to read file content
    buffer   times 128 db 0

    ; Matriz de 7x7 para guardar posiciones de las 'O'
    matriz   times 49 db 0

section .bss
    file_handle resd 1

section .text
    extern fopen, fgets, fclose
    extern printf

    global _start

_start:
    ; Abrir archivo
    push dword mode
    push dword filename
    call fopen
    add esp, 8
    mov [file_handle], eax

    ; Leer archivo
    mov ecx, 7            ; Número de filas
    mov edi, buffer       ; Dirección del buffer
    mov esi, matriz       ; Dirección de la matriz
read_lines:
    dec ecx
    jl done_reading

    push dword edi
    push dword 128
    push dword [file_handle]
    call fgets
    add esp, 12

    ; Procesar línea leída
    mov ebx, 0            ; Índice de columna
process_line:
    cmp byte [edi + ebx], 0
    je next_line

    cmp byte [edi + ebx], 'O'
    jne skip
    ; Si es 'O', guarda 1 en la matriz
    mov byte [esi + ebx], 1
skip:
    inc ebx
    cmp ebx, 128
    jl process_line

next_line:
    add esi, 7            ; Mover al siguiente fila en la matriz
    jmp read_lines

done_reading:
    ; Cerrar archivo
    push dword [file_handle]
    call fclose
    add esp, 4

    ; Imprimir matriz para verificación
    mov ecx, 7
    mov esi, matriz
print_matrix:
    dec ecx
    jl done_printing

    mov ebx, 0
print_row:
    cmp ebx, 7
    jge next_row

    mov al, byte [esi + ebx]
    add al, '0'
    push eax
    push format
    call printf
    add esp, 8

    inc ebx
    jmp print_row

next_row:
    add esi, 7
    push new_line
    call printf
    add esp, 4
    jmp print_matrix

done_printing:
    ; Terminar el programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

section .data
    format db '%c ', 0
    new_line db 10, 0