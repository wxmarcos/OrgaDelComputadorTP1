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

%macro mHayOca 0 
    sub     rsp,8
    call    hayOca
    add     rsp,8
%endmacro

%macro mValidarFyC 0 
    sub     rsp,8
    call    validarFyC
    add     rsp,8
%endmacro

%macro mCasilleroVacio 0 
    sub     rsp,8
    call    casilleroVacio
    add     rsp,8
%endmacro

%macro mValidarLimTablero 0 
    mValidarFyC
    cmp     byte[inputValido],'S'
    jne     errorMovimiento
%endmacro

%macro mValidarLimAcorralamiento 0 
    mValidarFyC
    cmp     byte[inputValido],'S'
%endmacro

%macro mLimpieza 0 
    xor     rcx,rcx
    xor     rax,rax
    xor     rdi,rdi
    xor     rsi,rsi 
%endmacro


section	.data
    matriz      db  "#","#","O","O","O","#","#"
                db  "#","#","O","O","O","#","#"
                db  "O","O","O","O","O","O","O"
                db  "O"," "," "," "," "," ","O"
                db  "O"," "," ","X"," "," ","O"
                db  "#","#"," "," "," "," ","#"
                db  "#","#"," "," "," ","#","#",0
                                
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

    contador            dw  0
    turno               dw  0
    ocasCapturadas      dw  0

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
    completoMov             resb    1   ;S completo movimiento correctamente y N para no.
    finDelJuedo             resb    1   ;X sale e Y no.


section .text
main:
    ; Limpia la pantalla
    ; mov     rdi,cmdClear
    ; sub		rsp,8	
    ; call    system    
	; add		rsp,8	

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


errorMovZorro:
; Si el zorro come  o si hay un error de mov salta aca para mover otra vez.
comioZorro:
    sub     rsp,8
    call    turnoZorro
    add     rsp,8

    cmp     byte[finDelJuedo],'X'
    je      fin

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

    ; Chequear si el zorro comio una oca si es asi bifurca a main.
    xor     rcx,rcx
    mov     cl,byte[turno]
    cmp     cl,0
    je      main

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

    ; Se pide una opcion de movimiento, si es x sale y guarda la partida
    mov     byte[finDelJuedo],'N'
    mov     rdi,msgMovimientoZorro
    mPuts                       
    mov     rdi,inputMov
    mGets

    cmp     byte[inputMov],'X'
    je      comandoSalirYGuardar

    sub     rsp,8
    call    movimientoZorro   
    add     rsp,8

    cmp     byte[completoMov],'S'
    je      completoMovConExito

    mov     rdi,msjError
    mPuts 
    jmp     turnoZorro

; Fin del turno zorro.
completoMovConExito:
    ret

; Fin del juego guardar la partida y salir.
comandoSalirYGuardar:
    mov     byte[finDelJuedo],'X'
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BUCAR LA POSICION ACTUAL DEL ZORRO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
    mLimpieza
    ; Cargo las coordenadas del zorro.
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

    ; Si llega aca se ingreso algo no valido
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                        MOVIMIENTOS DEL ZORRO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER A LA IZQUIERDA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
izquierdaZorro:
    ; Validar si no me voy fuera de los limites del talero.
    dec     si 
    mValidarLimTablero

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    sub     rcx,1

    ; Valida la existencia de oca.
    mHayOca
    cmp     byte[inputValido],'S'
    je      verSiComeIzq
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx
    add     rcx,1
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    jmp     movValido

verSiComeIzq:
    ; Validar si no me voy fuera de los limites del talero.
    dec     si 
    mValidarLimTablero

    ; Valida si es un casillero distinto de vacio.
    sub     rcx,1
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    add     rcx,1
    mov     byte [matriz + rcx],' '
    add     rcx,1
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    jmp     movValido

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER A LA DERECHA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
derechaZorro:
   ; Validar si no me voy fuera de los limites del talero.
    inc     si 
    mValidarLimTablero

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    add     rcx,1

    ; Valida la existencia de oca.
    mHayOca
    cmp     byte[inputValido],'S'
    je      verSiComeDer
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx
    sub     rcx,1
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    jmp     movValido

verSiComeDer:
    ; Validar si no me voy fuera de los limites del talero.
    inc     si 
    mValidarLimTablero

    ; Valida si es un casillero distinto de vacio.
    add     rcx,1
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    sub     rcx,1
    mov     byte [matriz + rcx],' '
    sub     rcx,1
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    jmp     movValido

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER A LA ARRIBA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
arribaZorro:
    ; Validar si no me voy fuera de los limites del talero.
    dec     di
    mValidarLimTablero

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    sub     rcx,7

    ; Valida la existencia de oca.
    mHayOca
    cmp     byte[inputValido],'S'
    je      verSiComeArriba
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    add     rcx,7
    mov     [posZorro], rcx
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    jmp     movValido

verSiComeArriba:
    ; Validar si no me voy fuera de los limites del talero.
    dec     si 
    mValidarLimTablero

    ; Valida si es un casillero distinto de vacio.    
    sub     rcx,7
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    add     rcx,7
    mov     byte [matriz + rcx],' '
    add     rcx,7
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    jmp     movValido

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER A LA ABAJO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
abajoZorro:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di
    mValidarLimTablero

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    add     rcx,7

    ; Valida la existencia de oca.
    mHayOca
    cmp     byte[inputValido],'S'
    je      verSiComeAbajo
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    sub     rcx,7
    mov     [posZorro], rcx
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    jmp     movValido 

verSiComeAbajo:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di
    mValidarLimTablero

    ; Valida si es un casillero distinto de vacio.
    add     rcx,7
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    sub     rcx,7
    mov     byte [matriz + rcx],' '
    sub     rcx,7
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    jmp     movValido

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER DIAGONAL ARRIBA IZQUIERDA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diagonalArribaIzqZorro:   
    ; Validar si no me voy fuera de los limites del talero.
    dec     di
    dec     si
    mValidarLimTablero

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    sub     rcx,8

    ; Valida la existencia de oca.
    mHayOca
    cmp     byte[inputValido],'S'
    je      verSiComeArriIzqZorro
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    add     rcx,8
    mov     [posZorro], rcx
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    jmp     movValido 

verSiComeArriIzqZorro:
    ; Validar si no me voy fuera de los limites del talero.
    dec     di
    dec     si
    mValidarLimTablero

    sub     rcx,8
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    add     rcx,8
    mov     byte [matriz + rcx],' '
    add     rcx,8
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    jmp     movValido

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER DIAGONAL ARRIBA DERECHA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diagonalArribaDerZorro:
    ; Validar si no me voy fuera de los limites del talero.
    dec     di
    inc     si
    mValidarLimTablero

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    sub     rcx,6

    ; Valida si es un casillero distinto de vacio.
    mHayOca
    cmp     byte[inputValido],'S'
    je      verSiComeArriDerZorro
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    add     rcx,6
    mov     [posZorro], rcx
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    jmp     movValido 

verSiComeArriDerZorro:
    ; Validar si no me voy fuera de los limites del talero.
    dec     di
    inc     si
    mValidarLimTablero

    sub     rcx,6
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    add     rcx,6
    mov     byte [matriz + rcx],' '
    add     rcx,6
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    jmp     movValido

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER DIAGONAL ABAJO IZQUIERDA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diagonalAbajoIzqZorro:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di
    dec     si
    mValidarLimTablero

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    add     rcx,6

    ; Valida la existencia de oca.
    mHayOca
    cmp     byte[inputValido],'S'
    je      verSiComeAbajoIzqZorro
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    sub     rcx,6
    mov     [posZorro], rcx
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    jmp     movValido 

verSiComeAbajoIzqZorro:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di
    dec     si
    mValidarLimTablero
    add     rcx,6
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    sub     rcx,6
    mov     byte [matriz + rcx],' '
    sub     rcx,6
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    jmp     movValido

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER DIAGONAL ABAJO DERECHA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diagonalAbajoDerZorro:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di
    inc     si
    mValidarLimTablero

    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
    add     rcx,8

    ; Valida la existencia de oca.
    mHayOca
    cmp     byte[inputValido],'S'
    je      verSiComeAbajoDerZorro
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    sub     rcx,8
    mov     [posZorro], rcx
    mov     byte [matriz + rcx],' '

    inc     byte[turno]

    jmp     movValido 

verSiComeAbajoDerZorro:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di
    inc     si
    mValidarLimTablero

    add     rcx,8
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    mov     [posZorro], rcx

    sub     rcx,8
    mov     byte [matriz + rcx],' '
    sub     rcx,8
    mov     byte [matriz + rcx],' '

    inc     byte[ocasCapturadas]

    jmp     movValido


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VALIDACIONES DE MOVIMIENTOS DEL ZORRO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Se chequea si el casillero al que se mueve el zorro es vacio.
casilleroVacio:
    mov     byte[inputValido],'N'   
    cmp     byte [matriz + rcx],' '
    jne     pasoInvalido
    mov     byte[inputValido],'S'
    ret

; Se chequea si en el casillero al que quiere ir el zorro existe una oca.
hayOca:
    mov     byte[inputValido],'N'   
    cmp     byte [matriz + rcx],'O'
    jne     pasoInvalido
    mov     byte[inputValido],'S'
    ret

pasoInvalido:
    ret


; Estas dos funciones validan si realizo algun movimiento correcto.
movValido:
    mov     byte[completoMov],'S'
    ret 

errorMovimiento:
    mov     byte[completoMov],'N'
    ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONDICION VICTORIA OCAS POR ACORRALAMIENTO DEL ZORRO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
estaAcorralado:
    sub     rsp,8
    call    buscarZorro
    add     rsp,8

;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mLimpieza
    mov     sil,[posZorroCol]
    mov     dil,[posZorroFil]

    ; Valido por izq
    ; Valido limite de tablero
    dec     sil
    mValidarLimAcorralamiento
    jne     paso1

    ; Valido si es un casillero vacio.
    mov     rcx,[posZorro]
    dec     rcx
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado

    ; Valido si es una oca si no es vacio.
    mHayOca
    cmp     byte[inputValido],'S'
    jne     paso1

    ; Valido limite del tablero.
    dec     sil
    mValidarLimAcorralamiento
    jne     paso1

    ; Valido si es vacio entonces no esta acorralado.
    dec     rcx
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,

paso1:
    ret

noAcorralado:
    ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVIMIENTO DE LAS OCAS.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
turnoOcas:
    mov     byte[completoMov],'N'
    sub     rsp,8
    call    movimientoOca
    add     rsp,8   

    cmp     byte[completoMov],'S'
    je      completoMovConExito

    mov     rdi,msjError
    mPuts 

    jmp     turnoOcas

; Fin del turno oca.
completoMovConExitoOca:
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
    mLimpieza
    mov     sil,[colOca]
    mov     dil,[filOca]

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


noOca:
    mov     rdi,msjNoHayOca
    mPuts
    
    jmp     obtener_pos_ocas


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
    ; Validar si no me voy fuera de los limites del talero.
    dec     si 
    mValidarLimTablero

    mov     cx,[desplazOca]
    mov     al,[matriz + rcx]
    sub     rcx,1

    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    mov     [desplazOca], rcx
    add     rcx,1
    mov     byte [matriz + rcx],' '

    dec     byte[turno]

    jmp     movValido



derechaOca:
    ; Validar si no me voy fuera de los limites del talero.
    inc     si 
    mValidarLimTablero

    mov     cx,[desplazOca]
    mov     al,[matriz + rcx]
    add     rcx,1

    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    mov     [desplazOca], rcx
    sub     rcx,1
    mov     byte [matriz + rcx],' '

    dec     byte[turno]

    jmp     movValido


abajoOca:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di 
    mValidarLimTablero

    mov     cx,[desplazOca]
    mov     al,[matriz + rcx]
    add     rcx,7

    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimiento

    mov     byte [matriz + rcx], al
    sub     rcx,7
    mov     [desplazOca], rcx
    mov     byte [matriz + rcx],' '
    dec     byte[turno]    

    jmp     movValido



