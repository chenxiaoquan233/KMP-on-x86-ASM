;#########################################################;
;                                                         ;
; @description : KMP inplementation, find str_a in str_b  ;
;      @author : XQChen                                   ;
;       @email : chenxiaoquan233@gmail.com                ;
;                                                         ;
;#########################################################;

ASSUME DS:DATA,SS:STACK,CS:CODE
DATA SEGMENT
  STRING STRUC
	   MAX DB 255             ; the max length of the string
	   LEN DB 0               ; the actual length inputed
	   STR DB 254 DUP ('$')   ; the string buffer
	STRING ENDS
	  STRA STRING <>
	  STRB STRING <>
	  HINT DB 'PLEASE INPUT A STRING:$'
	 FOUND DB 'FOUND','$'
	NFOUND DB 'NOT FOUND','$'
 NEWLINE DB 0DH,0AH,'$'     ; end of line: '\r','\n'
	  NEXT DB 256 DUP('$')    ; next array in KMP
DATA ENDS

STACK SEGMENT STACK
		DB 64 DUP (0)
STACK ENDS

CODE SEGMENT
	START:	MOV AX,DATA
		      MOV DS,AX
		      MOV ES,AX
	
          MOV AX,STACK
          MOV SS,AX
          MOV SP,40H

          CALL PH          ; input str_b
          LEA DX,STRB
          CALL INPUT
          CALL ENDL

          CALL PH          ; input str_a
          LEA DX,STRA
          CALL INPUT
          CALL ENDL

          MOV AH,STRA.LEN
          MOV AL,STRB.LEN

          CMP AL,AH        ; if len(str_a) > len(str_b):
          JB NF            ;     print "NOT FOUND"
          
          CALL GETN        ; calculate the next array

          MOV DX,0         ; use DX to store the postion
          CALL KMP         ; start find

          CMP DX,0FFFFH    ; whether found sub_str
          JE NF

	     F:	LEA DX,FOUND     ; if found
          CALL PRINT
          JMP ENDPRO
	
	    NF:	LEA DX,NFOUND    ; if not found
          CALL PRINT
          JMP ENDPRO

	ENDPRO:	MOV AX,4C00H
          INT 21H
         
;################################################;
; @ input function                               ;
;   description: read a string ended with enter  ;
;################################################;

	 INPUT:	PUSH AX
          MOV AH,0AH
          INT 21H
          POP AX
          RET

;##########################################################################;
; @ print function                                                         ;
;   description: print the string from the pointed buffer(begin at DS:DX)  ;
;##########################################################################;

	 PRINT: PUSH AX
          PUSH BX
          XOR BX,BX
          MOV AH,09H
          INT 21H
          POP BX
          POP AX
		      RET
          
;#################################;
; @ end of line functin           ;
;   description: print '\r','\n'  ;
;#################################;

	  ENDL:	PUSH DX
          MOV DX,OFFSET NEWLINE
          CALL PRINT
          POP DX
          RET

;################################################;
; @ print hint function                          ;
;   description: print "PLEASE INPUT A STRING:"  ;
;################################################;

	    PH:	PUSH DX
          MOV DX,OFFSET HINT
          CALL PRINT
          POP DX
          RET

;#################################################;
; @ get next function                             ;
;   description: calculate the next array in KMP  ;
;#################################################;

	  GETN:	PUSH AX
          PUSH BX
          PUSH CX

          MOV NEXT[0],0FFH 
          XOR BX,BX
          XOR CX,CX
          MOV DI,0FFFFH   

          MOV CL,STRA.LEN  
          DEC CX
		
	 LOOPN:	MOV BL,STRA.LEN
          MOV SI,BX
          SUB SI,CX
          CMP DI,0FFFFH    
          JE EN 
          MOV AH,STRA.STR[SI]
          MOV AL,STRA.STR[DI]
          CMP AH,AL       
          JE EN

     NEN: MOV BL,NEXT[DI]  
          MOV DI,BX        
          XOR DI,0FFH      ; DI is a 16-bit register, but next[DI] is a 8-bit memory unit
          JNZ NMINUS       ; so if DI get 0xFF from next[DI]
          MOV DI,0FFFFH    ; DI should be set to 0xFFFF
	NMINUS: NOP	
	    EN:	INC DI           
          INC SI
          DEC CX           ; to keep the loop time same, CX--
          MOV AH,STRA.STR[DI]
          MOV AL,STRA.STR[SI]
          CMP AH,AL        
          JNE ENIF
  ENELSE: MOV BL,NEXT[DI]  
	        MOV NEXT[SI],BL  
		      JMP CLN

	  ENIF:	MOV BX,DI        
		      MOV NEXT[SI],BL

	   CLN:	LOOP LOOPN

	 ENDGN:	POP CX
          POP BX
          POP AX
          RET

;#####################################;
; @ KMP function                      ;
;   description: find str_a in str_b  ;
;#####################################;

	   KMP: PUSH AX
          PUSH BX
          PUSH CX
          XOR BX,BX
          XOR SI,SI
          XOR DI,DI
		
	  	MOV CL,STRB.LEN
	  FIND:	MOV BL,STRA.LEN
          CMP SI,BX
          JE KMPCMP
          MOV BL,STRB.LEN
          CMP DI,BX
          JE KMPCMP

          CMP DI,0FFFFH
          JE KMPIF
          MOV AH,STRA.STR[SI]
          MOV AL,STRB.STR[DI]
          CMP AH,AL
          JE KMPIF
          MOV BL,NEXT[DI]
          JMP KMPLP
	 KMPIF:	INC SI
          INC DI

	 KMPLP:	LOOP FIND

	KMPCMP: MOV BL,STRA.LEN
          CMP DI,BX
          JE KMPE
          MOV DX,0FFFFH
          JMP KMPEND
          KMPE: MOV BL,STRA.LEN
          SUB SI,BX
          MOV DX,SI
		
	KMPEND:	POP CX
          POP BX
          POP AX
          RET

CODE ENDS
END START
