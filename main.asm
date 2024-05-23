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
    msjSalir        db "Partida cancelada",0
    msjFin          db 10,"Finalizo la partida: %s",10,0
    msjMovimiento   db 10,"Ingresar w (arriba), a (izquierdo), s (abajo), d (derecha) o x (para salir)",10,0
    newline         db 10, 0 


section .bss
    proxMov         resq 2

section .text
main:
    sub rsp, 8
    call printMapa
    add rsp, 8

    ; Añadir una nueva linea al final
    mov rdi, newline
    mPrintf
    
    mov rdi, msjMovimiento
    mPrintf
    
    ; Valido salida del programa
    mov rdi, proxMov
    mGets

    mov rdi, [proxMov]
    cmp rdi, 'x'
    mov rsi, msjSalir
    je  finPrograma

    jmp main

finPrograma:
    mov rdi, msjFin
    mPrintf

    ret

