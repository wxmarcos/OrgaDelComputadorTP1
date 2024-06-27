global	printMapa
extern	printf
extern  puts
extern  gets
extern  sscanf

%macro mGets 0 
    sub     rsp,8
    call    gets
    add     rsp,8
%endmacro

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
    separador           db  "---------------------",10,0
    char                db  "|%c|",0
    charNum             db  "|%hhi| ",0    
    
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

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;IMPRIME MATRIZ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
imprimir:           
    xor     rcx,rcx                                              
    mov     rdi,char
    mov     cx,[contador]
    mov     rsi,[matriz + rcx]              ;;; EL PROBLEMA DEL RCX ES QUE CUANDO LLAMAS A PRINTF COMO LO USA EN SUS PARAMETROS LO LLENA DE KK(ARREGLAR LUEGO)
    mPrintf
    
    inc     byte[contador]

    ; Cada 7 elementos \n
    mov     ax,[contador]
    idiv    byte[longFila]

    cmp     ah,0
    je      nuevaLinea

    jmp     imprimir

nuevaLinea:
    mov     rdi, newline   
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

finLoop:
    mov     byte[contador],0
    mov     byte[nFil],1

    ret