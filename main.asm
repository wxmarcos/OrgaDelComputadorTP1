global	main
extern	printf
extern  puts
extern  gets
extern  sscanf
extern  printMapa
extern  system


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

%macro mPuts 0 
    sub     rsp,8
    call    puts
    add     rsp,8
%endmacro


section	.data
    matriz      db  "#","#","O","O","O","#","#"
                db  "#","#","O","O","O","#","#"
                db  "O","O","O","O","O","O","O"
                db  "O"," "," ","X"," "," ","O"
                db  "O"," "," "," "," "," ","O"
                db  "#","#"," "," "," ","#","#"
                db  "#","#"," "," "," ","#","#"
                                
    msgMovimientoZorro  db  "Ingresar W (arriba), A (izquierda), S (abajo), D (derecha), Q (diagonal sup izq), E (diagonal sup der), Z (diagonal inf izq), C (diagonal inf der) o X (para guardar y salir)",0
    msjMovimientoOcas   db  "Ingrese A (izquierda), S (abajo), D (derecha)",0
    msjIngFilCol	    db	"Ingrese fila (1 a 7) y columna (1 a 7) separados por un espacio para seleccionar la oca que quiera mover: ",0
    msjErrorInput       db  "Los datos ingresados son inválidos. Intente nuevamente.",0
    msjNoHayOca         db  "No hay una oca en esa posicion.",0
    msjOcasCapturadas   db  "Cantidad de ocas capturadas: %hhi",10,0
    msjError            db  "Error de movimiento",0

    columnas            db  "    |1||2||3||4||5||6||7|",0
    separador           db  "    ---------------------",0

    msjGanaZorro        db  10,"¡¡¡Gana el Zorro por capturar 12 ocas!!!",10,10,0   

    formatInputFilCol	db	"%hhi %hhi",0  
    cmdClear            db  "clear",0

    contador            db  0
    turno               db  0
    ocasCapturadas      db  0

	LONG_ELEM	        equ	1
	CANT_FIL	        equ	7
	CANT_COL	        equ	7
    longFila            db  7

    desplazOca			dw	0

section .bss
    inputFilCol		        resb	50
   	filOca		            resw	1
	colOca       	        resw	1 	
    inputValido             resb    1   ;S valido N invalido

    inputMov                resb    50
    posZorro                resb    100
    posZorroCol             resb    1
    posZorroFil             resb    1



section .text

main:
    ; Limpia la pantalla
    mov     rdi,cmdClear
    sub		rsp,8	
    call    system    
	add		rsp,8	

    ; Printea el mapa actualizado
    mov     rdi, columnas
    mPuts
    mov     rdi, separador
    mPuts

    xor     rdi,rdi
    lea     rdi,[matriz]

    sub		rsp,8	
    call    printMapa    
	add		rsp,8	

    mov     rdi, msjOcasCapturadas
    mov     sil, [ocasCapturadas]
    mPrintf


errorMovZorro:
; Si el zorro come  o si hay un error de mov salta aca para mover otra vez.
comioZorro:
    sub     rsp,8
    call    turnoZorro
    add     rsp,8

    ; Printea el mapa actualizado
    mov     rdi, columnas
    mPuts
    mov     rdi, separador
    mPuts
    xor     rdi,rdi
    mov     rdi,matriz

    sub		rsp,8	
    call    printMapa    
	add		rsp,8

    mov     rdi, msjOcasCapturadas
    mov     sil, [ocasCapturadas]
    mPrintf


    ; Chequea condicion de fin.
    sub     rdi,rdi
    mov     dil,[ocasCapturadas]
    cmp     dil,12
    je      fin


    xor     rcx,rcx
    mov     cl,byte[turno]
    cmp     cl,0
    je      main
    
errorMovOca:
    ; Siguen las Ocas
    sub     rsp,8
    call    turnoOcas
    add     rsp,8

    jmp     main


fin:
    ; Guardamos partida
    ; ....
    ; ....
    ; ....

    mov     rdi, msjGanaZorro
    mPrintf

    ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; VALIDAR FILA COLUMNA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validarFyC:
    mov     byte[inputValido],'N'   

    cmp     si,1
    jl      invalido
    cmp     si,7
    jg      invalido

    cmp     di,1
    jl      invalido
    cmp     di,7
    jg      invalido

    mov     byte[inputValido],'S'
invalido:
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RUTINAS INTERNAS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
turnoZorro:
    sub     rsp,8
    call    buscarZorro
    add     rsp,8

    sub     rsp,8
    call    movimientoZorro   
    add     rsp,8

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Ç
; BUCAR LA POSICION ACTUAL DEL ZORRO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
buscarZorro:
    mov     byte[contador],0

    sub     rsp,8
    call    buscarPosZorro
    add     rsp,8

    ret

buscarPosZorro:
    xor     rcx,rcx
    mov     cx,[contador]
    mov     al,[matriz + rcx]
    cmp     al,'X'                      
    je      actualizarPosicion          
    inc     byte[contador]
    jmp     buscarPosZorro

actualizarPosicion:
    mov     [posZorro],rcx
    mov     byte[contador],0

    sub     rax,rax
    mov     ax,[posZorro]
    idiv    byte[longFila]

    sub     rcx,rcx
    sub     rsi,rsi

    ; Cociente Fil
    inc     al
    mov     [posZorroFil],al
    ; Resto Col
    inc     ah
    mov     [posZorroCol],ah

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VALIDAR INGRESO POR TECLADO DEL MOVIMIENTO DEL ZORRO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movimientoZorro:
    mov     rdi,msgMovimientoZorro
    mPuts                       

    mov     rdi,inputMov
    mGets

    xor     rcx,rcx
    xor     rax,rax
    xor     rdi,rdi
    xor     rsi,rsi 

    mov     sil,[posZorroCol]
    mov     dil,[posZorroFil]


    cmp     byte[inputMov],'A'
    je      izquierdaZorro

    cmp     byte[inputMov],'D'
    je      derechaZorro

    cmp     byte[inputMov],'W'
    je      arribaZorro

    cmp     byte[inputMov],'S'
    je      abajoZorro

    cmp     byte[inputMov],'Q'
    je      diagonalArribaIzqZorro

    cmp     byte[inputMov],'E'
    je      diagonalArribaDerZorro

    cmp     byte[inputMov],'Z'
    je      diagonalAbajoIzqZorro

    cmp     byte[inputMov],'C'
    je      diagonalAbajoDerZorro

    cmp     byte[inputMov],'X'
    je      fin

    ; Si llega aca se ingreso algo no valido
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVIMIENTOS DEL ZORRO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validarIzq:
    dec     si 
    sub     rsp,8
    call    validarFyC
    add     rsp,8

    cmp     byte[inputValido],'S'
    je      pasoValido
    jmp     errorMovimientoZorro

izquierdaZorro:
    sub     rsp,8
    call    validarIzq
    add     rsp,8

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    sub     rcx,1

    cmp     byte [matriz + rcx],'O'
    je      verSiComeIzq

    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx
    add     rcx,1
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    ret

verSiComeIzq:
    sub     rsp,8
    call    validarIzq
    add     rsp,8

    sub     rcx,1
    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    add     rcx,1
    mov     byte [matriz + rcx],' '
    add     rcx,1
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validarDer:
    inc     si 
    sub     rsp,8
    call    validarFyC
    add     rsp,8

    cmp     byte[inputValido],'S'
    je      pasoValido
    jmp     errorMovimientoZorro



derechaZorro:
    sub     rsp,8
    call    validarDer
    add     rsp,8

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    add     rcx,1

    cmp     byte [matriz + rcx],'O'
    je      verSiComeDer

    ; Para verificar limites del tablero
    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx
    sub     rcx,1
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    ret

verSiComeDer:
    sub     rsp,8
    call    validarDer
    add     rsp,8

    add     rcx,1
    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    sub     rcx,1
    mov     byte [matriz + rcx],' '
    sub     rcx,1
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validarArriba:
    dec     di
    sub     rsp,8
    call    validarFyC
    add     rsp,8

    cmp     byte[inputValido],'S'
    je      pasoValido  
    jmp     errorMovimientoZorro

arribaZorro:
    sub     rsp,8
    call    validarDer
    add     rsp,8

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    sub     rcx,7

    cmp     byte [matriz + rcx],'O'
    je      verSiComeArriba

    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    add     rcx,7
    mov     [posZorro], rcx
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    ret


verSiComeArriba:
    sub     rsp,8
    call    validarDer
    add     rsp,8

    sub     rcx,7
    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    add     rcx,7
    mov     byte [matriz + rcx],' '
    add     rcx,7
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validarAbajo:
    inc     di
    sub     rsp,8
    call    validarFyC
    add     rsp,8

    cmp     byte[inputValido],'S'
    je      pasoValido
    jmp     errorMovimientoZorro

abajoZorro:
    sub     rsp,8
    call    validarAbajo
    add     rsp,8

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    add     rcx,7

    cmp     byte [matriz + rcx],'O'
    je      verSiComeAbajo

    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    sub     rcx,7
    mov     [posZorro], rcx
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    ret 

verSiComeAbajo:
    sub     rsp,8
    call    validarAbajo
    add     rsp,8

    add     rcx,7
    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    sub     rcx,7
    mov     byte [matriz + rcx],' '
    sub     rcx,7
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validarArriIzqZorro:
    dec     di
    dec     si
    sub     rsp,8
    call    validarFyC
    add     rsp,8

    cmp     byte[inputValido],'S'
    je      pasoValido
    jmp     errorMovimientoZorro


diagonalArribaIzqZorro:
    sub     rsp,8
    call    validarArriIzqZorro
    add     rsp,8

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    sub     rcx,8

    cmp     byte [matriz + rcx],'O'
    je     verSiComeArriIzqZorro

    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    add     rcx,8
    mov     [posZorro], rcx
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    ret 

verSiComeArriIzqZorro:
    sub     rsp,8
    call    validarArriIzqZorro
    add     rsp,8

    sub     rcx,8
    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    add     rcx,8
    mov     byte [matriz + rcx],' '
    add     rcx,8
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validarArriDerZorro:
    dec     di
    inc     si
    sub     rsp,8
    call    validarFyC
    add     rsp,8

    cmp     byte[inputValido],'S'
    je      pasoValido
    jmp     errorMovimientoZorro

diagonalArribaDerZorro:
    sub     rsp,8
    call    validarArriDerZorro
    add     rsp,8

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    sub     rcx,6

    cmp     byte [matriz + rcx],'O'
    je     verSiComeArriDerZorro

    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    add     rcx,6
    mov     [posZorro], rcx
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    ret 

verSiComeArriDerZorro:
    sub     rsp,8
    call    validarArriIzqZorro
    add     rsp,8

    sub     rcx,6
    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    add     rcx,6
    mov     byte [matriz + rcx],' '
    add     rcx,6
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validarAbajoIzqZorro:
    inc     di
    dec     si
    sub     rsp,8
    call    validarFyC
    add     rsp,8

    cmp     byte[inputValido],'S'
    je      pasoValido
    jmp     errorMovimientoZorro

diagonalAbajoIzqZorro:
    sub     rsp,8
    call    validarAbajoIzqZorro
    add     rsp,8

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    add     rcx,6

    cmp     byte [matriz + rcx],'O'
    je     verSiComeAbajoIzqZorro

    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    sub     rcx,6
    mov     [posZorro], rcx
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    ret 

verSiComeAbajoIzqZorro:
    sub     rsp,8
    call    validarArriIzqZorro
    add     rsp,8

    add     rcx,6
    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    sub     rcx,6
    mov     byte [matriz + rcx],' '
    sub     rcx,6
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validarAbajoDerZorro:
    inc     di
    inc     si
    sub     rsp,8
    call    validarFyC
    add     rsp,8

    cmp     byte[inputValido],'S'
    je      pasoValido
    jmp     errorMovimientoZorro

diagonalAbajoDerZorro:
    sub     rsp,8
    call    validarAbajoDerZorro
    add     rsp,8

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    add     rcx,8

    cmp     byte [matriz + rcx],'O'
    je     verSiComeAbajoDerZorro

    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    sub     rcx,8
    mov     [posZorro], rcx
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    ret 

verSiComeAbajoDerZorro:
    sub     rsp,8
    call    validarArriIzqZorro
    add     rsp,8

    add     rcx,8
    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    sub     rcx,8
    mov     byte [matriz + rcx],' '
    sub     rcx,8
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pasoValido:
    ret

errorMovimientoZorro:
    mov     rdi,msjError
    mPuts 
    jmp     errorMovZorro




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVIMIENTO DE LAS OCAS.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
turnoOcas:
    sub     rsp,8
    call    movimientoOca
    add     rsp,8   

    ret

movimientoOca:
    ; Pido una oca del tablero.
    sub     rsp,8
    call    obtener_pos_ocas
    add     rsp,8

    ; Pido un movimiento para la oca seleccionada.
    mov     rdi,msjMovimientoOcas
    mPuts                       
    mov     rdi,inputMov
    mGets

    ; Valido entrada.
    xor     rcx,rcx
    xor     rax,rax
    cmp     byte[inputMov],'A'
    je      izquierdaOca

    cmp     byte[inputMov],'D'
    je      derechaOca

    cmp     byte[inputMov],'S'
    je      abajoOca

    ret

; Obtengo una pos de alguna oca de tablero de juego.
obtener_pos_ocas:
	mov		rdi,msjIngFilCol
	call	mPrintf

    mov		rdi,inputFilCol	
    mGets    

    ; Valido la entrada de fila y columna.
    sub     rsp,8
    call    validarEntradaFyC
    add     rsp,8

    sub     rdi,rdi
    sub     rsi,rsi

    ; Guardo la posicion X e Y de la oca seleccionada
    mov     rdi,[filOca]
    mov     rsi,[colOca]

    sub     rsp,8
    call    validarFyC
    add     rsp,8

    cmp     byte[inputValido],'S'
    je      continuar

    mov     rdi,msjErrorInput
    mPuts

    jmp     obtener_pos_ocas


continuar:
    sub     rsp,8
    call    calcDesplaz
    add     rsp,8

    xor     r8,r8
    mov     r8w,[desplazOca]

    xor     rsi,rsi
	mov		sil,byte[matriz+r8]
    cmp     sil,'O'
    jne     noOca


    ret


validarEntradaFyC:
    mov     rdi,inputFilCol
    mov     rsi,formatInputFilCol
    mov     rdx,filOca
    mov     rcx,colOca

	sub		rsp,8
	call	sscanf
	add		rsp,8  

    cmp     rax,2
    jl      invalido

    ret



calcDesplaz:
    mov     word[desplazOca],0
	mov		ax,[filOca]			;ax = fil
	dec		ax						;fil-1
	imul	ax,LONG_ELEM	;(fil-1) * longElem
	imul	ax,CANT_COL	;(fil-1) * longElem * cantCol = (fil-1) * longFil

	mov		bx,ax				;bx = desplazOca en fil
	
	mov		ax,[colOca]			;ax = col
	dec		ax						;col-1
	imul	ax,LONG_ELEM	;(col-1) * longElem

	add		bx,ax				;bx = desplazOca total

    add     word[desplazOca], bx

    ret









izquierdaOca:
    mov     cx,[desplazOca]
    mov     al,[matriz + rcx]
    sub     rcx,1
    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoOca

    mov     byte [matriz + rcx], al
    mov     [desplazOca], rcx
    add     rcx,1
    mov     byte [matriz + rcx],' '

    dec     byte[turno]

    ret


derechaOca:
    mov     cx,[desplazOca]
    mov     al,[matriz + rcx]
    add     rcx,1
    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoOca

    mov     byte [matriz + rcx], al
    mov     [desplazOca], rcx
    sub     rcx,1
    mov     byte [matriz + rcx],' '

    dec     byte[turno]
    ret


abajoOca:
    mov     cx,[desplazOca]
    mov     al,[matriz + rcx]
    add     rcx,7
    cmp     byte [matriz + rcx],' '
    jne     errorMovimientoOca

    mov     byte [matriz + rcx], al
    sub     rcx,7
    mov     [desplazOca], rcx
    mov     byte [matriz + rcx],' '
    dec     byte[turno]    
    ret 



errorMovimientoOca:
    mov     rdi,msjError
    mPuts 
    jmp      errorMovOca

noOca:
    mov     rdi,msjNoHayOca
    mPuts
    jmp     errorMovOca