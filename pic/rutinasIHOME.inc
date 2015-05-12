;VARIABLES**********************************************************

;OxOO - 0x04 SON DEL LCD

;CONFIGURACION Y CONTROL
CONTROL	  equ 0x05 ;REGISTRO CON BITS DE CONTROL
conLucesA equ 0x06 ;REGISTRO que indica si cada foco se prende a la media o a la hora
conLucesB equ 0x07 ;REGISTRO que indica si cada foco se apaga a la media o a la hora
conLucesAUTO equ 0x08;REGISTRO que indica si cada foco esta programado o no
luzAlrmOUT equ 0x09 ;REGISTRO que indica que luces deben estar prendidas
;HORA
hrHIGH	  equ 0x0A ;DECENAS de la HORA
hrLOW     equ 0x0B ;UNIDADES de la HORA
hrHIGHaux equ 0x2F
hrLOWaux  equ 0x30
minHIGHaux equ 0x31
minLOWaux equ 0x32
CONTROL2  equ 0x33
minHIGH   equ 0x0C ;DECENAS de los MINUTOS
minLOW    equ 0x0D ;UNIDADES de los MINUTOS
segHIGH   equ 0x0E ;DECENAS de los SEGUNDOS
segLOW    equ 0x0F ;UNIDADES de los SEGUNDOS
diaSemana equ 0x10 ;DIA de la semana en que se está
;FOCOS
f1hrHon	  equ 0x11	;hora de encendido de foco 1
f1hrLon	  equ 0x12
f1hrHoff  equ 0x13	;hora de apagado de foco 1
f1hrLoff  equ 0x14
f2hrHon	  equ 0x15	;hora de encendido de foco 2
f2hrLon	  equ 0x16
f2hrHoff  equ 0x17	;hora de apagado de foco 2
f2hrLoff  equ 0x18
f3hrHon	  equ 0x19	;hora de encendido de foco 3
f3hrLon	  equ 0x1A
f3hrHoff  equ 0x1B	;hora de apagado de foco 3
f3hrLoff  equ 0x1C
f4hrHon	  equ 0x1D	;hora de encendido de foco 4
f4hrLon	  equ 0x1E
f4hrHoff  equ 0x1F	;hora de apagado de foco 4
f4hrLoff  equ 0x20
f5hrHon	  equ 0x21	;hora de encendido de foco 5
f5hrLon	  equ 0x22
f5hrHoff  equ 0x23	;hora de apagado de foco 5
f5hrLoff  equ 0x24
f6hrHon	  equ 0x25	;hora de encendido de foco 6
f6hrLon	  equ 0x26
f6hrHoff  equ 0x27	;hora de apagado de foco 6
f6hrLoff  equ 0x28
f7hrHon	  equ 0x29	;hora de encendido de foco 7
f7hrLon	  equ 0x2A
f7hrHoff  equ 0x2B	;hora de apagado de foco 7
f7hrLoff  equ 0x2C
;Contadores
buzzCONT  equ 0x2D	;contador de segundos entre disparo de alarma y del buzzer
alrmCONT  equ 0x2E	;contador de segundos entre botonazo de alarma encendida y activación de alrm	 
;TECLADO
tecla 	  equ 0x34
contKEYS  equ 0x35
vel		  equ 0x36
PORTBTEMP equ 0x37
contFF	  equ 0x38
cont78	  equ 0x39
password  equ 0x3A
passTRY	  equ 0x3B
temp	  equ 0x3C
uni  	  equ 0x3D
dec		  equ 0x3E
cent	  equ 0x3F
wtmp	  equ 0x40

;ETIQUETAS**********************************************************

;CONTROL REGISTER
sistemaON  equ 0
alarmaON   equ 1
buzzerON   equ 2
setREQUEST equ 3
setALARMA  equ 4
mediaHORA  equ 5
fullHORA   equ 6
passwdOK   equ 7

;CONTROL2 REGISTER
alarmaACT equ 0
allowSENSOR equ 1
allowALRMbutton equ 2
checandoLUCES equ 3

botonSET   equ 1
botonNEXT  equ 3

SEGUNDOS   equ d'10'


;RUTINAS**************************************************************

INIT_REGISTROS:
		movlw '0'; '0'
		movwf segLOW
		movwf segHIGH
		movwf minLOW
		movwf minHIGH
		movwf hrLOW
		movwf hrHIGH		;hora default en el que inicia es 00:00:00

		movwf f1hrHon   	;hora de encendido de foco 1
		movwf f1hrLon	  
		movwf f1hrHoff  	;hora de apagado de foco 1
		movwf f1hrLoff  
		movwf f2hrHon	    ;hora de encendido de foco 2
		movwf f2hrLon	  
		movwf f2hrHoff  	;hora de apagado de foco 2
		movwf f2hrLoff  
		movwf f3hrHon	  	;hora de encendido de foco 3
		movwf f3hrLon	  
		movwf f3hrHoff  	;hora de apagado de foco 3
		movwf f3hrLoff  
		movwf f4hrHon	  	;hora de encendido de foco 4
		movwf f4hrLon	  
		movwf f4hrHoff  	;hora de apagado de foco 4
		movwf f4hrLoff  
		movwf f5hrHon	  	;hora de encendido de foco 5
		movwf f5hrLon		  
		movwf f5hrHoff  	;hora de apagado de foco 5
		movwf f5hrLoff  
		movwf f6hrHon	  	;hora de encendido de foco 6
		movwf f6hrLon	  
		movwf f6hrHoff  	;hora de apagado de foco 6
		movwf f6hrLoff  
		movwf f7hrHon	  	;hora de encendido de foco 7
		movwf f7hrLon	  
		movwf f7hrHoff  	;hora de apagado de foco 7
		movwf f7hrLoff  
			


		clrf CONTROL		;no hay nada programado
		clrf CONTROL2
		setf luzAlrmOUT		;luces y alarma apagados
		setf PORTC
		clrf conLucesA
		clrf conLucesB
		clrf conLucesAUTO

		movlw SEGUNDOS		;inicializa el contador de segundos
		movwf buzzCONT
		movwf alrmCONT

		movlw 0x08
		movwf password		;PASSWORD DEFAULT: d'15'

		return
;********************************************************************************************		
MUESTRA_HORA:

		movlw LINE2CENTER 	;posiciona el CURSOR en (2,4)
		call  LCD_CMD
		
		movf hrHIGH,0		;escribe HORAS
		call LCD_CHAR
		movf hrLOW,0
		call LCD_CHAR
		movlw ':'
		call LCD_CHAR
		
		movf minHIGH,0		;escribe MINUTOS
		call LCD_CHAR
		movf minLOW,0
		call LCD_CHAR
		movlw ' '
		call LCD_CHAR
		
		movlw '0'
		cpfsgt hrHIGH
		bra escribeA
		movlw '2'
		cpfslt hrHIGH
		bra escribeP
		movlw '1'
		cpfsgt hrLOW
		bra escribeA

escribeP
		movlw 'P'
		call LCD_CHAR
		bra escribeM
	
escribeA
		movlw 'A'
		call LCD_CHAR	

escribeM
		movlw 'M'
		call LCD_CHAR

		return

MUESTRA_HORA2:

		movlw LINE2CENTER 	;posiciona el CURSOR en (2,4)
		call  LCD_CMD
		
		movf INDF0,0		;escribe HORAS
		call LCD_CHAR
		movf INDF1,0
		call LCD_CHAR
		movlw ':'
		call LCD_CHAR
		
		return

;********************************************************************************************
ACTUALIZA_HORA:
	;SEGUNDOS
		incf segLOW			;incrementa unidades seg:segLOW
		movlw ':'           ; checa si pasó de 9 a ":" y tiene que ser 0
		cpfseq segLOW
		bra salACTUALIZA_HORA ;no se pasó
		movlw '0'			;pon en cero segLOW
		movwf segLOW

		incf segHIGH		;incrementa decenas seg:segHigH
		movlw '6'			;checa si se pasó
		cpfseq segHIGH
		bra salACTUALIZA_HORA ;no se pasó
		movlw '0'			;pone en cero segHIGH
		movwf segHIGH

	;MINUTOS
		incf minLOW			;incrementa unidades min:minLOW
		movlw ':'			;checa si pasó de 9 a ":" y tiene que ser 0
		cpfseq minLOW
		bra salACTUALIZA_HORA ;no se pasó
		movlw '0'			;pone en cero minLOW
		movwf minLOW

		incf minHIGH		;incrementa decenas min:minLOW
		movlw '6'			;checa si se pasó
		cpfseq minHIGH
		bra salACTUALIZA_HORA ;no se pasó
		movlw '0'			;pon en cero minHIGH
		movwf minHIGH
	
	;HORAS
		incf hrLOW
		movlw ':'
		cpfseq hrLOW		;si son iguales entonces eras las 09 o las 19
		bra checaFINdelDIA
		movlw '0'			;incrementa a 10 o a 20			
		movwf hrLOW
		incf hrHIGH
		bra salACTUALIZA_HORA

checaFINdelDIA
		movlw '2'			;si las decenas son '2'
		cpfseq hrHIGH
		bra salACTUALIZA_HORA	;si las decenas no son 2 pues salte
		movlw '4'			;si ya son las 23
		cpfseq hrLOW
		bra incHrHIGH		;todavías no son las 23
		movlw '0'			;cambio de Día
		movwf hrLOW
		movwf hrHIGH		;00:00:00

		bra salACTUALIZA_HORA	;no estás en el 'octavo'dia

incHrHIGH
		incf hrHIGH		

salACTUALIZA_HORA
		return
		
;********************************************************************************************
SCHEDULER
		call prendeApagaFocos
		
		tstfsz CONTROL
		bra checaTASKS
		bra	salSCHEDULER 		;no hay nada que hacer
	
checaTASKS
		
		btfsc CONTROL,setREQUEST; checa si se quiere entran al SETMODE
		call SETMODE
		btfss CONTROL,sistemaON	;checa si esta activado el sistema
		bra salSCHEDULER		;no está activado..salte
		btfsc CONTROL,alarmaON	;checa si se activó la alarma
		call checaALARMA
		
		movlw '0'				;checa si son las xx:30 o las xx:00
		cpfseq minLOW
		bra salSCHEDULER		;minLow es diferente de '0'
		cpfseq minHIGH
		bra checaSIson30
		bsf CONTROL,fullHORA	;enciende BANDERA de que son las xx:00
		bra aLucesTSKS	 		;si es xx:00
checaSIson30
		movlw '3'
		cpfseq minHIGH			;si son iguales entonces son las xx:30 y se salta la prox
		
		bra salSCHEDULER
		bsf CONTROL,mediaHORA	;enciende BANDERA de que son las xx:30
		
aLucesTSKS
		bsf CONTROL2,checandoLUCES
		call lucesTASKS			;checa si hay que cambiar el ESTADO de ALGUN FOCO
		bcf CONTROL2,checandoLUCES
salSCHEDULER
		bsf INTCON3, INT1IE ; INT1 ENABLE
		return

;********************************************************************************************
lucesTASKS
		;f1On
		

		btfss	conLucesAUTO,1	;checa si está activado la automatización del foco1
  		bra f2On				;no está activado el fx..checa el sig

		movf hrHIGH,0
  		cpfseq f1hrHon			;checa si la hrH coincide con el fxonHigh
		bra f1Off				;no coinciden la hrON checa el fxOff
		movf hrLOW,0			;si coinciden las hrHigh..checa las hrLow
		cpfseq f1hrLon 
		bra f1Off				;tampoco coincidieron..checa su hrOff
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f1Onmedia			;no son las xx:00		
		btfss conLucesA,1 		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bcf luzAlrmOUT,6		;si se tiene que prender!
		bra f1Off				;son las xx:00 y no se tiene que prender
f1Onmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA	
		bcf luzAlrmOUT,6		;si se tiene que prender!	

f1Off	movf hrHIGH,0
		cpfseq f1hrHoff			;checa si la hrH coincide con el fx0ffHigh
		bra f2On				;no coincide..checa el sig
		movf hrLOW,0 		;si coinciden..checa las hrLow
		cpfseq f1hrLoff
		bra f2On				;tampoco coincidieron	
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f1Offmedia	
		btfss conLucesB,1		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bsf luzAlrmOUT,6		;si se tiene que apagar!
		bra f2On				;si son las xx:00 y no se tiene que apagar
f1Offmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA
		bsf luzAlrmOUT,6		;sí se tiene que apagar
 ;***************
f2On    btfss	conLucesAUTO,2	;checa si está activado la automatización del focoX
  		bra f3On				;no está activado el fx..checa el sig

		movf hrHIGH,0
  		cpfseq f2hrHon			;checa si la hrH coincide con el fxonHigh
		bra f2Off				;no coinciden la hrON checa el fxOff
		movf hrLOW,0			;si coinciden las hrHigh..checa las hrLow
		cpfseq f2hrLon 
		bra f2Off				;tampoco coincidieron..checa su hrOff
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f2Onmedia			;no son las xx:00		
		btfss conLucesA,2 		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bcf luzAlrmOUT,0		;si se tiene que prender!
		bra f2Off				;son las xx:00 y no se tiene que prender
f2Onmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA	
		bcf luzAlrmOUT,0		;si se tiene que prender!	

f2Off	movf hrHIGH,0
		cpfseq f2hrHoff			;checa si la hrH coincide con el fx0ffHigh
		bra f3On				;no coincide..checa el sig
		movf hrLOW,0 		;si coinciden..checa las hrLow
		cpfseq f2hrLoff
		bra f3On				;tampoco coincidieron	
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f2Offmedia	
		btfss conLucesB,2		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bsf luzAlrmOUT,0		;si se tiene que apagar!
		bra f3On				;si son las xx:00 y no se tiene que apagar
f2Offmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA
		bsf luzAlrmOUT,0		;sí se tiene que apagar
 ;***************
f3On	btfss	conLucesAUTO,3	;checa si está activado la automatización del focoX
  		bra f4On				;no está activado el fx..checa el sig

		movf hrHIGH,0
  		cpfseq f3hrHon			;checa si la hrH coincide con el fxonHigh
		bra f3Off				;no coinciden la hrON checa el fxOff
		movf hrLOW,0			;si coinciden las hrHigh..checa las hrLow
		cpfseq f3hrLon 
		bra f3Off				;tampoco coincidieron..checa su hrOff
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f3Onmedia			;no son las xx:00		
		btfss conLucesA,3 		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bcf luzAlrmOUT,1		;si se tiene que prender!
		bra f3Off				;son las xx:00 y no se tiene que prender
f3Onmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA	
		bcf luzAlrmOUT,1		;si se tiene que prender!	

f3Off	movf hrHIGH,0
		cpfseq f3hrHoff			;checa si la hrH coincide con el fx0ffHigh
		bra f4On				;no coincide..checa el sig
		movf hrLOW,0 			;si coinciden..checa las hrLow
		cpfseq f3hrLoff
		bra f4On				;tampoco coincidieron	
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f3Offmedia	
		btfss conLucesB,3		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bsf luzAlrmOUT,1		;si se tiene que apagar!
		bra f4On				;si son las xx:00 y no se tiene que apagar
f3Offmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA
		bsf luzAlrmOUT,1		;sí se tiene que apagar
 ;***************
f4On    btfss	conLucesAUTO,4	;checa si está activado la automatización del focoX
  		bra f5On				;no está activado el fx..checa el sig

		movf hrHIGH,0
  		cpfseq f4hrHon			;checa si la hrH coincide con el fxonHigh
		bra f4Off				;no coinciden la hrON checa el fxOff
		movf hrLOW,0			;si coinciden las hrHigh..checa las hrLow
		cpfseq f4hrLon 
		bra f4Off				;tampoco coincidieron..checa su hrOff
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f4Onmedia			;no son las xx:00		
		btfss conLucesA,4 		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bcf luzAlrmOUT,2		;si se tiene que prender!
		bra f4Off				;son las xx:00 y no se tiene que prender
f4Onmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA	
		bcf luzAlrmOUT,2		;si se tiene que prender!	

f4Off	movf hrHIGH,0
		cpfseq f4hrHoff			;checa si la hrH coincide con el fx0ffHigh
		bra f5On				;no coincide..checa el sig
		movf hrLOW,0 		;si coinciden..checa las hrLow
		cpfseq f4hrLoff
		bra f5On				;tampoco coincidieron	
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f4Offmedia	
		btfss conLucesB,4		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bsf luzAlrmOUT,2		;si se tiene que apagar!
		bra f5On				;si son las xx:00 y no se tiene que apagar
f4Offmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA
		bsf luzAlrmOUT,2		;sí se tiene que apagar
 ;***************
f5On    btfss	conLucesAUTO,5	;checa si está activado la automatización del focoX
  		bra f6On				;no está activado el fx..checa el sig

		movf hrHIGH,0
  		cpfseq f5hrHon			;checa si la hrH coincide con el fxonHigh
		bra f5Off				;no coinciden la hrON checa el fxOff
		movf hrLOW,0			;si coinciden las hrHigh..checa las hrLow
		cpfseq f5hrLon 
		bra f5Off				;tampoco coincidieron..checa su hrOff
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f5Onmedia			;no son las xx:00		
		btfss conLucesA,5		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bcf luzAlrmOUT,3		;si se tiene que prender!
		bra f5Off				;son las xx:00 y no se tiene que prender
f5Onmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA	
		bcf luzAlrmOUT,3		;si se tiene que prender!	

f5Off	movf hrHIGH,0
		cpfseq f5hrHoff			;checa si la hrH coincide con el fx0ffHigh
		bra f6On				;no coincide..checa el sig
		movf hrLOW,0 		;si coinciden..checa las hrLow
		cpfseq f5hrLoff
		bra f6On				;tampoco coincidieron	
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f5Offmedia	
		btfss conLucesB,5		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bsf luzAlrmOUT,3		;si se tiene que apagar!
		bra f6On				;si son las xx:00 y no se tiene que apagar
f5Offmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA
		bsf luzAlrmOUT,3		;sí se tiene que apagar 
 ;***************
f6On    btfss	conLucesAUTO,6	;checa si está activado la automatización del focoX
  		bra f7On				;no está activado el fx..checa el sig

		movf hrHIGH,0
  		cpfseq f6hrHon			;checa si la hrH coincide con el fxonHigh
		bra f6Off				;no coinciden la hrON checa el fxOff
		movf hrLOW,0			;si coinciden las hrHigh..checa las hrLow
		cpfseq f6hrLon 
		bra f6Off				;tampoco coincidieron..checa su hrOff
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f6Onmedia			;no son las xx:00		
		btfss conLucesA,6		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bcf luzAlrmOUT,4		;si se tiene que prender!
		bra f6Off				;son las xx:00 y no se tiene que prender
f6Onmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA	
		bcf luzAlrmOUT,4		;si se tiene que prender!	

f6Off	movf hrHIGH,0
		cpfseq f6hrHoff			;checa si la hrH coincide con el fx0ffHigh
		bra f7On				;no coincide..checa el sig
		movf hrLOW,0 		;si coinciden..checa las hrLow
		cpfseq f6hrLoff
		bra f7On				;tampoco coincidieron	
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f6Offmedia	
		btfss conLucesB,6		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bsf luzAlrmOUT,4		;si se tiene que apagar!
		bra f7On				;si son las xx:00 y no se tiene que apagar
f6Offmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA
		bsf luzAlrmOUT,4		;sí se tiene que apagar 
 ;***************
f7On    btfss	conLucesAUTO,7	;checa si está activado la automatización del focoX
  		bra salLucesTASKS		;salte

		movf hrHIGH,0
  		cpfseq f7hrHon			;checa si la hrH coincide con el fxonHigh
		bra f7Off				;no coinciden la hrON checa el fxOff
		movf hrLOW,0			;si coinciden las hrHigh..checa las hrLow
		cpfseq f7hrLon 
		bra f7Off				;tampoco coincidieron..checa su hrOff
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f7Onmedia			;no son las xx:00		
		btfss conLucesA,7		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bcf luzAlrmOUT,5		;si se tiene que prender!
		bra f7Off				;son las xx:00 y no se tiene que prender
f7Onmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA	
		bcf luzAlrmOUT,5		;si se tiene que prender!	

f7Off	movf hrHIGH,0
		cpfseq f7hrHoff			;checa si la hrH coincide con el fx0ffHigh
		bra salLucesTASKS		;no coincide..salte
		movf hrLOW,0	 		;si coinciden..checa las hrLow
		cpfseq f7hrLoff
		bra salLucesTASKS		;tampoco coincidieron	
		btfss CONTROL,fullHORA	;checa si son las xx:00		
		bra f7Offmedia	
		btfss conLucesB,7		;sí son las xx:00..checa si fx se tiene que prender a las xx:00	
		bsf luzAlrmOUT,5		;si se tiene que apagar!
		bra salLucesTASKS		;si son las xx:00 y no se tiene que apagar
f7Offmedia						;checa si son las xx:30
		btfsc CONTROL,mediaHORA
		bsf luzAlrmOUT,5		;sí se tiene que apagar 

salLucesTASKS
		bcf CONTROL,fullHORA ;baja banderas
		bcf CONTROL,mediaHORA
		return
;********************************************************************************************

checaALARMA
		call checaPassword
		btfss CONTROL,passwdOK	;checa si ya se metio el psswd correcto
		bra	salPrendeAlarma

		
		movlw LINE2
		call LCD_CMD

		MOVLW UPPER txtALRMOFF	;escribe "ALARM OFF"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtALRMOFF
		MOVWF TBLPTRH
		MOVLW LOW	txtALRMOFF
		MOVWF TBLPTRL 
		call WRITE_LCD		
	
		
		movlw LINE2
		call LCD_CMD

		MOVLW UPPER txtBLANK4	
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtBLANK4
		MOVWF TBLPTRH
		MOVLW LOW	txtBLANK4
		MOVWF TBLPTRL 
		call WRITE_LCD		

		;call DELAYtxt
salPrendeAlarma
		return

;********************************************************************************************
checaPassword
		movlw CLR_DISP			;limpia el LCd
		call LCD_CMD
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtIPSSWD	;escribe "ENTER PASSWORD"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtIPSSWD
		MOVWF TBLPTRH
		MOVLW LOW	txtIPSSWD
		MOVWF TBLPTRL 
		call WRITE_LCD

		movlw LINE2				;muevete a la linea 2
		call LCD_CMD

		bcf INTCON3, INT1E		;deshabilita el botonSET

		;pide al PASSWORD


loopPIDEpassword
		btfsc PORTB,botonNEXT
		bra loopPIDEpassword		;presioné NEXT
		call DELAY
		bsf CONTROL,passwdOK		;di que ya se ingresó el password correcto

		movlw LINE2
		call LCD_CMD

		MOVLW UPPER txtOK	
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtOK
		MOVWF TBLPTRH
		MOVLW LOW	txtOK
		MOVWF TBLPTRL 
		call WRITE_LCD

		;APAGA el BUZZ
		bsf INTCON3, INT1IE 	;INT1 ENABLE..otra vez puedes ir a un SETMODE
		bsf  INTCON3,INT2IE		;HABILITAS el poder activar la alarma
		bcf CONTROL,alarmaON	;baja la bandera de ALARMA
		bcf CONTROL2,alarmaACT  ;baja la bandera de que la alarma está activada
		bcf CONTROL,buzzerON	;baja la bandera del buzzer
		bcf PORTE,0				;calla al bzzr
		
		return


;********************************************************************************************
HOMESCREEN
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtWELCOME	;escribe "iHome v2"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtWELCOME
		MOVWF TBLPTRH
		MOVLW LOW	txtWELCOME
		MOVWF TBLPTRL 
		call WRITE_LCD
		return

;********************************************************************************************

SETMODE

		call clrLINE2
		movlw LINE1
		call LCD_CMD
		
		MOVLW UPPER txtSETtime		;ecribe "SET TIME"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtSETtime
		MOVWF TBLPTRH
		MOVLW LOW	txtSETtime
		MOVWF TBLPTRL 
		call WRITE_LCD
loopTIMEmenuSCREEN
		btfss PORTB,botonNEXT
		bra SYSTEMmenuSCREEN		;presioné NEXT
		btfsc PORTB,botonSET
		bra loopTIMEmenuSCREEN		;no he presionado OK  a "quiero setTIME"
		call DELAY
	
		;TIMEmenu

		call TIMEmenu
		bcf CONTROL,setREQUEST
		call clrLINE2

SYSTEMmenuSCREEN
		movlw LINE1
		call LCD_CMD
		
		MOVLW UPPER txtSETsys		;ecribe "SET SYSTEM"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtSETsys
		MOVWF TBLPTRH
		MOVLW LOW	txtSETsys
		MOVWF TBLPTRL 
		call WRITE_LCD
loopSYSTEMmenuSCREEN
		btfss PORTB,botonNEXT
		bra LIGHTSmenuSCREEN		;presioné NEXT
		btfsc PORTB,botonSET
		bra loopSYSTEMmenuSCREEN	;no he presionado OK  a "quiero setSYSTEM"
		call DELAY
		;SYSTEMmenu

		call SYSTEMmenu
		bcf CONTROL,setREQUEST
		call clrLINE2

LIGHTSmenuSCREEN
		movlw LINE1
		call LCD_CMD
		
		MOVLW UPPER txtSETluces		;ecribe "SET LIGHTSTIME"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtSETluces
		MOVWF TBLPTRH
		MOVLW LOW	txtSETluces
		MOVWF TBLPTRL 
		call WRITE_LCD
loopLIGHTSmenuSCREEN
		btfss PORTB,botonNEXT
		bra AUTOmenuSCREEN				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLIGHTSmenuSCREEN	;no he presionado OK  a "quiero setLIGHTS"
		call DELAY
		;LIGHTSmenu

		call LIGHTSmenu
		bcf CONTROL,setREQUEST
		call clrLINE2


AUTOmenuSCREEN
		movlw LINE1
		call LCD_CMD
		
		MOVLW UPPER txtSETlucesA		;ecribe "SET LIGHTSAUTO"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtSETlucesA
		MOVWF TBLPTRH
		MOVLW LOW	txtSETlucesA
		MOVWF TBLPTRL 
		call WRITE_LCD
loopAUTOmenuSCREEN
		btfss PORTB,botonNEXT
		bra salSETmode				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopAUTOmenuSCREEN	;no he presionado OK  a "quiero setLIGHTSAUTO"
		call DELAY
		;LIGHTSmenu

		call AUTOmenu
		bcf CONTROL,setREQUEST
		call clrLINE2


salSETmode
		bcf CONTROL,setREQUEST
		return

;******************************************************************************
AUTOmenu
		movlw DISP_ON_B			;ponle cursor bajo lo que escribes
		call LCD_CMD
;TODAS------------
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZall		;ecribe "LuZ i"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZall
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZall
		MOVWF TBLPTRL 
		call WRITE_LCD

		call clrLINE2
loopLUZallauto
		btfss PORTB,botonNEXT
		bra luz1AUTO			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZallauto		;no he presionado OK  
		call DELAY
		

luzallAUTOon
		call escribeAUTOon
				
loopLUZallautoONmenu
		btfss PORTB,botonNEXT
		bra luzallAUTOoff				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZallautoONmenu		;no he presionado OK  a "AUTO ON"
		call DELAY

		setf conLucesAUTO
		bra salSETauto

luzallAUTOoff
		call escribeAUTOoff
				
loopLUZallautoOFFmenu
		btfss PORTB,botonNEXT
		bra luzallAUTOon				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZallautoOFFmenu		;no he presionado OK  a "AUTO OFF"
		call DELAY

		clrf conLucesAUTO
		bra salSETauto

;-----LUZ1------
luz1AUTO
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ1		;ecribe "LuZ i"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ1
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ1
		MOVWF TBLPTRL 
		call WRITE_LCD

		call clrLINE2
loopLUZ1auto
		btfss PORTB,botonNEXT
		bra luz2AUTO			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ1auto		;no he presionado OK  
		call DELAY
		
		btfss conLucesAUTO,1
		bra  luz1AUTOoff

luz1AUTOon
		call escribeAUTOon
				
loopLUZ1autoONmenu
		btfss PORTB,botonNEXT
		bra luz1AUTOoff				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ1autoONmenu		;no he presionado OK  a "AUTO ON"
		call DELAY

		bsf conLucesAUTO,1
		bra luz2AUTO

luz1AUTOoff
		call escribeAUTOoff
				
loopLUZ1autoOFFmenu
		btfss PORTB,botonNEXT
		bra luz1AUTOon				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ1autoOFFmenu		;no he presionado OK  a "AUTO OFF"
		call DELAY

		bcf conLucesAUTO,1

;-----LUZ2------
luz2AUTO
		
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ2		;ecribe "LuZ i"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ2
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ2
		MOVWF TBLPTRL 
		call WRITE_LCD

		call clrLINE2
loopLUZ2auto
		btfss PORTB,botonNEXT
		bra luz3AUTO			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ2auto		;no he presionado OK  
		call DELAY
		
		btfss conLucesAUTO,2
		bra  luz2AUTOoff

luz2AUTOon
		call escribeAUTOon
				
loopLUZ2autoONmenu
		btfss PORTB,botonNEXT
		bra luz2AUTOoff				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ2autoONmenu		;no he presionado OK  a "AUTO ON"
		call DELAY

		bsf conLucesAUTO,2
		bra luz3AUTO

luz2AUTOoff
		call escribeAUTOoff
				
loopLUZ2autoOFFmenu
		btfss PORTB,botonNEXT
		bra luz2AUTOon				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ2autoOFFmenu		;no he presionado OK  a "AUTO OFF"
		call DELAY

		bcf conLucesAUTO,2

;-----LUZ3------
luz3AUTO
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ3		;ecribe "LuZ i"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ3
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ3
		MOVWF TBLPTRL 
		call WRITE_LCD

		call clrLINE2
loopLUZ3auto
		btfss PORTB,botonNEXT
		bra luz4AUTO			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ3auto		;no he presionado OK  
		call DELAY
		
		btfss conLucesAUTO,3
		bra  luz3AUTOoff

luz3AUTOon
		call escribeAUTOon
				
loopLUZ3autoONmenu
		btfss PORTB,botonNEXT
		bra luz3AUTOoff				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ3autoONmenu		;no he presionado OK  a "AUTO ON"
		call DELAY

		bsf conLucesAUTO,3
		bra luz4AUTO

luz3AUTOoff
		call escribeAUTOoff
				
loopLUZ3autoOFFmenu
		btfss PORTB,botonNEXT
		bra luz3AUTOon				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ3autoOFFmenu		;no he presionado OK  a "AUTO OFF"
		call DELAY

		bcf conLucesAUTO,3

;-----LUZ4------
luz4AUTO
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ4		;ecribe "LuZ i"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ4
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ4
		MOVWF TBLPTRL 
		call WRITE_LCD
		call clrLINE2
loopLUZ4auto
		btfss PORTB,botonNEXT
		bra luz5AUTO			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ4auto		;no he presionado OK  
		call DELAY
		
		btfss conLucesAUTO,4
		bra  luz4AUTOoff

luz4AUTOon
		call escribeAUTOon
				
loopLUZ4autoONmenu
		btfss PORTB,botonNEXT
		bra luz4AUTOoff				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ4autoONmenu		;no he presionado OK  a "AUTO ON"
		call DELAY

		bsf conLucesAUTO,4
		bra luz5AUTO

luz4AUTOoff
		call escribeAUTOoff
				
loopLUZ4autoOFFmenu
		btfss PORTB,botonNEXT
		bra luz4AUTOon				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ4autoOFFmenu		;no he presionado OK  a "AUTO OFF"
		call DELAY

		bcf conLucesAUTO,4

;-----LUZ5------
luz5AUTO
		movlw LINE1
		call LCD_CMD
		MOVLW UPPER txtLUZ5		;ecribe "LuZ i"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ5
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ5
		MOVWF TBLPTRL 
		call WRITE_LCD

		call clrLINE2
loopLUZ5auto
		btfss PORTB,botonNEXT
		bra luz6AUTO			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ5auto		;no he presionado OK  
		call DELAY
		
		btfss conLucesAUTO,5
		bra  luz5AUTOoff

luz5AUTOon
		call escribeAUTOon
				
loopLUZ5autoONmenu
		btfss PORTB,botonNEXT
		bra luz5AUTOoff				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ5autoONmenu		;no he presionado OK  a "AUTO ON"
		call DELAY

		bsf conLucesAUTO,5
		bra luz6AUTO

luz5AUTOoff
		call escribeAUTOoff
				
loopLUZ5autoOFFmenu
		btfss PORTB,botonNEXT
		bra luz5AUTOon				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ5autoOFFmenu		;no he presionado OK  a "AUTO OFF"
		call DELAY

		bcf conLucesAUTO,5

;-----LUZ6------
luz6AUTO
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ6		;ecribe "LuZ i"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ6
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ6
		MOVWF TBLPTRL 
		call WRITE_LCD
		call clrLINE2
loopLUZ6auto
		btfss PORTB,botonNEXT
		bra luz7AUTO			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ6auto		;no he presionado OK  
		call DELAY
		
		btfss conLucesAUTO,6
		bra  luz6AUTOoff

luz6AUTOon
		call escribeAUTOon
				
loopLUZ6autoONmenu
		btfss PORTB,botonNEXT
		bra luz6AUTOoff				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ6autoONmenu		;no he presionado OK  a "AUTO ON"
		call DELAY

		bsf conLucesAUTO,6
		bra luz7AUTO

luz6AUTOoff
		call escribeAUTOoff
				
loopLUZ6autoOFFmenu
		btfss PORTB,botonNEXT
		bra luz6AUTOon			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ6autoOFFmenu		;no he presionado OK  a "AUTO OFF"
		call DELAY

		bcf conLucesAUTO,6

;-----LUZ7------
luz7AUTO
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ7		;ecribe "LuZ i"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ7
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ7
		MOVWF TBLPTRL 
		call WRITE_LCD
		call clrLINE2
loopLUZ7auto
		btfss PORTB,botonNEXT
		bra salSETauto			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ7auto		;no he presionado OK  
		call DELAY
		
		btfss conLucesAUTO,7
		bra  luz7AUTOoff

luz7AUTOon
		call escribeAUTOon
				
loopLUZ7autoONmenu
		btfss PORTB,botonNEXT
		bra luz7AUTOoff				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ7autoONmenu		;no he presionado OK  a "AUTO ON"
		call DELAY

		bsf conLucesAUTO,7
		bra salSETauto

luz7AUTOoff
		call escribeAUTOoff
				
loopLUZ7autoOFFmenu
		btfss PORTB,botonNEXT
		bra luz7AUTOon				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ7autoOFFmenu		;no he presionado OK  a "AUTO OFF"
		call DELAY

		bcf conLucesAUTO,7

salSETauto
		movlw DISP_ON			;ponle cursor normal
		call LCD_CMD
		return




;******************************************************************************
TIMEmenu
		call MUESTRA_HORA

		LFSR FSR0, hrHIGH
		LFSR FSR1, hrLOW
		call FIJAHORA
		
		LFSR FSR0, minHIGH
		LFSR FSR1, minLOW
		call FIJAMINUTOS

		return
;******************************************************************************
SYSTEMmenu
		btfsc CONTROL,sistemaON		;checa el estado actual del SISTEMA		 
		bra	SYSTEMonMENU


SYSTEMoffMENU
		movlw LINE2
		call LCD_CMD

		MOVLW UPPER txtSISTOFF		;ecribe "SYSTEM OFF"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtSISTOFF
		MOVWF TBLPTRH
		MOVLW LOW	txtSISTOFF
		MOVWF TBLPTRL 
		call WRITE_LCD
loopSYSTEMOFFmenu
		btfss PORTB,botonNEXT
		bra SYSTEMonMENU			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopSYSTEMOFFmenu		;no he presionado OK  a "SYSTEM OFF"
		call DELAY
		;SiSTEMA OFF	
	
		
		;APAGAR ACTIVACIÓN DE ALARMA
		bcf INTCON3, INT2IE ; INT2 DISABLE ACTIVACIÖN DE ALARMA
		bcf CONTROL,sistemaON; bajar bandera de que el sistema está encendido
		

		bra salSYSTEMmenu

SYSTEMonMENU
		movlw LINE2
		call LCD_CMD

		MOVLW UPPER txtSISTON		;ecribe "SYSTEM ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtSISTON
		MOVWF TBLPTRH
		MOVLW LOW	txtSISTON
		MOVWF TBLPTRL 
		call WRITE_LCD
loopSYSTEMONmenu
		btfss PORTB,botonNEXT
		bra SYSTEMoffMENU			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopSYSTEMONmenu			;no he presionado OK  a "SYSTEM ON"
		call DELAY
		;SiSTEMA ON	
		
		;ENCENDER ACTIVACIÓN DE ALARMA
		bsf INTCON3, INT2IE ; INT2 ENABLE ACTIVACIÖN DE ALARMA
		bsf CONTROL,sistemaON; subir bandera de que el sistema está encendido

		bra salSYSTEMmenu

salSYSTEMmenu
		movlw DISP_ON			;pon otra vez sin cursor
		call LCD_CMD
		return


;******************************************************************************
LIGHTSmenu
		movlw DISP_ON_B			;ponle cursor bajo lo que escribes
		call LCD_CMD
	
;LUZ1************		
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ1ON		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ1ON
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ1ON
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f1hrHon
		LFSR FSR1,f1hrLon
		call MUESTRA_HORA2 			
	
		btfsc conLucesA,1
		bra	minl1on30
		call MIN00
		bra loopLUZ1ON
minl1on30
		call MIN30
		
		
loopLUZ1ON ;HORA
		btfss PORTB,botonNEXT
		bra LUZ1OFF					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ1ON				;no he presionado OK 
		call DELAY
		;LUZ1ON hr set	

		call FIJAHORA
loopLUZ1ONm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l1ON30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ1ONm		;no he presionado OK  
		bcf conLucesA,1			;luz1 ON a la xx:00
		call DELAY
		bra LUZ1OFF
l1ON30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ1ONm				;presioné NEXT..vuelve a l1ON:00
		btfsc PORTB,botonSET
		bra l1ON30				;no he presionado OK  
		bsf conLucesA,1			;luz1 ON a la xx:00
		call DELAY
		
LUZ1OFF
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ1OFF		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ1OFF
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ1OFF
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f1hrHoff
		LFSR FSR1,f1hrLoff
		call MUESTRA_HORA2 			
	
		btfsc conLucesB,1
		bra	minl1off30
		call MIN00
		bra loopLUZ1OFF
minl1off30
		call MIN30

		
loopLUZ1OFF
		btfss PORTB,botonNEXT
		bra LUZ2ON					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ1OFF				;no he presionado OK  
		call DELAY
		;LUZ1OFF set	
		call FIJAHORA
	
loopLUZ1OFFm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l1OFF30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ1OFFm		;no he presionado OK  
		bcf conLucesB,1			;luz1 OFF a la xx:00
		call DELAY
		bra LUZ2ON
l1OFF30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ1OFFm		;presioné NEXT
		btfsc PORTB,botonSET
		bra l1OFF30				;no he presionado OK  
		bsf conLucesB,1			;luz1 OFF a la xx:30
		call DELAY

;LUZ2***************		
LUZ2ON	movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ2ON		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ2ON
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ2ON
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f2hrHon
		LFSR FSR1,f2hrLon
		call MUESTRA_HORA2 			
	
		btfsc conLucesA,2
		bra	minl2on30
		call MIN00
		bra loopLUZ2ON
minl2on30
		call MIN30

loopLUZ2ON ;HORA
		btfss PORTB,botonNEXT
		bra LUZ2OFF					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ2ON				;no he presionado OK 
		call DELAY
		;LUZ1ON hr set	

		call FIJAHORA
loopLUZ2ONm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l2ON30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ2ONm		;no he presionado OK  
		bcf conLucesA,2			;luz1 ON a la xx:00
		call DELAY
		bra LUZ2OFF
l2ON30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ2ONm			;presioné NEXT
		btfsc PORTB,botonSET
		bra l2ON30				;no he presionado OK  
		bsf conLucesA,2			;luz1 ON a la xx:00
		call DELAY
		
LUZ2OFF
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ2OFF		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ2OFF
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ2OFF
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f2hrHoff
		LFSR FSR1,f2hrLoff
		call MUESTRA_HORA2 			
	
		btfsc conLucesB,2
		bra	minl2off30
		call MIN00
		bra loopLUZ2OFF
minl2off30
		call MIN30

loopLUZ2OFF
		btfss PORTB,botonNEXT
		bra LUZ3ON					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ2OFF				;no he presionado OK  
		call DELAY
		;LUZ1OFF set	

		call FIJAHORA
loopLUZ2OFFm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l2OFF30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ2OFFm		;no he presionado OK  
		bcf conLucesB,2		;luz1 OFF a la xx:00
		call DELAY
		bra LUZ3ON
l2OFF30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ2OFFm			;presioné NEXT
		btfsc PORTB,botonSET
		bra l2OFF30				;no he presionado OK  
		bsf conLucesB,2			;luz1 OFF a la xx:30
		call DELAY

;LUZ3***************		
LUZ3ON	movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ3ON		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ3ON
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ3ON
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f3hrHon
		LFSR FSR1,f3hrLon
		call MUESTRA_HORA2 			
	
		btfsc conLucesA,3
		bra	minl3on30
		call MIN00
		bra loopLUZ3ON
minl3on30
		call MIN30

loopLUZ3ON ;HORA
		btfss PORTB,botonNEXT
		bra LUZ3OFF					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ3ON				;no he presionado OK 
		call DELAY
		;LUZ3ON hr set	

		call FIJAHORA
loopLUZ3ONm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l3ON30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ3ONm		;no he presionado OK  
		bcf conLucesA,3			;luz1 ON a la xx:00
		call DELAY
		bra LUZ3OFF
l3ON30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ3ONm				;presioné NEXT
		btfsc PORTB,botonSET
		bra l3ON30				;no he presionado OK  
		bsf conLucesA,3			;luz1 ON a la xx:00
		call DELAY
		
LUZ3OFF
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ3OFF		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ3OFF
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ3OFF
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f3hrHoff
		LFSR FSR1,f3hrLoff
		call MUESTRA_HORA2 			
	
		btfsc conLucesB,3
		bra	minl3off30
		call MIN00
		bra loopLUZ3OFF
minl3off30
		call MIN30


loopLUZ3OFF
		btfss PORTB,botonNEXT
		bra LUZ4ON					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ3OFF				;no he presionado OK  
		call DELAY
		;LUZ1OFF set	

		call FIJAHORA
loopLUZ3OFFm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l3OFF30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ3OFFm		;no he presionado OK  
		bcf conLucesB,3			;luz1 OFF a la xx:00
		call DELAY
		bra LUZ4ON
l3OFF30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ3OFFm			;presioné NEXT
		btfsc PORTB,botonSET
		bra l3OFF30				;no he presionado OK  
		bsf conLucesB,3			;luz1 OFF a la xx:30
		call DELAY


;LUZ4***************		
LUZ4ON	movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ4ON		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ4ON
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ4ON
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f4hrHon
		LFSR FSR1,f4hrLon
		call MUESTRA_HORA2 			
	
		btfsc conLucesA,4
		bra	minl4on30
		call MIN00
		bra loopLUZ4ON
minl4on30
		call MIN30


loopLUZ4ON ;HORA
		btfss PORTB,botonNEXT
		bra LUZ4OFF					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ4ON				;no he presionado OK 
		call DELAY
		;LUZ3ON hr set	

		call FIJAHORA
loopLUZ4ONm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l4ON30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ4ONm		;no he presionado OK  
		bcf conLucesA,4			;luz1 ON a la xx:00
		call DELAY
		bra LUZ4OFF
l4ON30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ4ONm			;presioné NEXT
		btfsc PORTB,botonSET
		bra l4ON30				;no he presionado OK  
		bsf conLucesA,4			;luz1 ON a la xx:00
		call DELAY
		
LUZ4OFF
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ4OFF		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ4OFF
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ4OFF
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f4hrHoff
		LFSR FSR1,f4hrLoff
		call MUESTRA_HORA2 			
	
		btfsc conLucesB,4
		bra	minl4off30
		call MIN00
		bra loopLUZ4OFF
minl4off30
		call MIN30

loopLUZ4OFF
		btfss PORTB,botonNEXT
		bra LUZ5ON					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ4OFF				;no he presionado OK  
		call DELAY
		;LUZ1OFF set	

		call FIJAHORA
loopLUZ4OFFm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l4OFF30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ4OFFm		;no he presionado OK  
		bcf conLucesB,4			;luz1 OFF a la xx:00
		call DELAY
		bra LUZ5ON
l4OFF30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ4OFFm			;presioné NEXT
		btfsc PORTB,botonSET
		bra l4OFF30				;no he presionado OK  
		bsf conLucesB,4			;luz1 OFF a la xx:30
		call DELAY

;LUZ5***************		
LUZ5ON	movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ5ON		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ5ON
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ5ON
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f5hrHon
		LFSR FSR1,f5hrLon
		call MUESTRA_HORA2 			
	
		btfsc conLucesA,5
		bra	minl5on30
		call MIN00
		bra loopLUZ5ON
minl5on30
		call MIN30

loopLUZ5ON ;HORA
		btfss PORTB,botonNEXT
		bra LUZ5OFF					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ5ON				;no he presionado OK 
		call DELAY
		;LUZ3ON hr set	

		call FIJAHORA
loopLUZ5ONm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l5ON30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ5ONm		;no he presionado OK  
		bcf conLucesA,5			;luz1 ON a la xx:00
		call DELAY
		bra LUZ5OFF
l5ON30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ5ONm				;presioné NEXT
		btfsc PORTB,botonSET
		bra l5ON30				;no he presionado OK  
		bsf conLucesA,5			;luz1 ON a la xx:00
		call DELAY
		
LUZ5OFF
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ5OFF		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ5OFF
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ5OFF
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f5hrHoff
		LFSR FSR1,f5hrLoff
		call MUESTRA_HORA2 			
	
		btfsc conLucesB,5
		bra	minl5off30
		call MIN00
		bra loopLUZ5OFF
minl5off30
		call MIN30

loopLUZ5OFF
		btfss PORTB,botonNEXT
		bra LUZ6ON					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ5OFF				;no he presionado OK  
		call DELAY
		;LUZ1OFF set	

		call FIJAHORA
loopLUZ5OFFm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l5OFF30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ5OFFm		;no he presionado OK  
		bcf conLucesB,5			;luz1 OFF a la xx:00
		call DELAY
		bra LUZ6ON
l5OFF30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ5OFFm				;presioné NEXT
		btfsc PORTB,botonSET
		bra l5OFF30				;no he presionado OK  
		bsf conLucesB,5			;luz1 OFF a la xx:30
		call DELAY

;LUZ6***************		
LUZ6ON	movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ6ON		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ6ON
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ6ON
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f6hrHon
		LFSR FSR1,f6hrLon
		call MUESTRA_HORA2 			
	
		btfsc conLucesA,6
		bra	minl6on30
		call MIN00
		bra loopLUZ6ON
minl6on30
		call MIN30

loopLUZ6ON ;HORA
		btfss PORTB,botonNEXT
		bra LUZ6OFF					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ6ON				;no he presionado OK 
		call DELAY
		;LUZ3ON hr set	

		call FIJAHORA
loopLUZ6ONm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l6ON30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ6ONm		;no he presionado OK  
		bcf conLucesA,6			;luz1 ON a la xx:00
		call DELAY
		bra LUZ6OFF
l6ON30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ6ONm				;presioné NEXT
		btfsc PORTB,botonSET
		bra l6ON30				;no he presionado OK  
		bsf conLucesA,6			;luz1 ON a la xx:30
		call DELAY
		
LUZ6OFF
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ6OFF		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ6OFF
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ6OFF
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f6hrHoff
		LFSR FSR1,f6hrLoff
		call MUESTRA_HORA2 			
	
		btfsc conLucesB,6
		bra	minl6off30
		call MIN00
		bra loopLUZ6OFF
minl6off30
		call MIN30

loopLUZ6OFF
		btfss PORTB,botonNEXT
		bra LUZ7ON					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ6OFF				;no he presionado OK  
		call DELAY
		;LUZ1OFF set	

		call FIJAHORA
	
loopLUZ6OFFm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l6OFF30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ6OFFm		;no he presionado OK  
		bcf conLucesB,6			;luz1 OFF a la xx:00
		call DELAY
		bra LUZ7ON
l6OFF30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ6OFFm				;presioné NEXT
		btfsc PORTB,botonSET
		bra l6OFF30				;no he presionado OK  
		bsf conLucesB,6			;luz1 OFF a la xx:30
		call DELAY

;LUZ7***************		
LUZ7ON	movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ7ON		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ7ON
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ7ON
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f7hrHon
		LFSR FSR1,f7hrLon
		call MUESTRA_HORA2 			
	
		btfsc conLucesA,7
		bra	minl7on30
		call MIN00
		bra loopLUZ7ON
minl7on30
		call MIN30

loopLUZ7ON ;HORA
		btfss PORTB,botonNEXT
		bra LUZ7OFF					;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ7ON				;no he presionado OK 
		call DELAY
		;LUZ3ON hr set	

		call FIJAHORA
loopLUZ7ONm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l7ON30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ7ONm		;no he presionado OK  
		bcf conLucesA,7			;luz1 ON a la xx:00
		call DELAY
		bra LUZ7OFF
l7ON30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ7ONm				;presioné NEXT
		btfsc PORTB,botonSET
		bra l7ON30				;no he presionado OK  
		bsf conLucesA,7			;luz1 ON a la xx:00
		call DELAY
		
LUZ7OFF
		movlw LINE1
		call LCD_CMD

		MOVLW UPPER txtLUZ7OFF		;ecribe "LUZ:1ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtLUZ7OFF
		MOVWF TBLPTRH
		MOVLW LOW	txtLUZ7OFF
		MOVWF TBLPTRL 
		call WRITE_LCD

		LFSR FSR0,f7hrHoff
		LFSR FSR1,f7hrLoff
		call MUESTRA_HORA2 			
	
		btfsc conLucesB,7
		bra	minl7off30
		call MIN00
		bra loopLUZ7OFF
minl7off30
		call MIN30

loopLUZ7OFF
		btfss PORTB,botonNEXT
		bra salLUCES				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ7OFF				;no he presionado OK  
		call DELAY
		;LUZ1OFF set	

		call FIJAHORA
	
loopLUZ7OFFm;MIN
		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra l7OFF30				;presioné NEXT
		btfsc PORTB,botonSET
		bra loopLUZ7OFFm		;no he presionado OK  
		bcf conLucesB,7			;luz1 OFF a la xx:00
		call DELAY
		bra salLUCES
l7OFF30
		movlw 0xC7
		call LCD_CMD
		movlw '3'
		call LCD_CHAR
		btfss PORTB,botonNEXT
		bra loopLUZ7OFFm				;presioné NEXT
		btfsc PORTB,botonSET
		bra l7OFF30				;no he presionado OK  
		bsf conLucesB,7			;luz1 OFF a la xx:30
		call DELAY
salLUCES
		movlw DISP_ON			;ponle cursor normal
		call LCD_CMD
		return

;******************************************************************************
FIJAHORA
		
		movlw 0xC4				;mueve cursor a donde va hrH
		call LCD_CMD
		movlw DISP_ON_B			;ponle cursor bajo lo que escribes
		call LCD_CMD
		
		movff hrHIGH,hrHIGHaux
		movff hrLOW,hrLOWaux
		decf hrHIGHaux
		decf hrLOWaux

fijaHIGH
		incf hrHIGHaux
		movlw '2'
		cpfsgt hrHIGHaux
		bra hrHIGHenRANGO		;sigues en rango
		movlw '0'				;te habías pasado..otra vez eres 0
		movwf hrHIGHaux
hrHIGHenRANGO
		movf hrHIGHaux,0		;el digito está entre 0-2..pasalo alWREG para imprimirlo
		call LCD_CHAR			;escribe el digito en el LCD
		movlw 0xC4				;regresate al punto de hrH
		call LCD_CMD
loopFIJAhoraHIGH
		btfss PORTB,botonNEXT
		bra fijaHIGH  			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopFIJAhoraHIGH	;no he presionado OK  a este digito
		call DELAY				;ya lo presioné

		;FIJAR HORA
		movff hrHIGHaux,INDF0

		
		movlw 0xC5				;ve a la posición de hrLOW
		call LCD_CHAR
fijaLOW
		incf hrLOWaux
		movlw '3'
		cpfsgt hrLOWaux
		bra hrLOWenRANGO		;sigues en rango (00,01,02,03,10,11,12,13,21,22,23)
		movlw '2'
		cpfslt hrHIGHaux			
		bra ponHrLOWcero		;hrHIGH es 2 y hrLOW ya es 4
		movlw '9'
		cpfsgt hrLOWaux
		bra hrLOWenRANGO
ponHrLOWcero
		movlw '0'				;te habías pasado del 09-19-23..otra vez eres 0
		movwf hrLOWaux

hrLOWenRANGO
		movf hrLOWaux,0			;el digito está entre 0-9..pasalo alWREG para imprimirlo
		call LCD_CHAR			;escribe el digito en el LCD
		movlw 0xC5				;regresate al punto de hrH
		call LCD_CMD
loopFIJAhoraLOW
		btfss PORTB,botonNEXT
		bra fijaLOW  			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopFIJAhoraLOW		;no he presionado OK  a este digito
		call DELAY				;ya lo presioné

		;FIJAR HORA
		movff hrLOWaux,INDF1
		

		return
;******************************************************************************
FIJAMINUTOS
		movlw 0xC7				;mueve cursor a donde va minH
		call LCD_CMD
			
		movff minHIGH,minHIGHaux
		movff minLOW,minLOWaux
		decf minHIGHaux
		decf minLOWaux

fijaHIGHm
		incf minHIGHaux
		movlw '5'
		cpfsgt minHIGHaux
		bra minHIGHenRANGO		;sigues en rango
		movlw '0'				;te habías pasado..otra vez eres 0
		movwf minHIGHaux
minHIGHenRANGO
		movf minHIGHaux,0		;el digito está entre 0-2..pasalo alWREG para imprimirlo
		call LCD_CHAR			;escribe el digito en el LCD
		movlw 0xC7				;regresate al punto de minH
		call LCD_CMD
loopFIJAminHIGH
		btfss PORTB,botonNEXT
		bra fijaHIGHm 			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopFIJAminHIGH		;no he presionado OK  a este digito
		call DELAY				;ya lo presioné

		;FIJAR HORA
		movff minHIGHaux,INDF0

		movlw 0xC8				;mueve cursor a donde va minH
		call LCD_CMD

fijaLOWm
		incf minLOWaux
		movlw '9'
		cpfsgt minLOWaux
		bra minLOWenRANGO		;sigues en rango
		movlw '0'				;te habías pasado..otra vez eres 0
		movwf minLOWaux
minLOWenRANGO
		movf minLOWaux,0		;el digito está entre 0-2..pasalo alWREG para imprimirlo
		call LCD_CHAR			;escribe el digito en el LCD
		movlw 0xC8				;regresate al punto de minH
		call LCD_CMD
loopFIJAminLOW
		btfss PORTB,botonNEXT
		bra fijaLOWm 			;presioné NEXT
		btfsc PORTB,botonSET
		bra loopFIJAminLOW		;no he presionado OK  a este digito
		call DELAY				;ya lo presioné

		;FIJAR HORA
		movff minLOWaux,INDF1

		movlw DISP_ON			;ponle cursor normal
		call LCD_CMD
		return

clrLINE2
		movlw LINE2
		call LCD_CMD

		MOVLW UPPER txtBLANK	
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtBLANK
		MOVWF TBLPTRH
		MOVLW LOW	txtBLANK
		MOVWF TBLPTRL 
		call WRITE_LCD
		return

horaCERO
		movlw 0xC4
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		movlw 0xC5
		call LCD_CMD
		movlw '0'
		call LCD_CHAR

		movlw 0xC6
		call LCD_CMD
		movlw ':'
		call LCD_CHAR

		movlw 0xC7
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		movlw 0xC8
		call LCD_CMD
		movlw '0'
		call LCD_CHAR

		movlw 0xC9
		call LCD_CMD
		movlw ':'
		call LCD_CHAR

		movlw 0xCA
		call LCD_CMD
		movlw '0'
		call LCD_CHAR
		movlw 0xCB
		call LCD_CMD
		movlw '0'
		call LCD_CHAR

		return

MIN30
		movlw '3'       					;escribe MINUTOS
		call LCD_CHAR
		movlw '0'						;minLOW
		call LCD_CHAR
		call SEGUNDOScero
		;movlw 0xC7
		;call LCD_CMD
		return

MIN00
		movlw '0'       					;escribe MINUTOS
		call LCD_CHAR
		movlw '0'						;minLOW
		call LCD_CHAR
		call SEGUNDOScero
		;movlw 0xC7
		;call LCD_CMD
		return


SEGUNDOScero
		movlw ':'
		call LCD_CHAR
		movlw '0'				;escribe SEGUNDOS
		call LCD_CHAR
		movlw '0'
		call LCD_CHAR
		return;

escribeAUTOoff
		movlw LINE2
		call LCD_CMD

		MOVLW UPPER txtAUTOoff		;ecribe "AUTO OFF"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtAUTOoff
		MOVWF TBLPTRH
		MOVLW LOW	txtAUTOoff
		MOVWF TBLPTRL 
		call WRITE_LCD
		return

escribeAUTOon
		movlw LINE2
		call LCD_CMD

		MOVLW UPPER txtAUTOon		;ecribe "AUTO ON"
		MOVWF TBLPTRU 			
		MOVLW HIGH  txtAUTOon
		MOVWF TBLPTRH
		MOVLW LOW	txtAUTOon
		MOVWF TBLPTRL 
		call WRITE_LCD
		return

prendeApagaFocos

;FOCO1---
		btfss conLucesAUTO,1		;checa si el fx está activado el AUTO
		bra edof2			
edof1
		btfss luzAlrmOUT,6			;si es 1 entonces se tiene que apagar
		bra prendef1
		bcf PORTA,0					;apaga el foco
		bra edof2
prendef1
		bsf PORTA,0					;enciende el foco

;FOCO2--
edof2	btfss conLucesAUTO,2		;checa si el fx está activado el AUTO
		bra edof3

		btfss luzAlrmOUT,0			;si es 1 entonces se tiene que apagar
		bra prendef2
		bcf PORTA,1					;apaga el foco
		bra edof3
prendef2
		bsf PORTA,1					;enciende el foco

;FOCO3--
edof3	btfss conLucesAUTO,3		;checa si el fx está activado el AUTO
		bra edof4

		btfss luzAlrmOUT,1			;si es 1 entonces se tiene que apagar
		bra prendef3
		bcf PORTA,2					;apaga el foco
		bra edof4
prendef3
		bsf PORTA,2					;enciende el foco

;FOCO4--
edof4	btfss conLucesAUTO,4		;checa si el fx está activado el AUTO
		bra edof5

		btfss luzAlrmOUT,2			;si es 1 entonces se tiene que apagar
		bra prendef4
		bcf PORTA,3					;apaga el foco
		bra edof5
prendef4
		bsf PORTA,3					;enciende el foco

;FOCO5--
edof5	btfss conLucesAUTO,5		;checa si el fx está activado el AUTO
		bra edof6

		btfss luzAlrmOUT,3			;si es 1 entonces se tiene que apagar
		bra prendef5
		bcf PORTA,4					;apaga el foco
		bra edof6
prendef5
		bsf PORTA,4					;enciende el foco

;FOCO6--
edof6	btfss conLucesAUTO,6		;checa si el fx está activado el AUTO
		bra edof7

		btfss luzAlrmOUT,4			;si es 1 entonces se tiene que apagar
		bra prendef6
		bcf PORTA,5					;apaga el foco
		bra edof7
prendef6
		bsf PORTA,5					;enciende el foco


;FOCO7--
edof7	btfss conLucesAUTO,7		;checa si el fx está activado el AUTO
		bra salPrendeApagaFocos

		btfss luzAlrmOUT,5			;si es 1 entonces se tiene que apagar
		bra prendef7
		bcf PORTE,1					;apaga el foco
		bra salPrendeApagaFocos
prendef7
		bsf PORTE,1					;enciende el foco


salPrendeApagaFocos
		return

;FIN RUTINAS**********************************************************