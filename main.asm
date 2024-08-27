global	main

extern	printf, puts, gets, sscanf, printMapa, system, leerMapa, guardarMapa

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

%macro mSscanf 4
    mov     rdi, %1
    mov     rsi, %2
    mov     rdx, %3
    mov     rcx, %4
    sub     rsp,8
    call    sscanf
    add     rsp,8
%endmacro

%macro mClearCmd 0
    mov     rdi,cmdClear
    sub		rsp,8	
    call    system    
	add		rsp,8
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
    jne     errorMovimientoZorro
%endmacro

%macro mValidarLimAcorralamiento 0 
    mValidarFyC
    cmp     byte[inputValido],'S'
%endmacro

%macro mIncTur 0 
    mLimpieza
    inc     byte[estadisticas]
%endmacro

%macro mDecTur 0 
    mLimpieza
    dec     byte[estadisticas]
%endmacro

%macro mIncEstadisticas 1 
    mLimpieza
    mov     rcx,%1
    inc     byte[estadisticas+rcx]
%endmacro

%macro mLimpieza 0 
    sub     rcx,rcx
    sub     rax,rax
    sub     rdi,rdi
    sub     rsi,rsi 
    sub     rbx,rbx
%endmacro

%macro mPrintInterfaz 0 
    ; Printea el mapa actualizado
    xor     rdi,rdi
    mov     rdi,matriz
    sub		rsp,8	
    call    printMapa    
	add		rsp,8	

    ; Printear cant de ocas capturadas hasta el momento
    mLimpieza
    mov     rdi, msjOcasCapturadas
    mov     rcx,1
    mov     sil, [estadisticas+rcx]
    mPrintf

    ; Printear opcion de guardar y salir.
    mov     rdi, msjGuardarYSalir
    mPrintf
%endmacro

%macro mLimpiarElementoMatrizAdd 1
    add     rcx,%1
    mov     byte [matriz + rcx],' '
%endmacro

%macro mLimpiarElementoMatrizSub 1
    sub     rcx,%1
    mov     byte [matriz + rcx],' '
%endmacro

%macro mValidarHayOcayCasilleroVacio 1
    ; Valida la existencia de oca.
    mHayOca
    cmp     byte[inputValido],'S'
    je      %1
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimientoZorro
%endmacro

%macro mCargarPosZorroYGuardarRCXAL 0 
    mov     rcx,[posZorro]
    mov     al,[matriz + rcx]
%endmacro


section	.data

    fileGuardado        db	"guardado.dat",0 
    fileNuevo		    db	"mapa.dat",0 

    msjBienvenida       db  "🦊 ¡Bienvenido al juego de el Zorro y las Ocas! 🦢",10,0

    msgMovimientoZorro  db  "Ingresar W (arriba), A (izquierda), S (abajo), D (derecha), Q (diagonal sup izq), E (diagonal sup der), Z (diagonal inf izq), C (diagonal inf der): ",0
    msjMovimientoOcas   db  "Ingrese A (izquierda), S (abajo), D (derecha)",0
    msjGuardarYSalir    db  "'X' para guardar partida y salir.",10,0
    msjIngFilCol	    db	"Ingrese fila (1 a 7) y columna (1 a 7) separados por un espacio para seleccionar la oca que quiera mover: ",0
    
    msjErrorInput       db  "Los datos ingresados son invalidos. Intente nuevamente.",0
    msjNoHayOca         db  "No hay una oca en esa posicion.",0
    msjError            db  "Error de movimiento",0
    msjOpcionCorrecta   db  "Porfavor ingrese una de las 2 opcione.",0

    msjTurnoZorro       db  10,"¡¡¡🦊 Es turno del zorro 🦊!!!",0
    msjTurnoOca         db  10,"¡¡¡🦢 Es turno de las Ocas 🦢!!!",0
    msjOcasCapturadas   db  10,"Cantidad de ocas capturadas 🦢: %hhi",10,0
    msjGanaZorro        db  10,"¡¡¡🦊 Gana el Zorro por capturar 12 ocas 🦊!!!",10,0 
    msjGanaOcas         db  10,"¡¡¡🦢 Ganan las ocas por acorralamiento 🦢!!!",10,0  
    msjGuardado         db  10,"¡¡¡La partida se guardo correctamente!!!",10,10,0

    msjCargarPartida    db  "¿Desea reanudar la partida anterior?",10
                        db  " 🗺️  'S' para cargar la partida anterior.",10
                        db  " 🆕 'N' para crear una partida nueva.",10,10
                        db  "Ingresa S o N segun desee: ",0

    msjEstadisticasZor  db  "Estadisticas del zorro 🦊: ",0
    vecMov			    db  "                        ",0
                        db  "                        ",0
                        db  "   Arriba               ",0
                        db  "   Izquierda            ",0
                        db  "   Abajo                ",0
                        db  "   Derecha              ",0
                        db  "   Diagonal superior izq",0
                        db  "   Diagonal superior der",0
                        db  "   Diagonal inferior izq",0
                        db  "   Diagonal inferior Der",0
                        
    formatEstadisticas	db	"%s - %hhi",10,0
    formatInputFilCol	db	"%hhi %hhi",0  
    formatString        db  "%hhi",0
    cmdClear            db  "clear",0


    ; Contador general.
    contador            dw  0

    ; Variables dimensiones del tablero.
    longFila            db  7

    desplazOca			dw	0


section .bss
    ; Resevados para Ocas.
    inputFilCol		        resb	50
   	filOca		            resw	1
	colOca       	        resw	1 	
    inputMovOca             resb    10

    ; Resevados para Zorro.
    inputMovZorro           resb    10
    posZorro                resb    50
    posZorroCol             resb    1
    posZorroFil             resb    1

    ; Uso general.
    completoMov             resb    1   ; S completo movimiento correctamente y N para no.
    inputAcorralado         resb    1   ; S si esta acorralado N si no.
    finDelJuedo             resb    1   ; X sale y N no.
    inputValido             resb    1   ; S valido N invalido

    charInt                 resb    2   ; Se usa para almacenar temporarmente un caracter entero a string.

    ; Sera una matriz 7x7 donde cada byte representa un elemento en el mapa
    ;matriz              db  "#","#"," "," "," ","#","#"
    ;                    db  "#","#"," "," "," ","#","#"
    ;                    db  " "," "," "," "," "," "," "
    ;                    db  " "," "," "," "," "," "," "
    ;                    db  " "," "," ","X"," "," "," "
    ;                    db  "#","#"," "," "," ","#","#"
    ;                    db  "#","#"," "," "," ","#","#",0
    matriz              resb 50
    ; Sera un vector con las estadisticas de la partida, turno, comidas, arr, izq, aba, der, dsi, dsd, dii, did.
    ;estadisticas        db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    estadisticas        resb 10  


section .text
main:    
    mClearCmd
    mov     rdi,msjBienvenida
    mPuts

verSiCargoPartida:
    mov     rdi,msjCargarPartida
    mPrintf
    mov     rdi,inputValido
    mGets

    cmp     byte[inputValido],'S'
    je      cargarPartidaGuardada

    cmp     byte[inputValido],'N'
    je      cargarPartidaNueva

    mov     rdi,msjOpcionCorrecta
    mPuts

    jmp     verSiCargoPartida

cargarPartidaGuardada: 

    ; CARGA EL MAPA GUARDADO.
    mov rdi,fileGuardado
    mov r12,estadisticas
    mov r13,matriz
    ; Leer mapa guardado. 
    sub		rsp,8	
    call    leerMapa    
	add		rsp,8	

    ; Veo quien era sl sig en mover antes de que termine la partida, si es 0 iba el zorro y si es 1 iban las ocas.
    xor     rcx,rcx
    mov     cl,byte[estadisticas]
    cmp     cl,1
    je      siguenOcas
    jmp     sigueZorro
cargarPartidaNueva:

    ; CARGA UN MAPA NUEVO.
    mov rdi,fileNuevo
    mov r12,estadisticas
    mov r13,matriz
    ; Leer mapa nuevo. 

    sub		rsp,8	
    call    leerMapa    
	add		rsp,8	

sigueZorro:
    ; Limpia la pantalla
    mClearCmd
    mPrintInterfaz

    mov     rdi,msjTurnoZorro
    mPuts
    sub     rsp,8
    call    turnoZorro
    add     rsp,8

    ; Chequea condicion fin por finalizar partida.
    cmp     byte[finDelJuedo],'X'
    je      guardarPartida

    mPrintInterfaz

    ; Chequea condicion de fin por captura de 12 ocas.
    mLimpieza
    mov     rcx,1
    mov     dil,[estadisticas+rcx]
    cmp     dil,12
    je      ganaZorro

    ; Chequear si el zorro comio una oca si es asi bifurca a main.
    xor     rcx,rcx
    mov     cl,byte[estadisticas]
    cmp     cl,0
    je      sigueZorro

siguenOcas:
    mClearCmd
    mPrintInterfaz
    
    ; Siguen las Ocas.
    mov     rdi,msjTurnoOca
    mPuts
    sub     rsp,8
    call    turnoOcas
    add     rsp,8

    ; Chequea condicion fin por finalizar partida.
    cmp     byte[finDelJuedo],'X'
    je      guardarPartida

    mPrintInterfaz

    ; Luego del movimiento de cada oca se chequea si el zorro esta acorralado.
    sub     rsp,8
    call    estaAcorralado
    add     rsp,8
    cmp     byte[inputAcorralado],'S'
    je      gananOcas

    jmp     sigueZorro


gananOcas:
    mClearCmd
    mPrintInterfaz
    mov     rdi, msjGanaOcas
    mPuts

    jmp fin

ganaZorro:
    mClearCmd
    mPrintInterfaz
    mov     rdi, msjGanaZorro
    mPuts

    jmp fin

    ; GUARDA EL MAPA ACTUAL
guardarPartida:
    ; Cargo mapa y estadisticas actuales.
    mov r12, estadisticas
    mov r13, matriz

    ;;Guardo mapa 
    sub		rsp,8	
    call    guardarMapa    
	add		rsp,8	

    mov     rdi, msjGuardado
    mPuts


fin:
    sub		rsp,8	
    call    mostrarEstadisticas    
	add		rsp,8	

    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                           RUTINAS INTERNAS.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOSTRAR ESTADISTICAS DEL ZORRO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mostrarEstadisticas:
    mov     rdi, msjEstadisticasZor
    mPuts

    ; Me pociciono en la primera estadistica.
    inc     byte[contador]
imprimirStats:
    mLimpieza
    inc     byte[contador]
	mov		cl,[contador]	        ;rcx = contador

	mov		al,[estadisticas+rcx]	        ; rax/al me guardo el num

	imul	bx,cx,25			    ; (contador)*longElem obtengo el string asociado a la pos

	mov		rdi,formatEstadisticas			   
    lea		rsi,[vecMov+rbx] 		; rsi dir str
	mov		rdx,rax	                ; rdx num asociado
	 
	mPrintf
    
    cmp     byte[contador],9
    jne     imprimirStats   

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MOVIMIENTOS DEL ZORRO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
turnoZorro:
    mov     byte[inputValido],'N' 
    sub     rsp,8
    call    buscarZorro
    add     rsp,8

    ; Se pide una opcion de movimiento, si es x sale y guarda la partida
    mov     byte[finDelJuedo],'N'
    mov     rdi,msgMovimientoZorro
    mPuts                       
    mov     rdi,inputMovZorro
    mGets

    cmp     byte[inputMovZorro],'X'
    je      comandoSalirYGuardar

    mov     byte[completoMov],'N'
    sub     rsp,8
    call    movimientoZorro   
    add     rsp,8

    cmp     byte[completoMov],'S'
    je      completoMovConExitoZorro

    mov     rdi,msjError
    mPuts 

    jmp     turnoZorro

; Fin del turno zorro.
completoMovConExitoZorro:
    ret

; Fin del juego guardar la partida y salir.
comandoSalirYGuardar:
    mov     byte[finDelJuedo],'X'
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BUCAR LA POSICION ACTUAL DEL ZORRO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
buscarZorro:
    mov     byte[contador],0 ; Establezco contador en 0

    sub     rsp,8
    call    buscarPosZorro
    add     rsp,8

    ret 

    ; Busco de forma iteratiba el zorro.
buscarPosZorro:
    xor     rcx,rcx
    mov     cx,[contador]
    mov     al,[matriz + rcx]
    cmp     al,'X'              ; Si no encontre el zorro incremento contador y repito.

    je      actualizarPosicion          
    inc     byte[contador]
    jmp     buscarPosZorro


    ; Actualizo la pos del zorro y su coordenada.
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

    cmp     byte[inputMovZorro],'A'
    je      izquierdaZorro

    cmp     byte[inputMovZorro],'D'
    je      derechaZorro

    cmp     byte[inputMovZorro],'W'
    je      arribaZorro

    cmp     byte[inputMovZorro],'S'
    je      abajoZorro

    cmp     byte[inputMovZorro],'Q'
    je      diagonalArribaIzqZorro

    cmp     byte[inputMovZorro],'E'
    je      diagonalArribaDerZorro

    cmp     byte[inputMovZorro],'Z'
    je      diagonalAbajoIzqZorro

    cmp     byte[inputMovZorro],'C'
    je      diagonalAbajoDerZorro

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

    mCargarPosZorroYGuardarRCXAL

    sub     rcx,1
    mValidarHayOcayCasilleroVacio verSiComeIzq

    mov     byte [matriz + rcx], al
    mLimpiarElementoMatrizAdd 1

    mIncTur
    mIncEstadisticas 3

    jmp     movValidoZorro

verSiComeIzq:
    ; Validar si no me voy fuera de los limites del talero.
    dec     si 
    mValidarLimTablero

    ; Valida si es un casillero distinto de vacio.
    sub     rcx,1
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al

    mLimpiarElementoMatrizAdd 1
    mLimpiarElementoMatrizAdd 1

    mIncEstadisticas 1
    mIncEstadisticas 3

    jmp     movValidoZorro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER A LA DERECHA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
derechaZorro:
   ; Validar si no me voy fuera de los limites del talero.
    inc     si 
    mValidarLimTablero

    mCargarPosZorroYGuardarRCXAL

    add     rcx,1
    mValidarHayOcayCasilleroVacio verSiComeDer

    mov     byte [matriz + rcx], al
    mLimpiarElementoMatrizSub 1

    mIncTur
    mIncEstadisticas 5    
    jmp     movValidoZorro

verSiComeDer:
    ; Validar si no me voy fuera de los limites del talero.
    inc     si 
    mValidarLimTablero

    ; Valida si es un casillero distinto de vacio.
    add     rcx,1
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al

    mLimpiarElementoMatrizSub 1
    mLimpiarElementoMatrizSub 1

    mIncEstadisticas 1
    mIncEstadisticas 5    
    jmp     movValidoZorro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER A LA ARRIBA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
arribaZorro:
    ; Validar si no me voy fuera de los limites del talero.
    dec     di
    mValidarLimTablero

    mCargarPosZorroYGuardarRCXAL

    sub     rcx,7
    mValidarHayOcayCasilleroVacio verSiComeArriba

    mov     byte [matriz + rcx], al
    mLimpiarElementoMatrizAdd 7

    mIncTur
    mIncEstadisticas 2

    jmp     movValidoZorro

verSiComeArriba:
    ; Validar si no me voy fuera de los limites del talero.
    dec     di 
    mValidarLimTablero

    ; Valida si es un casillero distinto de vacio.    
    sub     rcx,7
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al

    mLimpiarElementoMatrizAdd 7
    mLimpiarElementoMatrizAdd 7

    mIncEstadisticas 1
    mIncEstadisticas 2

    jmp     movValidoZorro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER A LA ABAJO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
abajoZorro:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di
    mValidarLimTablero

    mCargarPosZorroYGuardarRCXAL

    add     rcx,7
    mValidarHayOcayCasilleroVacio verSiComeAbajo

    mov     byte [matriz + rcx], al
    mLimpiarElementoMatrizSub 7

    mIncTur
    mIncEstadisticas 4

    jmp     movValidoZorro 

verSiComeAbajo:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di
    mValidarLimTablero

    ; Valida si es un casillero distinto de vacio.
    add     rcx,7
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al

    mLimpiarElementoMatrizSub 7
    mLimpiarElementoMatrizSub 7

    mIncEstadisticas 1
    mIncEstadisticas 4

    jmp     movValidoZorro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER DIAGONAL ARRIBA IZQUIERDA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diagonalArribaIzqZorro:   
    ; Validar si no me voy fuera de los limites del talero.
    dec     di
    dec     si
    mValidarLimTablero

    mCargarPosZorroYGuardarRCXAL

    sub     rcx,8 
    mValidarHayOcayCasilleroVacio verSiComeArriIzqZorro

    mov     byte [matriz + rcx], al

    mLimpiarElementoMatrizAdd 8

    mIncTur
    mIncEstadisticas 6

    jmp     movValidoZorro 

verSiComeArriIzqZorro:
    ; Validar si no me voy fuera de los limites del talero.
    dec     di
    dec     si
    mValidarLimTablero

    sub     rcx,8
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al

    mLimpiarElementoMatrizAdd 8
    mLimpiarElementoMatrizAdd 8

    mIncEstadisticas 1
    mIncEstadisticas 6

    jmp     movValidoZorro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER DIAGONAL ARRIBA DERECHA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diagonalArribaDerZorro:
    ; Validar si no me voy fuera de los limites del talero.
    dec     di
    inc     si
    mValidarLimTablero

    mCargarPosZorroYGuardarRCXAL

    sub     rcx,6
    mValidarHayOcayCasilleroVacio verSiComeArriDerZorro

    mov     byte [matriz + rcx], al
    mLimpiarElementoMatrizAdd 6

    mIncTur
    mIncEstadisticas 7    
    jmp     movValidoZorro 

verSiComeArriDerZorro:
    ; Validar si no me voy fuera de los limites del talero.
    dec     di
    inc     si
    mValidarLimTablero

    sub     rcx,6
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    mLimpiarElementoMatrizAdd 6
    mLimpiarElementoMatrizAdd 6

    mIncEstadisticas 1
    mIncEstadisticas 7    
    jmp     movValidoZorro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER DIAGONAL ABAJO IZQUIERDA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diagonalAbajoIzqZorro:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di
    dec     si
    mValidarLimTablero

    mCargarPosZorroYGuardarRCXAL

    add     rcx,6
    mValidarHayOcayCasilleroVacio verSiComeAbajoIzqZorro

    mov     byte [matriz + rcx], al
    mLimpiarElementoMatrizSub 6

    mIncTur
    mIncEstadisticas 8
    jmp     movValidoZorro 

verSiComeAbajoIzqZorro:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di
    dec     si
    mValidarLimTablero
    add     rcx,6
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al
    mLimpiarElementoMatrizSub 6
    mLimpiarElementoMatrizSub 6

    mIncEstadisticas 1
    mIncEstadisticas 8
    jmp     movValidoZorro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER DIAGONAL ABAJO DERECHA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diagonalAbajoDerZorro:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di
    inc     si
    mValidarLimTablero

    mCargarPosZorroYGuardarRCXAL

    add     rcx,8
    mValidarHayOcayCasilleroVacio verSiComeAbajoDerZorro

    mov     byte [matriz + rcx], al
    mLimpiarElementoMatrizSub 8

    mIncTur
    mIncEstadisticas 9    
    jmp     movValidoZorro 

verSiComeAbajoDerZorro:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di
    inc     si
    mValidarLimTablero

    add     rcx,8
    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimientoZorro

    mov     byte [matriz + rcx], al

    mLimpiarElementoMatrizSub 8
    mLimpiarElementoMatrizSub 8

    mIncEstadisticas 1
    mIncEstadisticas 9    
    jmp     movValidoZorro


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
movValidoZorro:
    mov     byte[completoMov],'S'
    ret 

errorMovimientoZorro:
    mov     byte[completoMov],'N'
    ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONDICION VICTORIA OCAS POR ACORRALAMIENTO DEL ZORRO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
estaAcorralado:
    sub     rsp,8
    call    buscarZorro
    add     rsp,8

acorrIzq: 
    ; Comenzamos verificando los casilleros a izq.
    mLimpieza
    mov     sil,[posZorroCol]
    mov     dil,[posZorroFil]

    ; Valido por izq
    ; Valido limite de tablero
    dec     sil
    mValidarLimAcorralamiento
    jne     acorrDer

    ; Valido si es un casillero vacio.
    mov     rcx,[posZorro]
    dec     rcx
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado

    ; Valido si es una oca si no es vacio.
    mHayOca
    cmp     byte[inputValido],'S'
    jne     acorrDer

    ; Valido limite del tablero.
    dec     sil
    mValidarLimAcorralamiento
    jne     acorrDer

    ; Valido si es vacio entonces no esta acorralado.
    dec     rcx
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado


acorrDer:
    mLimpieza
    mov     sil,[posZorroCol]
    mov     dil,[posZorroFil]

    ; Valido por der
    ; Valido limite de tablero
    inc     sil
    mValidarLimAcorralamiento
    jne     acorrArr

     ; Valido si es un casillero vacio.
    mov     rcx,[posZorro]
    inc     rcx
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado

    ; Valido si es una oca si no es vacio.
    mHayOca
    cmp     byte[inputValido],'S'
    jne     acorrArr

    ; Valido limite del tablero.
    inc    sil
    mValidarLimAcorralamiento
    jne     acorrArr

    ; Valido si es vacio entonces no esta acorralado.
    inc     rcx
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado


acorrArr:
    mLimpieza
    mov     sil,[posZorroCol]
    mov     dil,[posZorroFil]
    ; Valido por arr
    ; Valido limite de tablero
    dec     dil
    mValidarLimTablero
    jne     acorrAbj

    ; Valido si es un casillero vacio
    mov     rcx,[posZorro]
    sub     rcx,7
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     acorrAbj

    ; Valido si es una oca
    mHayOca
    cmp     byte[inputValido],'S'
    jne     acorrAbj

    ; Valido limite del tablero.
    dec     dil
    mValidarLimAcorralamiento
    jne     acorrAbj
    
    ; Valido si es vacio entonces no esta acorralado
    sub     rcx,7
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado


acorrAbj:
    mLimpieza
    mov     sil,[posZorroCol]
    mov     dil,[posZorroFil]

    ; Valido por abjo
    ; Valido limite de tablero
    inc     dil
    mValidarLimAcorralamiento
    jne     acorrDiagArrDer

    ; Valido si es un casillero vacio.
    mov     rcx,[posZorro]
    add     rcx,7
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado

    ; Valido si es una oca si no es vacio.
    mHayOca
    cmp     byte[inputValido],'S'
    jne     acorrDiagArrDer

    ; Valido limite del tablero.
    inc    dil
    mValidarLimAcorralamiento
    jne     acorrDiagArrDer

    ; Valido si es vacio entonces no esta acorralado.
    add     rcx,7
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado


acorrDiagArrDer:
    mLimpieza
    mov     sil,[posZorroCol]
    mov     dil,[posZorroFil]

    ; Valido por diagonal arriba derecha
    ; Valido limite de tablero
    inc     sil
    dec     dil
    mValidarLimAcorralamiento
    jne     acorrDiagArrIzq

    ; Valido si es un casillero vacio.
    mov     rcx,[posZorro]
    sub     rcx,6
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado

    ; Valido si es una oca si no es vacio.
    mHayOca
    cmp     byte[inputValido],'S'
    jne     acorrDiagArrIzq

    ; Valido limite del tablero.

    inc     sil
    dec     dil
    mValidarLimAcorralamiento
    jne     acorrDiagArrIzq

    ; Valido si es vacio entonces no esta acorralado.
    sub     rcx,6
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado



acorrDiagArrIzq:
    mLimpieza
    mov     sil,[posZorroCol]
    mov     dil,[posZorroFil]

    ; Valido por diagonal arr izq
    ; Valido limite de tablero
    dec     sil
    dec     dil
    mValidarLimAcorralamiento
    jne     acorrDiagAbjder

    ; Valido si es un casillero vacio.
    mov     rcx,[posZorro]
    sub     rcx,8
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado

    ; Valido si es una oca si no es vacio.
    mHayOca
    cmp     byte[inputValido],'S'
    jne     acorrDiagAbjder

    ; Valido limite del tablero.
    dec     sil
    dec     dil
    mValidarLimAcorralamiento
    jne     acorrDiagAbjder

    ; Valido si es vacio entonces no esta acorralado.
    sub     rcx,8
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado


acorrDiagAbjder:
    mLimpieza
    mov     sil,[posZorroCol]
    mov     dil,[posZorroFil]

    ; Valido por izq
    ; Valido limite de tablero
    inc     sil
    inc     dil
    mValidarLimAcorralamiento
    jne     acorrDiagAbjIzq

    ; Valido si es un casillero vacio.
    mov     rcx,[posZorro]
    add     rcx,8
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado

    ; Valido si es una oca si no es vacio.
    mHayOca
    cmp     byte[inputValido],'S'
    jne     acorrDiagAbjIzq

    ; Valido limite del tablero.
    inc     sil
    inc     dil
    mValidarLimAcorralamiento
    jne     acorrDiagAbjIzq

    ; Valido si es vacio entonces no esta acorralado.
    add     rcx,8
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado



acorrDiagAbjIzq:
    mLimpieza
    mov     sil,[posZorroCol]
    mov     dil,[posZorroFil]

    ; Valido por izq
    ; Valido limite de tablero
    dec     sil
    inc     dil
    mValidarLimAcorralamiento
    jne     estaAcorraladoTrue

    ; Valido si es un casillero vacio.
    mov     rcx,[posZorro]
    add     rcx,6
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado

    ; Valido si es una oca si no es vacio.
    mHayOca
    cmp     byte[inputValido],'S'
    jne     estaAcorraladoTrue

    ; Valido limite del tablero.
    dec     sil
    inc     dil
    mValidarLimAcorralamiento
    jne    estaAcorraladoTrue

    ; Valido si es vacio entonces no esta acorralado.
    dec     rcx
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    je      noAcorralado


estaAcorraladoTrue:
    mov     byte[inputAcorralado],'S'
    ret

noAcorralado:
    mov     byte[inputAcorralado],'N'
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVIMIENTO DE LAS OCAS.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
turnoOcas:
    mov     byte[finDelJuedo],'N'
    mov     byte[completoMov],'N'

    sub     rsp,8
    call    movimientoOca
    add     rsp,8   

    cmp     byte[inputFilCol],'X'
    je      comandoSalirYGuardar

    cmp     byte[inputMovOca],'X'
    je      comandoSalirYGuardar

    ; Verifico si pudo completar el movimiento.
    cmp     byte[completoMov],'S'
    je      completoMovConExitoOca

    mov     rdi,msjError
    mPuts 

    jmp     turnoOcas

; Fin del turno oca.
completoMovConExitoOca:
    ret

movimientoOca:
    ; Pido una oca del tablero.
    sub     rsp,8
    call    obtenerPosOcas
    add     rsp,8

    cmp     byte[inputFilCol],'X'
    je      finMovOca

    ; Pido un movimiento para la oca seleccionada.
    mov     rdi,msjMovimientoOcas
    mPuts                       
    mov     rdi,inputMovOca
    mGets

    cmp     byte[inputMovOca],'X'
    je      finMovOca

    ; Valido entrada.
    mLimpieza
    mov     sil,[colOca]
    mov     dil,[filOca]

    cmp     byte[inputMovOca],'A'
    je      izquierdaOca

    cmp     byte[inputMovOca],'D'
    je      derechaOca

    cmp     byte[inputMovOca],'S'
    je      abajoOca

finMovOca:
    ret


; Obtengo una pos de alguna oca de tablero de juego.
obtenerPosOcas:
	mov		rdi,msjIngFilCol
	call	mPrintf

    mov		rdi,inputFilCol	
    mGets    

    cmp     byte[inputFilCol],'X'
    je      entradaInvalida

    ; Valido la entrada de fila y columna.
    sub     rsp,8
    call    validarEntradaFyC
    add     rsp,8

    cmp     byte[inputValido],'N'
    je      ingresoInvalido

    sub     rdi,rdi
    sub     rsi,rsi

    ; Guardo la posicion X e Y de la oca seleccionada
    mov     rdi,[filOca]
    mov     rsi,[colOca]

    ; Validar si los estamos dentro de los limites del tablero.
    sub     rsp,8
    call    validarFyC
    add     rsp,8

    ; Si efectivamente lo estamos continuamos.
    cmp     byte[inputValido],'S'
    je      continuar

    ; Si no llamamos otra vez a obtener oca.
ingresoInvalido:
    mov     rdi,msjErrorInput
    mPuts

    jmp     obtenerPosOcas


    ; Calculo dezplazamiento y me fijo si en la posicion seleccionada hay una oca.
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

    ; Si no hay oca bifurco a obtener oca.
noOca:
    mov     rdi,msjNoHayOca
    mPuts
    
    jmp     obtenerPosOcas


    ; Valida si la entrada ingresado por usuario son 2 ints.
validarEntradaFyC:
    mov     byte[inputValido],'N'
    mSscanf inputFilCol, formatInputFilCol, filOca, colOca
    cmp     rax,2
    jl      entradaInvalida
    mov     byte[inputValido],'S'

entradaInvalida:
    ret


    ; Calcula el dezplazamiento en base a lo que el usuario ingreso y guarda el desplazamiento en desplazOca.
calcDesplaz:
    mov     word[desplazOca],0
	mov		ax,[filOca]			        ;ax = fil
	dec		ax						    ;fil-1
	imul	ax,1	                    ;(fil-1) * longElem
	imul	ax,7	                    ;(fil-1) * longElem * cantCol = (fil-1) * longFil

	mov		bx,ax				        ;bx = desplazOca en fil
	
	mov		ax,[colOca]			        ;ax = col
	dec		ax						    ;col-1
	imul	ax,1	                    ;(col-1) * longElem

	add		bx,ax				        ;bx = desplazOca total
    add     word[desplazOca], bx

    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                      MOVIMIENTOS DE LAS OCAS.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER A LA IZQUIERDA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
    jne     errorMovimientoOca

    mov     byte [matriz + rcx], al
    mLimpiarElementoMatrizAdd 1

    mDecTur

    jmp     movValidoOca


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER A LA DERECHA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
derechaOca:
    ; Validar si no me voy fuera de los limites del talero.
    inc     si 
    mValidarLimTablero

    mov     cx,[desplazOca]
    mov     al,[matriz + rcx]
    add     rcx,1

    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimientoOca

    mov     byte [matriz + rcx], al
    mLimpiarElementoMatrizSub 1

    mDecTur

    jmp     movValidoOca


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER A LA ABAJO.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
abajoOca:
    ; Validar si no me voy fuera de los limites del talero.
    inc     di 
    mValidarLimTablero

    mov     cx,[desplazOca]
    mov     al,[matriz + rcx]
    add     rcx,7

    ; Valida si es un casillero distinto de vacio.
    mCasilleroVacio
    cmp     byte[inputValido],'S'
    jne     errorMovimientoOca

    mov     byte [matriz + rcx], al
    mLimpiarElementoMatrizSub 7

    mDecTur    

    jmp     movValidoOca

; Estas dos funciones validan si realizo algun movimiento correcto.
movValidoOca:
    mov     byte[completoMov],'S'
    ret 

errorMovimientoOca:
    mov     byte[completoMov],'N'
    ret