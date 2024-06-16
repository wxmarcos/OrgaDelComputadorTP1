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
    fileTablero3     db "mapa3.txt", 0
    
    msjSalir         db "Partida cancelada.",0
    msjFin           db 10,"Finalizo la partida: %s",10,0
    msjMovimiento    db 10,"Ingresar w (arriba), a (izquierdo), s (abajo), d (derecha), q (diagonal sup izq), e (diagonal sup der), z (diagonal inf izq), (diagonal inf der) o x (para salir)",10,0

    newline          db 10, 0 
    texto    db "Valor de la celda %lli",10,0
    
    ; Matriz de 7x7 para guardar posiciones de las 'O'
    posOcas   times 49 db 0

    posx        dd 02
    posy        dd 03
    longfil     dd 28
    longele     dd 4


section .bss
    proxMov          resq 1


section .text
main:

    mov rdi, fileTablero1
    sub rsp, 8
    call printMapa
    add rsp, 8





    ; Añadir una nueva linea al final
    mov rdi, newline
    mPrintf


    mov rcx, 0
    mov rbx, posOcas


    mov eax,dword[posx] ;guardo el valor de la fila
    sub eax,1
    imul dword[longfil] ;me desplazo en la fila
    add ecx,eax


    mov eax,dword[posy] ;guardo el valor de la fila
    sub eax,1
    imul dword[longele] ;me desplazo en la columna
    add ecx,eax ;sumo los desplazamientos
    

    add ebx,ecx ;me posicione en la matriz

    mov rdi, texto
    mov esi,dword[rbx]
    mPrintf

    mov dword[rbx],5 ;nuevo el valor

    mov rdi, texto
    mov esi,dword[rbx]
    mPrintf



    mov rdi, fileTablero1
    sub rsp, 8
    call printMapa
    add rsp, 8



    
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

