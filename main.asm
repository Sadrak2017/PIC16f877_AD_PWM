;*****************************************************
;   Professor(a): Sofia Lopes
;   Aluno: Sadrak da Silva
;   Data 29/01/2022
;   Decrição: Código para conversão AD com saída PWM
;*****************************************************

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 INICIALIZAÇÃO E CONFIGURAÇÕES                   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#include p16f877.inc

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE
; MEMÓRIA.

BANK0	MACRO					;SELECIONA BANK0 DE MEMÓRIA.
				bcf STATUS,RP1
				bcf	STATUS,RP0
		ENDM					;FIM DA MACRO BANK0.

BANK1	MACRO					;SELECIONA BANK1 DE MEMÓRIA.
				bcf STATUS,RP1
				bsf	STATUS,RP0
		ENDM					;FIM DA MACRO BANK1.

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;com as constantes a seguir, temos um delay de 5,03ms
 T1 EQU .150		;constante de tempo para a função delay
 T2 EQU .44			;constante de tempo para a função delay2
 T3 EQU	.10			;constante para execução de 5ms T3 vezes
 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    CONFIGURAÇÕES                       *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
__config _XT_OSC & _WDT_OFF & _LVP_OFF & _DEBUG_OFF

; Criação de variáveis
cblock 0x20 ; O endereço 0x20 é a partir de onde eu posso adicionar variáveis na memória de dados
	W_TEMP
	STATUS_TEMP
	TEMP		;VARIÁVEIS PARA DELAY
	TEMP2
	TEMP3
endc

org 0x00 

goto CONFIGURACAO


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO.
	movwf	W_TEMP		;COPIA W PARA W_TEMP.
	swapf	STATUS,W
	movwf	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP.



;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS INTERRUPÇÕES


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT						
	swapf	STATUS_TEMP,W
	movwf	STATUS		;MOVE STATUS_TEMP PARA STATUS.
	swapf	W_TEMP,F
	swapf	W_TEMP,W	;MOVE W_TEMP PARA W.
retfie; Palavra reservada para saída de interrupção

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
;*                 CONFIGURAÇÕES DO MICROCONTROLADOR               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
CONFIGURACAO:

BANK0			; Seleciona o Bank0 da memória de dados
	CLRF PORTA 	; Limpa as portas
	CLRF PORTB
	CLRF PORTC
	CLRF PORTD
					
BANK1           ; Seleciona o  Bank 1 da memória de dados

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;       Passa o valor em binário 0b00000000 para o ADCON1, seguintes configurações       ;
	;                                                                                        ;
	;  Bit ADFM zerado - o resultado será justificado para a esquerda (ADRESH cheio)         ;
	;  Os 8 pinos disponíveis no pic são definidos como analógicos,                          ; 
    ;  e a tensão de referência será a de 5V                                                 ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOVLW 0x00	
	MOVWF ADCON1 
	
    ; Todos os pinos estão configurados como entrada
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
	BCF	TRISC,2 ; Define como saída o pino com sinal PWM 
	
BANK0	; Seleciona o Bank0 da memória de dados

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;       Passa o valor em binário 0b01000001 para o ADCON0, seguintes configurações         ;
	;                                                                                          ;
	; 1. Clock de conversão: Fosc/8                                                            ;
	; 2. Canal analógico: AN0                                                                  ;
	; 3. Bit Go/DONE desligado - não deve ser ligado na mesma instrução que liga o conversor AD;
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
BANK1       ; Seleciona o  Bank 1 da memória de dados

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;                               CONFIGURA FREQUÊNCIA DO PWM                                ;
	;                                                                                          ;
	; 1. Tosc = 1 / PIC CLOCK   =>  Tosc = 1/20Mhz = 0.25us                                    ;
	; 2. Fpwm = 20MHz / (1023 * 16)  => Fpwm = 1,22kHz                                         ;
	; 3. Tpwm = [(PR2)+1] * 4 * TOSC * (TMR2 PRESCALE) => Tpwm = 1/Fpwm => Tpwm = 816,67us     ;
	; 4. PR2 = [ Tpwm / (4 * Tosc * Prescale)] - 1 => PR2 = 255                                ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOVLW D'255'      
	MOVWF PR2

BANK0    	; Seleciona o Bank0 da memória de dados
	
	;Inicia DUTY CYCLE em zero 
	CLRF CCPR1L

	MOVLW B'00001100' ;SET PWM MODE, BITS 5 E 4 SÃO OS DOIS LSBs DO 10BIT DUTY CYCLE REGISTER (CCPR1L:CCP1CON<5:4>)
	MOVWF CCP1CON
	
	;CLEAR TIMER 2 MODULE
	CLRF TMR2
	
	;HABILITA TIMER 2 MODULE
	BSF T2CON, TMR2ON
	
    ; Configuramos por segurança os registradores seguintes
	CLRF OPTION_REG ; 
	CLRF INTCON 

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA PRINCIPAL					               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN:
	; Chama a função de delay para garantir o tempo de carregamento do capacitor
	CALL	DELAY3
	BSF  	ADCON0,2 ; Seta o bit GO/DONE, permitindo que a conversão comece

CONVERSAO:
	BTFSC 	ADCON0, 2 ; Testa o bit GO/DONE e pula a linha seguinte caso o bit seja zero e a conversão tenha encerrado
	goto 	$-1
	MOVF	ADRESH, 0 ; Passa o resultado da conversão do registrador ADRESH para CCPR1L 
	MOVWF	CCPR1L
	GOTO	MAIN
	
END

; Este programa faz a leitura de um sinal analógico de um potenciômetro, converte em sinal
; digital e por fim devolve na PORTC, RC2, um sinal PWM.
; Para isso levando em consideração um clock interno de 20 MHz, os seguintes cálculos foram realizados:
;
;    Tosc = 1 / PIC CLOCK   =>  Tosc = 1/20Mhz = 0.25us                                    
;    Fpwm = 20MHz / (1023 * 16)  => Fpwm = 1,22kHz                                         
;    Tpwm = [(PR2)+1] * 4 * TOSC * (TMR2 PRESCALE) => Tpwm = 1/Fpwm => Tpwm = 816,67us     
;    PR2 = [ Tpwm / (4 * Tosc * Prescale)] - 1 => PR2 = 255                         
;
; O Prescale foi configurado na diretiva T2CON, passando o valor binário B'00000010', setando assim 
; o prescale 16. O registrador CCPR1L foi inciado zerado. Quando a connversão é finalizada o valor
; da conversão vai para o ADRESH que em seguida é enviado p/ o registrado Work e por fim passado 
; o CCPR1L para controlar o DUTY CYCLE
       