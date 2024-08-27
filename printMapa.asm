global	printMapa
extern	printf
extern  puts

%macro mPuts 0 
    sub     rsp,8
    call    puts
    add     rsp,8
%endmacro

%macro mPrintf 0 
    sub     rsp, 8         
    call    printf         
    add     rsp, 8
%endmacro


section	.data
    columnas            db  " 🦊🌿🦢   ( 1 ) ( 2 ) ( 3 ) ( 4 ) ( 5 ) ( 6 ) ( 7 )",0 
    separador           db  "       🌲------------------------------------------🌲",0
    arboles             db  "       🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲",10,0
    separadorFilas      db  "🌲",10,"       🌲------------------------------------------🌲",10,0
    

    charPasto           db  "  🌿  ",0
    charPiedra          db  " 🗿🗿 ",0 
    charZorro           db  "  🦊  ",0
    charOca             db  "  🦢  ",0
    charNum             db  " ( %hhi ) 🌲",0    
    
    newline             db  10,0                               
    longFila            db  7                               
    nFil                db  1
    contador            db  0
    

section	.bss
    matriz  		    resb	100


section .text
printMapa:
    mov     rsi,rdi
    mov     rdi, matriz
    mov     rcx,49
    rep     movsb


    mov     rdi, columnas
    mPuts
    mov     rdi, arboles   
    mPrintf  
    mov     rdi, separador
    mPuts
    
    sub     rcx,rcx
    sub     rsi,rsi
    sub     rdi,rdi 

    mov     rdi,charNum
    mov     sil,[nFil]
    mPrintf
    inc     byte[nFil]


    sub     rsp,8
    call    imprimir
    add     rsp,8
    mov     rdi, arboles   
    mPrintf

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;IMPRIME MATRIZ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
imprimir:      
    
    xor     rcx,rcx                                              
    mov     cx,[contador]
    mov     rsi,[matriz + rcx]              ;;; EL PROBLEMA DEL RCX ES QUE CUANDO LLAMAS A PRINTF COMO LO USA EN SUS PARAMETROS LO LLENA DE KK(ARREGLAR LUEGO)
    
    ;;Chequeo que elemento tiene la matriz para imprimir un mapa realista con emojis
    cmp     byte[matriz + rcx],"#"
    je      asignoCharPiedra
    cmp     byte[matriz + rcx]," "
    je      asignoCharPasto
    cmp     byte[matriz + rcx],"X"
    je      asignoCharZorro
    cmp     byte[matriz + rcx],"O"
    je      asignoCharOca

seguirImprimiendo:
    mPrintf
    
    inc     byte[contador]

    ; Cada 7 elementos \n
    mov     ax,[contador]
    idiv    byte[longFila]

    cmp     ah,0
    je      nuevaLinea

    jmp     imprimir

nuevaLinea:
    mov     rdi, separadorFilas   
    mPrintf

    sub     rdi,rdi
    sub     rsi,rsi
    mov     rdi,charNum
    mov     sil,[nFil]
    cmp     sil,8
    je      continuar
    mPrintf
    inc     byte[nFil]

continuar:
    cmp     byte[contador],49
    je      finLoop
    jmp     imprimir  
asignoCharPiedra:
    mov     rdi,charPiedra
    jmp     seguirImprimiendo
asignoCharPasto:
    mov     rdi,charPasto
    jmp     seguirImprimiendo
asignoCharZorro:
    mov     rdi,charZorro
    jmp     seguirImprimiendo
asignoCharOca:
    mov     rdi,charOca   
    jmp     seguirImprimiendo     
finLoop:
    mov     byte[contador],0
    mov     byte[nFil],1

    ret