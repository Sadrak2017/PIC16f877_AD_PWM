# Este programa faz a leitura de um sinal analógico de um potenciômetro, converte em sinal
  digital e por fim devolve na PORTC, RC2, do PIC16F877, um sinal PWM.
  Para isso levando em consideração um clock interno de 20 MHz, os seguintes cálculos foram realizados:
#
     Tosc = 1 / PIC CLOCK   =>  Tosc = 1/20Mhz = 0.25us                                    
     Fpwm = 20MHz / (1023 * 16)  => Fpwm = 1,22kHz                                         
     Tpwm = [(PR2)+1] * 4 * TOSC * (TMR2 PRESCALE) => Tpwm = 1/Fpwm => Tpwm = 816,67us     
     PR2 = [ Tpwm / (4 * Tosc * Prescale)] - 1 => PR2 = 255                         
 
  O Prescale foi configurado na diretiva T2CON, passando o valor binário B'00000010', setando assim 
  o prescale 16. O registrador CCPR1L foi inciado zerado. Quando a connversão é finalizada o valor
  da conversão vai para o ADRESH que em seguida é enviado p/ o registrado Work e por fim passado 
  o CCPR1L para controlar o DUTY CYCLE
