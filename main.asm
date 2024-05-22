global	main
extern	puts
extern	fopen
extern	fgets
extern	fclose


section		.data  
    fileTablero     db "mapa.txt",0
    modo            db  "r+"
    error           db "Error de archivo",0

section		.bss
    idTablero       resq 1
    registro        resb 81

section		.text

main:

	sub		rsp,8
	call	manejoArchivoTablero
	add		rsp,8  

    ;Imprimir mapa
    mov     rdi,registro
    sub		rsp,8
	call	puts
	add		rsp,8
    

    ret

manejoArchivoTablero:
    ;Apertura de archivo
    mov     rdi,fileTablero
    mov     rsi,modo

	sub		rsp,8
	call	fopen
	add		rsp,8

    cmp     rax,0
    jle     errorArchivo
    mov     qword[idTablero],rax

    ;Lectura de archivo
    mov     rdi,registro
    mov     rsi,80
    mov     rdx,[idTablero]

	sub		rsp,8
	call	fgets
	add		rsp,8

    cmp     rax,0
    jle     errorArchivo
    
    ;Cierre de archivo
    mov     rdi,[idTablero]
    sub		rsp,8
	call	fclose
	add		rsp,8        

    ret

errorArchivo:
    mov     rdi,error

    sub		rsp,8
	call	puts
	add		rsp,8

    ret
