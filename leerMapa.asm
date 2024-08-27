global leerMapa

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

section .data
    
    modoLectura		            db	"rb+",0	
    msgErrorApertura       	    db	"Error en apertura de archivo Mapa",0

section .bss
    idMapa              resq 1
section .text
leerMapa:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ABRO EL ARCHIVO PARA LECTURA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;en el rdi debo tener el archivo
    mov     rsi,modoLectura 

    sub     rsp,8
    call    fopen
    add     rsp,8

	cmp		rax,0
	jle		errorAperturaArchivo
	mov     [idMapa],rax

    ;; Se lee el archivo y se guarda lo leido en matriz
    mov     rdi,r12              ;Param 1: campo de memoria para guardar el registro q se leerá del archivo
    mov     rsi,10                  ;Param 2: Tamaño del registro en bytes
    mov     rdx,1                   ;Param 3: Cantidad de registros a leer (** usamos siempre 1 **)
    mov		rcx,[idMapa]     ;Param 4: id o handle del archivo (obtenido en fopen)

	sub		rsp,8  
	call    fread
	add		rsp,8

    ;; Se lee el archivo y se guarda lo leido en matriz
    mov     rdi,r13              ;Param 1: campo de memoria para guardar el registro q se leerá del archivo
    mov     rsi,50                  ;Param 2: Tamaño del registro en bytes
    mov     rdx,1                   ;Param 3: Cantidad de registros a leer (** usamos siempre 1 **)
    mov		rcx,[idMapa]     ;Param 4: id o handle del archivo (obtenido en fopen)

	sub		rsp,8  
	call    fread
	add		rsp,8



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