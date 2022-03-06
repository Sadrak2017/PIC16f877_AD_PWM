;*****************************************************
;   Professor(a): Sofia Lopes
;   Aluno: Sadrak da Silva
;   Data 29/01/2022
;   Decri��o: C�digo para convers�o AD com sa�da PWM
;*****************************************************

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 INICIALIZA��O E CONFIGURA��ES                   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#include p16f877.inc

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE
; MEM�RIA.

BANK0	MACRO					;SELECIONA BANK0 DE MEM�RIA.
				bcf STATUS,RP1
				bcf	STATUS,RP0
		ENDM					;FIM DA MACRO BANK0.

BANK1	MACRO					;SELECIONA BANK1 DE MEM�RIA.
				bcf STATUS,RP1
				bsf	STATUS,RP0
		ENDM					;FIM DA MACRO BANK1.

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;com as constantes a seguir, temos um delay de 5,03ms
 T1 EQU .150		;constante de tempo para a fun��o delay
 T2 EQU .44			;constante de tempo para a fun��o delay2
 T3 EQU	.10			;constante para execu��o de 5ms T3 vezes
 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    CONFIGURA��ES                       *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
__config _XT_OSC & _WDT_OFF & _LVP_OFF & _DEBUG_OFF

; Cria��o de vari�veis
cblock 0x20 ; O endere�o 0x20 � a partir de onde eu posso adicionar vari�veis na mem�ria de dados
	W_TEMP
	STATUS_TEMP
	TEMP		;VARI�VEIS PARA DELAY
	TEMP2
	TEMP3
endc

org 0x00 

goto CONFIGURACAO


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O.
	movwf	W_TEMP		;COPIA W PARA W_TEMP.
	swapf	STATUS,W
	movwf	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP.



;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS INTERRUP��ES


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT						
	swapf	STATUS_TEMP,W
	movwf	STATUS		;MOVE STATUS_TEMP PARA STATUS.
	swapf	W_TEMP,F
	swapf	W_TEMP,W	;MOVE W_TEMP PARA W.
retfie; Palavra reservada para sa�da de interrup��o

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       SUBROTINAS               	           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;ROTINAS PARA O DELAY
DELAY:
	movlw	T1
	movwf	TEMP
	decfsz  TEMP
	goto	$-.1 ;retorna a linha anterior	
return

DELAY2:
	movlw   T2
	movwf	TEMP2
	call	DELAY
	decfsz	TEMP2
	goto	$-.2
return

DELAY3:
	movlw   T3
	movwf	TEMP3
	call	DELAY2
	decfsz	TEMP3
	goto	$-.2
return

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 CONFIGURA��ES DO MICROCONTROLADOR               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
CONFIGURACAO:

BANK0			; Seleciona o Bank0 da mem�ria de dados
	CLRF PORTA 	; Limpa as portas
	CLRF PORTB
	CLRF PORTC
	CLRF PORTD
					
BANK1           ; Seleciona o  Bank 1 da mem�ria de dados

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;       Passa o valor em bin�rio 0b00000000 para o ADCON1, seguintes configura��es       ;
	;                                                                                        ;
	;  Bit ADFM zerado - o resultado ser� justificado para a esquerda (ADRESH cheio)         ;
	;  Os 8 pinos dispon�veis no pic s�o definidos como anal�gicos,                          ; 
    ;  e a tens�o de refer�ncia ser� a de 5V                                                 ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOVLW 0x00	
	MOVWF ADCON1 
	
    ; Todos os pinos est�o configurados como entrada
	MOVLW	0xFF			
	MOVWF	TRISA
	MOVLW	0xFF			
	MOVWF	TRISB
	MOVLW	0xFF			
	MOVWF	TRISC
	MOVLW	0xFF			
	MOVWF	TRISD
	MOVLW	0xFF			
	MOVWF	TRISE
	BCF	TRISC,2 ; Define como sa�da o pino com sinal PWM 
	
BANK0	; Seleciona o Bank0 da mem�ria de dados

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;       Passa o valor em bin�rio 0b01000001 para o ADCON0, seguintes configura��es         ;
	;                                                                                          ;
	; 1. Clock de convers�o: Fosc/8                                                            ;
	; 2. Canal anal�gico: AN0                                                                  ;
	; 3. Bit Go/DONE desligado - n�o deve ser ligado na mesma instru��o que liga o conversor AD;
	; 4. Bit ADON setado - Liga o conversor AD                                                 ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOVlW 0x41 
	MOVWF ADCON0

	;Configura PRESCALE = 16 
	MOVLW B'00000010'
	MOVWF T2CON

    ;Tosc = 1 / PIC CLOCK   =>  Tosc = 1/20MHz = 0.25us
	;Tpwm = [(PR2)+1] * 4 * TOSC * (TMR2 PRESCALE) => Tpwm =  1 / Fpwm
    ;PR2 = [ Tpwm / (4 * Tosc * Prescale)] - 1
    ; 
	;PWM DUTY CYCLE = (CCPR1L:CCP1CON<5:4>) * TOSC * (TMR2 PRESCALE)
	
    ;;;SET PWM FREQUENCIA;;;
BANK1       ; Seleciona o  Bank 1 da mem�ria de dados

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;                               CONFIGURA FREQU�NCIA DO PWM                                ;
	;                                                                                          ;
	; 1. Tosc = 1 / PIC CLOCK   =>  Tosc = 1/20Mhz = 0.25us                                    ;
	; 2. Fpwm = 20MHz / (1023 * 16)  => Fpwm = 1,22kHz                                         ;
	; 3. Tpwm = [(PR2)+1] * 4 * TOSC * (TMR2 PRESCALE) => Tpwm = 1/Fpwm => Tpwm = 816,67us     ;
	; 4. PR2 = [ Tpwm / (4 * Tosc * Prescale)] - 1 => PR2 = 255                                ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOVLW D'255'      
	MOVWF PR2

BANK0    	; Seleciona o Bank0 da mem�ria de dados
	
	;Inicia DUTY CYCLE em zero 
	CLRF CCPR1L

	MOVLW B'00001100' ;SET PWM MODE, BITS 5 E 4 S�O OS DOIS LSBs DO 10BIT DUTY CYCLE REGISTER (CCPR1L:CCP1CON<5:4>)
	MOVWF CCP1CON
	
	;CLEAR TIMER 2 MODULE
	CLRF TMR2
	
	;HABILITA TIMER 2 MODULE
	BSF T2CON, TMR2ON
	
    ; Configuramos por seguran�a os registradores seguintes
	CLRF OPTION_REG ; 
	CLRF INTCON 

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA PRINCIPAL					               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN:
	; Chama a fun��o de delay para garantir o tempo de carregamento do capacitor
	CALL	DELAY3
	BSF  	ADCON0,2 ; Seta o bit GO/DONE, permitindo que a convers�o comece

CONVERSAO:
	BTFSC 	ADCON0, 2 ; Testa o bit GO/DONE e pula a linha seguinte caso o bit seja zero e a convers�o tenha encerrado
	goto 	$-1
	MOVF	ADRESH, 0 ; Passa o resultado da convers�o do registrador ADRESH para CCPR1L 
	MOVWF	CCPR1L
	GOTO	MAIN
	
END

; Este programa faz a leitura de um sinal anal�gico de um potenci�metro, converte em sinal
; digital e por fim devolve na PORTC, RC2, um sinal PWM.
; Para isso levando em considera��o um clock interno de 20 MHz, os seguintes c�lculos foram realizados:
;
;    Tosc = 1 / PIC CLOCK   =>  Tosc = 1/20Mhz = 0.25us                                    
;    Fpwm = 20MHz / (1023 * 16)  => Fpwm = 1,22kHz                                         
;    Tpwm = [(PR2)+1] * 4 * TOSC * (TMR2 PRESCALE) => Tpwm = 1/Fpwm => Tpwm = 816,67us     
;    PR2 = [ Tpwm / (4 * Tosc * Prescale)] - 1 => PR2 = 255                         
;
; O Prescale foi configurado na diretiva T2CON, passando o valor bin�rio B'00000010', setando assim 
; o prescale 16. O registrador CCPR1L foi inciado zerado. Quando a connvers�o � finalizada o valor
; da convers�o vai para o ADRESH que em seguida � enviado p/ o registrado Work e por fim passado 
; o CCPR1L para controlar o DUTY CYCLE
       