
;********************************************************************************************************************************************************
;---------------- INICIO DE CODIGO DEL TECLADO-----------------------------------------------------------------------------------------------------------
;********************************************************************************************************************************************************
;Rutina que detecta las pulsaciones en teclado matricial, y despues de oprimidas
; 3 teclas guarda el resultado en la variable "vel"


CHECAR_KEYS
;Aqui se queda hasta que se presione una tecla
;	call delaytcl
;	movlw 0xFF
;	movwf tecla
	movlw d'2'
	movwf contKEYS

CHECAR_KEYS2
	; columnas en 0
	bcf PORTA,0
	bcf PORTA,1
	bcf PORTA,2
	call delaytcl 		;wait 20us
	movf PORTB,W,0 ; 	read PORTB
	andlw b'11110000' ; mask out unused bits
	xorlw b'11110000' ; are bits 2,1,0 all 1?
	bz CHECAR_KEYS2 ; 		if yes branch to ->
	nop 				; if not execute jump
	
	
;Una vez presionada la tecla va barriendo columna x columna cada renglon
CHECK_COL3 
	; Output a zero for column 3
	bsf PORTA,0
	bsf PORTA,1
	bcf PORTA,2
	call delaytcl 		; wait 20us
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'01110000' 	; mask out unused bits
CHECK_9 
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'01110000' 	; mask out unused bits
	xorlw b'01100000' 	; was the 9 button pressed
	bnz CHECK_6 		; if it was not 9 then check if it is 6
	movlw 0x09 			; if it was 9 load WREG = 9 and DONE!!
	movwf tecla
	goto FINteclado 	; jump to FINteclado
CHECK_6 
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'01110000' 	; mask out unused bits
	xorlw b'01010000' 	; was the 6 button pressed?
	bnz CHECK_3 		; if it was not 6 then check if it is 3
	movlw 0x06 			; if it was 6 load WREG = 6 and DONE!!
	movwf tecla
	goto FINteclado
CHECK_3 
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'01110000' 	; mask out unused bits
	xorlw b'00110000' 	; was the 3 button pressed?
	bnz CHECK_COL2 		; if it was not 3 then check the next COLUMN
	movlw 0x03 			; if it was 3 load WREG = 3 and DONE!!
	movwf tecla
	goto FINteclado
					
CHECK_COL2 
	; Output a zero for column 2
	bsf PORTA,0
	bcf PORTA,1
	bsf PORTA,2
	movwf PORTA,0 		; writing values to the PORT
	call delaytcl 		; wait 20us
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'11110000' 	; mask out unused bits
CHECK_8 
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'11110000' 	; mask out unused bits
	xorlw b'11100000' 	; was the 8 button pressed
	bnz CHECK_5 		; if it was not 8 then check if it is 5
	movlw 0x08 			; if it was 8 load WREG = 8 and DONE!!
	movwf tecla
	goto FINteclado 	; jump to FINteclado
CHECK_5 
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'11110000' 	; mask out unused bits
	xorlw b'11010000' 	; was the 5 button pressed?
	bnz CHECK_2 		; if it was not 5 then check if it is 2
	movlw 0x05 			; if it was 5 load WREG = 5 and DONE!!
	movwf tecla
	goto FINteclado
CHECK_2 
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'11110000' 	; mask out unused bits
	xorlw b'10110000' 	; was the 2 button pressed?
	bnz CHECK_0 		; if it was not 2 then check the next COLUMN
	movlw 0x02 			; if it was 2 load WREG = 2 and DONE!!
	movwf tecla
	goto FINteclado

CHECK_0 
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'11110000' 	; mask out unused bits
	xorlw b'01110000' 	; was the 2 button pressed?
	bnz CHECK_COL1 		; if it was not 2 then check the next COLUMN
	movlw 0x00 			; if it was 2 load WREG = 2 and DONE!!
	movwf tecla
	goto FINteclado

CHECK_COL1 
	; Output a zero for column 1
	bcf PORTA,0
	bsf PORTA,1
	bsf PORTA,2
	call delaytcl 		; wait 20us
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'01110000' 	; mask out unused bits
CHECK_7 
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'01110000' 	; mask out unused bits
	xorlw b'01100000' 	; was the 8 button pressed
	bnz CHECK_4 		; if it was not 8 then check if it is 5
	movlw 0x07 			; if it was 8 load WREG = 8 and DONE!!
	movwf tecla
	goto FINteclado 	; jump to FINteclado
CHECK_4 
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'01110000' 	; mask out unused bits
	xorlw b'01010000' 	; was the 5 button pressed?
	bnz CHECK_1 		; if it was not 5 then check if it is 2
	movlw 0x04 			; if it was 5 load WREG = 5 and DONE!!
	movwf tecla
	goto FINteclado
CHECK_1 
	movf PORTB,0,0 		; read PC -> WREG
	andlw b'01110000' 	; mask out unused bits
	xorlw b'00110000' 	; was the 2 button pressed?
	bnz FINteclado 		; if it was not 2 then check the next COLUMN
	movlw 0x01 			; if it was 2 load WREG = 2 and DONE!!
	movwf tecla
	goto FINteclado


FINteclado
;En las siguientes rutinas se convierten las 3 teclas por medio de multiplicaciones por 3, en el valor
;de 3 digitos que se desea:

	movlw 0x02
	cpfseq contKEYS
	bra tstcont1
	movff tecla,vel
	
tstcont1
	movlw 0x01
	cpfseq contKEYS
	bra tstcont0
	movf vel,w
	mullw d'10'
	movff PRODL,vel
	movf tecla,w
	addwf vel,f
tstcont0
	movlw 0x00
	cpfseq contKEYS
	bra contFINteclado
	movf vel,w
	mullw d'10'
	movff PRODL,vel
	movf tecla,w
	addwf vel,f

	bnov uniOK ; Si no hay overflow durante la suma, vel puede todavia estar >255
	movlw 0xFF 
	movwf vel  ; (si hay, entonces 255 -> vel)
uniOK 
	tstfsz PRODH ; Pero si PRODH = 0, entonces todo esta bien
	bra centKO
	bra centOK
centKO
	movlw 0xFF ; sino, pues 255 -> vel
	movwf vel
	clrf PRODH
centOK

;------	Aqui se envian los DATOS AL LCD-----
	
	movlw LINE2CENTER
	call LCD_CMD
	movf vel,w
	call dispwdec
	bra salKB
;-------------------------------------------
	
contFINteclado
	decf contKEYS

looploop ;Esta rutina se hace para eliminar los rebotes que ocurren al dejar una tecla presionada por mucho tiempo,
		 ; No sale de esta rutina hasta que se desoprime
	movf PORTB,w
	andlw b'11110000'
	movwf PORTBTEMP
	movlw b'11110000' ;Ninguna oprimida
	cpfseq PORTBTEMP
	bra looploop 
	
	call delay_rebote
	call delay_rebote
	call delay_rebote
	call delay_rebote
	call delay_rebote
	bra CHECAR_KEYS2

salKB
	call delay_rebote
	call delay_rebote
	call delay_rebote
	call delay_rebote
	call delay_rebote
	return




;------------------- desplegar en decimal--------------
dispwdec
	movwf wtmp
	call hex2dec
	movf cent,w
	addlw 0x30
	call LCD_CHAR	
	movf dec,w
	addlw 0x30
	call LCD_CHAR
	movf uni,w
	addlw 0x30
	call LCD_CHAR
	movf wtmp,w	
	return

;----------------- hex2dec routine----------------------
hex2dec
	movwf temp
	clrf uni
	clrf dec
	clrf cent
sup100
	movlw d'99'
	cpfsgt temp
	bra sup10
	movlw d'100'
	subwf temp,f
	incf cent
	bra sup100
sup10 movlw d'9'
	cpfsgt temp
	bra inf10
	movlw d'10'
	subwf temp,f
	incf dec
	bra sup10
inf10 tstfsz temp
	bra process
	bra salida
process decf temp
	incf uni
	bra inf10
salida return	





;----DELAY PARA ELIMINAR REBOTES DEL 4x3 KEYPAD------------
delay_rebote	
denuevo
	movlw 0xFF
	movwf contFF
decrementa
	dcfsnz contFF,f
	bra dec_78
	bra decrementa
dec_78
	dcfsnz cont78,f
	bra salida1
	bra denuevo
salida1
	movlw 0x4E
	movwf cont78
	return
;------------------------------------------------------------



;--------- DELAY 20microsegundos------------------------------
delaytcl
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	return 
;------------------------------------------------------------
;********************************************************************************************************************************************************
;---------------- FIN DE CODIGO DEL TECLADO---------------------------------------------------------------------------------------------------------------
;********************************************************************************************************************************************************

