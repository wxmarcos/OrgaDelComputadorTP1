global main

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
    modoLectura		            db	"rb+",0	
    modoEscritura               db  "wb+",0
    msgErrorAperturaArchivo       	db	"Error en apertura de archivo Mapa",0

section .bss

    matriz              resb 50
    idMapa              resq 1

section .text
main:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SE GUARDA EL MAPA EN EL ARCHIVO 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ABRO EL ARCHIVO PARA LECTURA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rdi,fileMatriz   ;Param 1: string con nombre del archivo (finaliza con 0 binario!!)
    mov     rsi,modoLectura 

    sub     rsp,8
    call    fopen
    add     rsp,8

	cmp		rax,0
	jle		msgErrorAperturaArchivo
	mov     [idMapa],rax

     ;; Se lee el archivo y se guarda lo leido en matriz
    mov     rdi,matriz              ;Param 1: campo de memoria para guardar el registro q se leerá del archivo
    mov     rsi,50                  ;Param 2: Tamaño del registro en bytes
    mov     rdx,1                   ;Param 3: Cantidad de registros a leer (** usamos siempre 1 **)
    mov		rcx,[idMapa]     ;Param 4: id o handle del archivo (obtenido en fopen)

	sub		rsp,8  
	call    fread
	add		rsp,8


     ;Printeo el mapa
    xor     rdi,rdi
    mov     rdi,matriz
    sub		rsp,8	
    call    printMapa    
	add		rsp,8	

    sub rsp,8
    call cerrarArchivo
    add rsp,8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ABRO EL ARCHIVO PARA ESCRITURA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rdi,fileMatriz   ;Param 1: string con nombre del archivo (finaliza con 0 binario!!)
    mov     rsi,modoEscritura 

    sub     rsp,8
    call    fopen
    add     rsp,8

	cmp		rax,0
	jle		msgErrorAperturaArchivo
	mov     [idMapa],rax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SE GUARDA EL MAPA EN EL ARCHIVO 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;Se guarda el mapa en el archivo 
    mov     rdi, matriz            ; Param 1: dirección de memoria con el registro a escribir
    mov     rsi, 50       ; Param 2: tamaño del registro en bytes
    mov     rdx, 1                  ; Param 3: cantidad de registros a escribir (1)
    mov     rax, [idMapa]    ; Obtener el handle del archivo (obtenido en fopen)

    ; Alinear la pila a 16 bytes antes de llamar a fwrite
    sub     rsp, 8                  ; Espacio para alinear la pila
    mov     rcx, rax                ; Enviar el handle del archivo a rcx, aunque no se use en fwrite
    call    fwrite
    add     rsp, 8                  ; Restaurar la pila
    

    

    ; Verificar el resultado de fwrite
    cmp     rax, 1                  ; Verificar si se escribió exactamente un registro

    sub rsp,8
    call cerrarArchivo
    add rsp,8

    ret


    ;Cierro el archivo
cerrarArchivo:
    mov     rdi,[idMapa]
    sub     rsp,8
    call    fclose
    add     rsp,8
    ret

errorAperturaArchivo:
    mPuts   msgErrorAperturaArchivo
	jmp		endProg

endProg:
ret