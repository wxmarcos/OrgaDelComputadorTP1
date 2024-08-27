global guardarMapa

%macro mPuts 1
    mov     rdi,%1
    sub     rsp,8
    call    puts
    add     rsp,8
%endmacro

extern  puts
extern  fopen
extern  fwrite
extern  fclose
extern  fread
extern  printf
extern  printMapa

section .data
    
    fileMatriz		            db	"guardado.dat",0 
    modoEscritura               db  "wb+",0
    msgErrorApertura       	db	"Error en apertura de archivo Mapa",0

section .bss
    idMapa              resq 1

section .text
guardarMapa:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SE GUARDA EL MAPA EN EL ARCHIVO 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ABRO EL ARCHIVO PARA ESCRITURA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rdi,fileMatriz   ;Param 1: string con nombre del archivo (finaliza con 0 binario!!)
    mov     rsi,modoEscritura 

    sub     rsp,8
    call    fopen
    add     rsp,8

	cmp		rax,0
	jle		errorAperturaArchivo
	mov     [idMapa],rax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SE GUARDA EL MAPA EN EL ARCHIVO 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;Se guarda el mapa en el archivo   
    mov     rdi,r12        
    mov     rsi, 10                ; Param 2: tamaño del registro en bytes
    mov     rdx, 1                  ; Param 3: cantidad de registros a escribir (1)
    mov     rax, [idMapa]           ; Obtener el handle del archivo (obtenido en fopen)

    ; Alinear la pila a 16 bytes antes de llamar a fwrite
    sub     rsp, 8                  ; Espacio para alinear la pila
    mov     rcx, rax                ; Enviar el handle del archivo a rcx, aunque no se use en fwrite
    call    fwrite
    add     rsp, 8                  ; Restaurar la pila

    ;;Se guarda el mapa en el archivo   
    mov     rdi,r13       
    mov     rsi, 50                 ; Param 2: tamaño del registro en bytes
    mov     rdx, 1                  ; Param 3: cantidad de registros a escribir (1)
    mov     rax, [idMapa]           ; Obtener el handle del archivo (obtenido en fopen)

    ; Alinear la pila a 16 bytes antes de llamar a fwrite
    sub     rsp, 8                  ; Espacio para alinear la pila
    mov     rcx, rax                ; Enviar el handle del archivo a rcx, aunque no se use en fwrite
    call    fwrite
    add     rsp, 8                  ; Restaurar la pila
    

    

    ; Verificar el resultado de fwrite
    cmp     rax, 1                  ; Verificar si se escribió exactamente un registro

    ;Cierro el archivo
cerrarArchivo:
    mov     rdi,[idMapa]
    sub     rsp,8
    call    fclose
    add     rsp,8
    jmp     endProg

errorAperturaArchivo:
    mPuts   msgErrorApertura
	jmp		endProg

endProg:
ret