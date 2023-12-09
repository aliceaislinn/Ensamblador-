Page 60, 132
Title Reloj con macros 
.286
.model small
.stack 64

;=================================macroinstrucciones=================================; 
	inicia macro 
		mov ax, @data
		mov ds, ax
		mov es, ax
	endm
	
	termina macro
		call clrscr
		mov ax, 4C00h
		int 21h
		ret
	endm
	
	hacerCasts macro
		;cast de horas
		xor ax, ax
		mov al, ch
		push ax
		;llamando a hacer cast
		call num2char
		
		;cast de minutos
		xor ax, ax
		mov al, cl
		push ax
		;llamando a hacer cast
		call num2char
		
		;cast de segundos
		xor ax, ax
		mov al, dh
		push ax
		;llamando a hacer cast
		call num2char
		
		;cast de centésimas de segundos
		xor ax, ax
		mov al, dl
		push ax
		;llamando a hacer cast
		call num2char
	endm
	
;=======================================datos=======================================; 
.data
	; Reloj
	cadReloj0 db 'HH:MM:SS:CS$'
	cadReloj1 db 'HH : MM : SS : CS$'
	cadReloj2 db 'HH  :  MM  :  SS  :  CS$'
	cadReloj3 db 'HH   :   MM   :   SS   :   CS$'
	cadReloj4 db 'HH    :    MM    :    SS    :    CS$'
	cadReloj5 db 'HH     :     MM     :     SS     :     CS$'
	cadReloj6 db 'HH      :      MM      :      SS      :      CS$'
	cadReloj7 db 'HH       :       MM       :       SS       :       CS$'
	cadReloj8 db 'HH        :        MM        :        SS        :        CS$'
	cadReloj9 db 'HH         :         MM         :         SS         :         CS$'
	inicioCadena dw 0 ; guarda el inicio de la cadena a imprimir
	colInicio db 0 ; guarda la columna donde dibuja
	cadena dw 0 ; direccion de la cadena a usar
	ten equ 10
	
	; Espacios en Reloj
	espacio db 0
	resEsp dw 3 ;default
	
	; Marco
	ren dw 7
	col dw 32
	tamren equ 17 ;w
	tamcol equ 9 ;h
	negro equ 00Fh ;fuente blanca, fondo negro
	azul equ 01Eh ;fuente amarilla, fondo azul
	verde equ 02Fh ;fuente blanca, fondo verde
	rojo equ 040h ;fuente negra, fondo rojo
	colorespacio db 0 ;espacio que almacena el color
	colorguardado db 00Fh ;almacena el color previo (comando s)
	rensig dw 0
	colsig dw 0
	memoria db 0 ;para recuperar el valor de cl (loop)
	
	; Teclas
	a equ 01Eh
	b equ 030h
	v equ 02Fh
	r equ 013h
	o equ 018h
	s equ 01Fh

;=======================================principal=======================================; 
.code
	Principal proc far
		inicia
		call clrscr
		;color de marco original:
		mov [colorespacio], negro
		call marco
		
		anima:
			call reloj
			; comprobar tecla
			in al,60h
			cmp al,01h ;esc
			jne compMarcoAzul
			jmp salir ;va a la etiqueta que sale del programa
			
			;comandos para cambiar colores
			compMarcoAzul:
				cmp al, b
				;compara con b, si no es igual compara con v
				jne compMarcoVerde
				call clrscr
				mov [espacio], 0 ;reloj sin espacios
				mov [colorespacio], azul ;guarda el azul
				call marco ;construye marco con el azul
				jmp anima
			compMarcoVerde:
				cmp al, v
				jne compMarcoRojo
				call clrscr
				mov [espacio], 0
				mov [colorespacio], verde
				call marco
				jmp anima
			compMarcoRojo:
				cmp al, r
				jne compMarcoNormal
				call clrscr
				mov [espacio], 0
				mov [colorespacio], rojo
				call marco
				jmp anima
			compMarcoNormal:
				cmp al, o
				jne compAnterior
				call clrscr
				mov [espacio], 0
				mov [colorespacio], negro
				call marco
				jmp anima
				
			;comando s
			compAnterior:
				cmp al, s
				jne compAnimacion
				call clrscr
				mov [espacio], 0
				mov al, [colorguardado]
				mov [colorespacio], al
				call marco
				jmp anima
				
			;comando a
			compAnimacion:
				cmp al, a
				jne ningunaTecla ;no se modifica nada
				mov al, [colorespacio] ;el color que tiene actualmente
				mov [colorguardado], al ;lo guarda en colorguardado
				call clrscr ;quita el marco
				mov [espacio], 1
				call reloj
				call timer
				mov [espacio], 2
				call reloj
				call timer
				mov [espacio], 3
				call reloj
				call timer
				mov [espacio], 4
				call reloj
				call timer
				mov [espacio], 5
				call reloj
				call timer
				mov [espacio], 6
				call reloj
				call timer
				mov [espacio], 7
				call reloj
				call timer
				mov [espacio], 8
				call reloj
				call timer
				mov [espacio], 9
				call clrscr
				
			ningunaTecla:
				jmp anima
		
		; Terminar programa
		salir:
			termina
	Principal endp

;=======================================procedimientos=======================================; 
	;Procedimiento para limpiar pantalla
	clrscr proc 
		mov ax,0002h 
		int 10h
		ret
	clrscr endp
	
	;Procedimiento para ubicar cursor
	ubicaCursor proc
		mov bp,sp
		xor ax,ax
		add bp, 4 ;suma 4 para llegar al primer valor insertado
		mov ah, 02h
		mov dh, [bp] ;renglon
		mov dl, [bp-2] ;columna
		int 10h
		ret 4
	ubicaCursor endp
	
	;Procedimiento para timer
	timer proc
		mov cx, 003H
		delRep:
			push cx
			mov cx, 0D090H
		delDec:
			dec cx
			jnz delDec ;salta a Delay Decrementa hasta que sea 0
			pop cx ;recupera valor inicial de cx
			dec cx ;decrementa el valor de cx inicial
			jnz delRep ;salta a Delay Repite hasta que el valor inicial de cx sea 0
			ret
	timer endp
	
	; Procedimiento para marco
	marco proc
		mov [ren], 7
		mov [col], 32
		mov ax, [ren]
		mov [rensig], ax
		inc [rensig]
		mov ax, [col]
		mov [colsig], ax
		inc [colsig]
		;ubicando cursor
		push [ren]
		push [col]
		call ubicaCursor
		;imprimiendo esquina del origen
		mov ah,09h
		mov bh,00;numero de pagina
		mov bl, [colorespacio]; atributo
		mov cx,01; Numero de caracteres
		mov al,0c9h ; esquina origen
		int 10h
		;co'= co+w+1
		add [col], tamren+1
		;ubicando cursor
		push [ren] ;re
		push [col] ;co'
		call ubicaCursor
		;imprimiendo segunda esquina
		mov ah,09h
		mov bh,00;numero de pagina
		mov bl, [colorespacio]; atributo
		mov cx,01; Numero de caracteres
		mov al,0bbh ; esquina
		int 10h
		;regresando a co original
		sub [col], tamren+1
		;re'=re+h+1
		add [ren], tamcol+1
		;ubicando cursor
		push [ren] ;re'
		push [col] ;co
		call ubicaCursor
		;imprimiendo tercera esquina
		mov ah,09h
		mov bh,00;numero de pagina
		mov bl, [colorespacio]; atributo
		mov cx,01; Numero de caracteres
		mov al,0c8h ; esquina 
		int 10h
		;co'= co+w+1
		add [col], tamren+1
		;ubicando cursor
		push [ren]
		push [col]
		call ubicaCursor
		;imprimiendo esquina destino
		mov ah,09h
		mov bh,00;numero de pagina
		mov bl, [colorespacio]; atributo
		mov cx,01; Numero de caracteres
		mov al,0bch ; esquina 
		int 10h
		push tamren ;w
		push tamcol ;h
		;escribiendo marcos verticales
		pop cx ; cx=9
		xor bx, bx
		;mov bl, 8
		MarcosVer:
			mov [memoria], cl
			push [rensig]
			push 32
			call ubicaCursor
			mov ah,09h
			mov bh,00;numero de pagina
			mov bl, [colorespacio]; atributo
			mov cx,01; Numero de caracteres
			mov al,0bah ; igual
			int 10h
			push [rensig]
			push 50
			call ubicaCursor
			mov ah,09h
			mov bh,00;numero de pagina
			mov bl, [colorespacio]; atributo
			mov cx,01; Numero de caracteres
			mov al,0bah ; igual
			int 10h
			inc [rensig]
			mov cl, [memoria]
			loop MarcosVer
		pop cx ;cx=17
		xor bx, bx
		;mov bl, 33 
		MarcosHor:
			mov [memoria], cl
			push 7
			push [colsig]
			call ubicaCursor
			mov ah,09h
			mov bh,00;numero de pagina
			mov bl, [colorespacio]; atributo
			mov cx,01; Numero de caracteres
			mov al,0cdh ; igual
			int 10h
			push 17
			push [colsig]
			call ubicaCursor
			mov ah,09h
			mov bh,00;numero de pagina
			mov bl, [colorespacio]; atributo
			mov cx,01; Numero de caracteres
			mov al,0cdh ; igual
			int 10h
			inc [colsig]
			mov cl, [memoria]
			loop MarcosHor
		ret
	marco endp

;============================================reloj============================================; 
	;Procedimiento para dibujar Reloj
	reloj proc
		mov al, [espacio] ;pone en al el valor actual de espacio
		
		;Determinar la cadena a usar de acuerdo con el número de espacios
		cmp al, 0
		jne saltar_a_1
		mov [cadena], offset cadReloj0 ;reloj original
		mov [colInicio], 36 ;posición original
		jmp etiEspaciado
		saltar_a_1:
			cmp al, 1
			jne saltar_a_2
			mov [cadena], offset cadReloj1
			mov [colInicio], 8
			jmp etiEspaciado
		saltar_a_2:
			cmp al, 2
			jne saltar_a_3
			mov [cadena], offset cadReloj2
			mov [colInicio], 8
			jmp etiEspaciado
		saltar_a_3:
			cmp al, 3
			jne saltar_a_4
			mov [cadena], offset cadReloj3
			mov [colInicio], 8
			jmp etiEspaciado
		saltar_a_4:
			cmp al, 4
			jne saltar_a_5
			mov [cadena], offset cadReloj4
			mov [colInicio], 8
			jmp etiEspaciado
		saltar_a_5:
			cmp al, 5
			jne saltar_a_6
			mov [cadena], offset cadReloj5
			mov [colInicio], 8
			jmp etiEspaciado
		saltar_a_6:
			cmp al, 6
			jne saltar_a_7
			mov [cadena], offset cadReloj6
			mov [colInicio], 8
			jmp etiEspaciado
		saltar_a_7:
			cmp al, 7
			jne saltar_a_8
			mov [cadena], offset cadReloj7
			mov [colInicio], 8
			jmp etiEspaciado
		saltar_a_8:
			cmp al, 8
			jne saltar_a_9
			mov [cadena], offset cadReloj8
			mov [colInicio], 8
			jmp etiEspaciado
		saltar_a_9:
			mov [cadena], offset cadReloj9
			mov [colInicio], 8
		
		; Calcular el espaciado
		etiEspaciado:
			;3+2*e (e=espacio)
			mov cx, 2
			mul cx ;en al está el # de espacios
			add al, 3
			mov ah, 0
			mov [resEsp], ax ;resEsp se pasa a construyeTiempo
		
		; Obteniendo dirección de cadena	
		mov si, [cadena]  ; offset cadena a usar
		mov [inicioCadena], si
		
		; Obtener tiempo del sistema
		call obtenerTiempo
		
		hacerCasts ;llamando a macro
		
		; Ubicando cursor
		push 12; re (en medio)
		mov cl, [colInicio]
		mov ch, 0
		push cx; col
		call ubicaCursor
		
		;esconder cursor
		mov ah, 01h
		mov cx, 02607h
		int 10h
		
		; Imprimir cadena
		call imprimeCad
		ret
	reloj endp
	
	;Procedimiento para cast de tiempo
	num2char proc
		mov bp, sp
		add bp, 2
		xor ax,ax
		mov al,[bp] ;guarda HH, MM, SS o CS
		mov bl,ten
		div bl
		xor ax,3030h; convirtiendo a ASCII
		;llamando a construir reloj
		call construyeTiempo
		ret 2 ;hace el pop automático
	num2char endp
	
	;procedimiento para obtener tiempo
	obtenerTiempo proc
		mov ah, 02ch
		int 21h
		ret
	obtenerTiempo endp
	
	;Procedimiento para construir tiempo
	construyeTiempo proc
		mov [si],al
		mov [si+1],ah
		add si, [resEsp]
		ret
	construyeTiempo endp
	
	;Procedimiento para imprimir Reloj
	imprimeCad proc
		mov dx, inicioCadena
		mov ah, 09h
		int 21h
		ret
	imprimeCad endp
	
	end Principal