global main
extern printf, printMapa, gets

%macro mPrintf 0 
    sub     rsp,8
    call    printf
    add     rsp,8
%endmacro

%macro mGets 0 
    sub     rsp,8
    call    gets
    add     rsp,8
%endmacro


section .data
    fileTablero1     db "mapa1.txt", 0
    fileTablero2     db "mapa2.txt", 0

    msjSalir        db "Partida cancelada",0
    msjFin          db 10,"Finalizo la partida: %s",10,0
    msjMovimiento   db 10,"Ingresar w (arriba), a (izquierdo), s (abajo), d (derecha) o x (para salir)",10,0

    newline         db 10, 0 

    cantOcas        dq 17


section .bss
    proxMov         resq 2

section .text
main:
    mov rdi, fileTablero2
    sub rsp, 8
    call printMapa
    add rsp, 8

    ; Añadir una nueva linea al final
    mov rdi, newline
    mPrintf
    
    mov rdi, msjMovimiento
    mPrintf
    
    ; Valido salida del programa.
    mov rdi, proxMov
    mGets

    ; Verificar condicion de corte.
    mov rdi, [proxMov]
    cmp rdi, 'x'
    mov rsi, msjSalir
    je  finPrograma

    jmp main

finPrograma:
    mov rdi, msjFin
    mPrintf

    ret

