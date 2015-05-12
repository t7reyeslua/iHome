variable1 equ 0x00
variable2 equ 0x01
variable3 equ 0x02

CMD_DELAY  EQU 0x03 
LCD_TMP	   EQU 0x04 

LCD_RS   EQU 1 
LCD_RW   EQU 2   
LCD_E    EQU 3


LINE1           EQU     0x080   ; Set el cursor en (1,0)
LINE2           EQU     0x0C0   ; Set el cursor en (2,0)
LINE2CENTER		EQU     0x0C4   ; Set el cursor en (2,4)
FUNC_SET        EQU     0x028   ; 4 bits, 2 lines, 5x7 Font 
DISP_ON         EQU     0x00C   ; Display on
DISP_ON_C       EQU     0x00E   ; Display on, Cursor on
DISP_ON_B       EQU     0x00F   ; Display on, Cursor on, Blink cursor
DISP_OFF        EQU     0x008   ; Display off
CLR_DISP        EQU     0x001   ; Clear el Display
SHIFT_ON		EQU		0x006	; Shift on

;rutina que inicializa el PIC
INITPIC

		clrf    TRISD	;Set Port B as output
		clrf    PORTD	; Clear Port B
		return

;rutina que inicializa el LCD
INITLCD
							
        CALL    DELAY
        MOVLW   0x30            ; Set LCD for 4 bits        
        MOVWF   PORTD           ; Data Lines
        BSF     PORTD,LCD_E     ; Toggle Enable
        BCF     PORTD,LCD_E     ; 
        CALL    DELAY			; Espera 5ms

        BSF     PORTD, LCD_E    ; Manda una segunda vez
        BCF     PORTD, LCD_E      
        CALL    DELAY        
                   
        BSF     PORTD, LCD_E    ; Manda una tercera vez
		BCF     PORTD, LCD_E     
        CALL    DELAY
        
        MOVLW   0x20            ; Configura LCD en 4bitMode
        MOVWF   PORTD           ; manda al PUERTOB                        
        BSF     PORTD, LCD_E    ; Toggle el ENABLE 
        BCF     PORTD, LCD_E	
        CALL    DELAY
     
        MOVLW   FUNC_SET       	; Set en 2line - 4 bit I/O
        CALL    LCD_CMD         
        MOVLW   DISP_OFF 		; Turn off the Display
        CALL    LCD_CMD
        MOVLW   CLR_DISP	    ; Clear los contenidos del LCD
        CALL    LCD_CMD
        MOVLW   SHIFT_ON       	; Set the Entry mode
        CALL    LCD_CMD
        MOVLW   DISP_ON        	; Turn it on again
        CALL    LCD_CMD
        RETURN                  

;rutina para enviar comandos       
LCD_CMD:
        MOVWF   LCD_TMP         ; Guarda comando en regTemporal
        MOVLW   0x01            ; Delay standard
        MOVWF   CMD_DELAY       
        MOVLW   0xFC            ; This is how we check for clear/home
        ANDWF   LCD_TMP,W       ; If any bit other than 0 or 1 is set
        BTFSS   STATUS,Z        ; 
        GOTO    OK_DELAY        ; If non-zero leave delay alone
        MOVLW   D'20'           ; Else store 2mS delay value.
        MOVWF   CMD_DELAY
OK_DELAY: 
        movf    LCD_TMP,W       ; Read it
        ANDLW   0xF0            ; Turn OFF the R/S bit
        MOVWF   PORTD           ; Out it goes
        BSF     PORTD,LCD_E     ; Clock it out
		call 	DELAY
        BCF     PORTD,LCD_E     ; Like so
		call	DELAY
        swapF   LCD_TMP,W       ; Get lower nybble, low nibble to high
        ANDLW   0xF0            ; Turn off R/S
        MOVWF   PORTD           ; Put it on PortB
        BSF     PORTD,LCD_E     ; Clock it out
        BCF     PORTD,LCD_E     ;
        MOVF    CMD_DELAY,W     ; Wait for it to complete
        CALL    DELAY
        RETURN   
   
;rutina para enviar caracter
LCD_CHAR:
        MOVWF   LCD_TMP         ; Store it in LCD_TMP
        movF   LCD_TMP,W       	; Upper Nybble
        ANDLW   0xF0           	; Clear lower bits
        IORLW   0x02           	; Turn On R/S bit
        MOVWF   PORTD           ; Put it out to PortA
        BSF     PORTD,LCD_E     ; Clock it out
        BCF     PORTD,LCD_E     ;
        swapF   LCD_TMP,W       ; Get the lower nybble
        ANDLW   0xF0           	; Clear upper bits
        IORLW   0x02           	; Turn on R/S Bit
        MOVWF   PORTD           ; Out to PORTA
        BSF     PORTD, LCD_E    ; Clock it out
        BCF     PORTD, LCD_E    ; 
        CALL    DELAY
        RETURN

;rutina que escribe una palabra
WRITE_LCD:

loop 	TBLRD*+ 				
		 MOVF TABLAT, W  	
		 BZ	salWRITE_LCD
		 call LCD_CHAR
		 bra loop

salWRITE_LCD
		return

;rutina DELAY
DELAY
		movlw 0xFF
		movwf variable3
ciclo_delay
		call delay
		decfsz variable3
		goto ciclo_delay
		return

delay  
		movlw 0xFF
		movwf variable1
		movwf variable2
loop1
		dcfsnz variable1
		goto ret
loop2
		decfsz variable2
		goto loop1
		goto loop2		
ret
		return

