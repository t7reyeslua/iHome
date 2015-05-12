#include "P18F4680.inc"

		CONFIG PBADEN = OFF
;VECTORES***********************************************************
		org 0x00
		goto MAIN

		org 0x08
		goto ISRhigh

		org 0x18
		goto ISRlow	


;TEXTOS PRE-ESTABLECIDOS PARA MOSTRAR EN LCD 2x16******************
	
		org 0x50

		  	  ;"----------------"
txtWELCOME	db "    iHOME v2    ",0x00 
txtSETtime	db "    SET TIME    ",0x00 
txtSETluces	 db " SET LIGHTSTIME ",0x00 
txtSETlucesA db " SET LIGHTSAUTO ",0x00
txtSETsys	db "   SET SYSTEM   ",0x00 
txtOK		db "       OK       ",0x00
txtAUTOon	db "    AUTO ON     ",0x00
txtAUTOoff	db "    AUTO OFF     ",0x00
txtIPSSWD   db " ENTER PASSWORD ",0x00 
txtALRMON	db "    ALARM ON    ",0x00 
txtALRMOFF	db "   ALARM OFF    ",0x00 
txtSISTON	db "   SYSTEM ON    ",0x00 
txtSISTOFF	db "   SYSTEM OFF   ",0x00 
txtBLANK    db "                ",0x00
txtBLANK4   db "    ",0x00
txtLUZ1ON	db "    LUZ: 1 ON   ",0x00
txtLUZ2ON	db "    LUZ: 2 ON   ",0x00
txtLUZ3ON	db "    LUZ: 3 ON   ",0x00
txtLUZ4ON	db "    LUZ: 4 ON   ",0x00
txtLUZ5ON	db "    LUZ: 5 ON   ",0x00
txtLUZ6ON	db "    LUZ: 6 ON   ",0x00
txtLUZ7ON	db "    LUZ: 7 ON   ",0x00
txtLUZ1OFF	db "    LUZ: 1 OFF  ",0x00
txtLUZ2OFF	db "    LUZ: 2 OFF  ",0x00
txtLUZ3OFF	db "    LUZ: 3 OFF  ",0x00
txtLUZ4OFF	db "    LUZ: 4 OFF  ",0x00
txtLUZ5OFF	db "    LUZ: 5 OFF  ",0x00
txtLUZ6OFF	db "    LUZ: 6 OFF  ",0x00
txtLUZ7OFF	db "    LUZ: 7 OFF  ",0x00
txtLUZ1		db "      LUZ 1     ",0x00
txtLUZ2		db "      LUZ 2     ",0x00
txtLUZ3		db "      LUZ 3     ",0x00
txtLUZ4		db "      LUZ 4     ",0x00
txtLUZ5		db "      LUZ 5     ",0x00
txtLUZ6		db "      LUZ 6     ",0x00
txtLUZ7		db "      LUZ 7     ",0x00
txtLUZall	db "   ALL LIGHTS   ",0x00

			  ;"    12:00:00    "


;PROGRAMA PRINCIPAL***************************************************

MAIN 
		;INICIALIZA
		call INIT_REGISTROS
	   	call INIT_PUERTOS
		call INITLCD
		call INIT_INTERR

		clrf CONTROL
		clrf CONTROL2

		

		;ESCRIBE TEXTO DE BIENVENIDA INICIAL
		movlw CLR_DISP			;limpia el LCd
		call LCD_CMD


idle	
		call HOMESCREEN
		call MUESTRA_HORA

;ACTICA DESACTIVA LOS PERMISOS PARA ACTIVAR ALARMA O SENSORES
;----------------		
		btfss INTCON3,INT2IE
		bra botonDENY
		bsf CONTROL2,allowALRMbutton
		bra permitirSENSOR	
botonDENY		
		bcf CONTROL2,allowALRMbutton
		
permitirSENSOR
		btfss INTCON, INT0IE
		bra sensorDENY
		bsf CONTROL2,allowSENSOR
		bra alSCHEDULER	
sensorDENY		
		bcf CONTROL2,allowSENSOR
;-----------------

alSCHEDULER
		;CHECA QUE HAY QUE HACER
		call SCHEDULER	
	
		bra idle;	;ESPERA POR INTERRUPCIONES mostrando la HORA

;FIN MAIN********************************************************




;INTERRUPT SERVICE ROUTINES**************************************

ISRhigh: ;ALARMA, TMR0
	btfss INTCON,TMR0IF 	;checa si fue el TMR0 -ha pasado un segundo-
	goto  intALARMA			;no fue el TMR0 checa si fue el el sensor de alarma

	 ;RUTINA DE INTERRUPCION del TMR0
	bcf INTCON,TMR0IF		;baja la BANDERA de su interrupcion
	call RELOAD_TMR     	;recarga el RELOJ
	call ACTUALIZA_HORA 	;actualiza registros de las horas
	
	btfss CONTROL,alarmaON 	;checa si se activó la alarma
	bra alarmaONrequest			;no está activada
	decfsz buzzCONT		   	;decrementa el contador {tiempo para que le permita ingresar el password sin que suene el buzzr}
	bra rethigh				;todavía no es cero
	bsf CONTROL,buzzerON	;se ha terminado el tiempo..levanta la bandera de que está encendido el bzzr
	bsf PORTE,0				;prende el buzzer
	movlw SEGUNDOS
	movwf buzzCONT			;recarga el contador para la proxima vez
	bra rethigh
	
alarmaONrequest
	btfss CONTROL,setALARMA;checa si se tiene que prender la alarma
	bra rethigh				;no
	decfsz alrmCONT			;checa si el alrmCONT ya es cero
	bra rethigh				;todavía no es cero
	bcf CONTROL,setALARMA	;baja la bandera..ya fue satisfecho el pedido
	bsf CONTROL2,alarmaACT	;subre la bandera de que la alarma está activada
	bsf INTCON, INT0IE		;HABILITA la deteccion de intrusos
	movlw SEGUNDOS
	movwf alrmCONT			;recarga el contador para la proxima vez
	
	movlw LINE2
	call LCD_CMD
	MOVLW UPPER txtALRMON	;escribe "ALARM ON"
	MOVWF TBLPTRU 			
	MOVLW HIGH  txtALRMON
	MOVWF TBLPTRH
	MOVLW LOW	txtALRMON
	MOVWF TBLPTRL 
	call WRITE_LCD
	;call DELAYtxt
	
		movlw LINE2
		call LCD_CMD

		MOVLW UPPER txtBLANK4	
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtBLANK4
		MOVWF TBLPTRH
		MOVLW LOW	txtBLANK4
		MOVWF TBLPTRL 
		call WRITE_LCD

		

	bra rethigh

	 ;RUTINA DE INTERRUPCION de INT0 : SE HA DETECTADO UN INTRUSO
intALARMA
	bcf INTCON,INT0IF    	;baja su bandera

	btfss CONTROL,sistemaON
	bra	rethigh				;si el sistema no está encendido no hagas nada

	btfss CONTROL2,allowSENSOR
	bra rethigh				;si la alarma no está activada no hagas nada
	bcf CONTROL2,allowSENSOR
	bcf INTCON, INT0IE		; INT0 DISABLE ..atiende esta	 
	bcf INTCON3, INT1IE 	; INT1 DISABLE..disble set mode hasta que se atienda al INTRUSO
	bsf CONTROL,alarmaON 	;al siguiente segundo haz que encienda la alarma
	bsf PORTA,0				;se prende el foco de la sala
rethigh
	retfie	


ISRlow: ;boton SET, boton ALARMAon
  	btfss INTCON3,INT1IF 	;checa si fue el boton SET
	goto  intBOTONalarma	;no fue el botonSET checa si fue el boton de alarma

	;RUTINA DE interrupcion del botonSET
intSET
	bcf	 	INTCON3,INT1IF
	call 	DELAY
	btfsc 	CONTROL,alarmaON
	bra 	retlow
 	btfss 	CONTROL,setREQUEST
	bsf  	CONTROL,setREQUEST ;activar bandera de que quieres entrar a SETMODE	
	bra	 	retlow

intBOTONalarma

	bcf	 INTCON3,INT2IF		;bajas su bandera
	call DELAY
	
	btfss CONTROL,sistemaON
	bra	retlow				;si el sistema no está encendido no hagas nada

	btfss CONTROL2,allowALRMbutton
	bra	retlow
	bcf  INTCON3,INT2IE		;DISABLE
	bsf CONTROL2,allowSENSOR
	bcf CONTROL,alarmaON
	bsf  CONTROL,setALARMA	;activar bandera de que quieres encender la alarma

retlow
	retfie 


;INCLUDES OTROS**************************************************
	#include "rutinasLCD.inc"
	#include "rutinasIHOME.inc"
	#include "rutinasINIT.inc"
		END	


