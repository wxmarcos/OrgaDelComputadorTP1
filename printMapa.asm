global printMapa
extern printf, fopen, fgets, fclose

%macro mPrintf 0 
    sub     rsp,8
    call    printf
    add     rsp,8
%endmacro


section .data
    fileTablero     db "mapa.txt", 0
    modo            db "r", 0
    error           db "Error de archivo", 0
    formato         db "%s", 0


section .bss
    idTablero       resq 1
    registro        resb 200


section .text
printMapa:
    ; Apertura de archivo
    ; mov rdi, fileTablero
    mov rsi, modo

    sub rsp, 8
    call fopen
    add rsp, 8

    cmp rax, 0
    jle errorArchivo
    mov qword [idTablero], rax

    ; Leer y imprimir cada linea del archivo
leer_linea:
    mov rdi, registro
    mov rsi, 200
    mov rdx, [idTablero]

    sub rsp, 8
    call fgets
    add rsp, 8

    cmp rax, 0
    je cerrar_archivo

    ; Imprimir linea
    mov rdi, formato
    mov rsi, registro

    mPrintf

    jmp leer_linea

cerrar_archivo:
    ; Cierre de archivo
    mov rdi, [idTablero]

    sub rsp, 8
    call fclose
    add rsp, 8
    
    ret

errorArchivo:
    mov rdi, error

    mPrintf

    ret
