.model small  
    
.stack 100h 
    
.data
    message1 db 'Input 5x6: ',0Dh, 0Ah, '$'
    message2 db 'Result: $' 
    message3 db 0Dh, 0Ah, 'Overflow happened, enter this number again ',0Dh, 0Ah, '$'
    message4 db 0Dh, 0Ah, 'Next string ',0Dh, 0Ah, '$'
    enter db 0Dh, 0Ah, '$'              
    array  db 31 dup (0)
    result dw 6 dup (0)     
    flag    db  0    
    symbol db '$$'
    num db 1
        
.code
START:     
   mov   AX, @data
   mov   DS, AX  
   
   mov   AH, 09h         
   mov   DX, offset Message1
   int   21h 
                    
   mov   CX,30               
   xor   BX,BX              
   lea   DI,array    ;DI->array
   lea   SI,result   ;SI->result        
cycle:                   
   mov   AL,' '    
   mov   BP, AX
   mov   [symbol], AL 
   mov   AH, 09h         
   mov   DX, offset symbol
   int   21h
   mov   AX, BP  
   call  ASC2HEX 
   cmp   flag, 1  ;flag=1 - otrizatelno, flag=0 - polozhitelno
   jne   ppp      ;esli ne ravno, to est' esli polozhitelno
   mov   [DI], AX ;array=AX
   sub   [SI], AX ;result=result-AX
   ;------------------->may be overflow (OF=1)
   jno   propusk3
   cmp   flag, 1  ;flag=1 - otrizatelno, flag=0 - polozhitelno
   jne   of2       ;esli ne ravno, to est' esli polozhitelno
   cmp   AX,8000h
   jne of2         ;esli SI ne ravno 32768 i ne otrizatelno, to overflow
   jmp propusk3   ;esli SI ravno 32768 i otrizatelno, to ne overflow
of2:
   call overflow
   mov AX,[DI]
   add [SI],AX
   mov flag,0   
   jmp cycle
   ;------------------->if overflow hapenned (OF=1)
propusk3:
   neg   AX       ;AX=-AX
   dec   flag     ;flag--
   jmp   pp1:
   
ppp:                             
   mov   [DI], AX ;array=AX
   add   [SI], AX ;result=result+AX
   ;------------------->may be overflow (OF=1)
   jno   pp1
   call overflow
   mov AX,[DI]
   sub [SI],AX   
   jmp cycle
   ;------------------->if overflow hapenned (OF=1)
pp1:
   inc   DI    ;DI++
   dec   CX    ;CX--                 
   inc   BX    ;BX++              
   cmp   BX, 5                
   jnz   next  ;esli ne ravno 
   ;_____________ 
   inc   SI 
   inc   SI  
   ;_____________            
   xor   BX,BX                            
   mov   DX,offset message4               
   mov   AH,9                 
   int   21h   ;schtoby sdelat' vvod po 5 numbers v stroke               
next:
   cmp   CX, 0                                    
   jne   cycle   ;poka ne vvedyom 30 shtyk
   lea   SI, result
   mov   CX, 6
   mov   AH, 09h         
   mov   DX, offset Message2
   int   21h    
   jmp   exit              
    
    
   
   
    
ASC2HEX proc                                             
   push  CX 
   push  BX 
   push  SI 
   push  DI          
   xor   SI,SI  ;obnulyaem SI            
   mov   BX,10  ;zanosim v BX 10 dlya perevoda stroki v chislo umnozheniem              
   mov   CX,5   ;budet cycle na 5 raz              
typeDigit:                    
   xor   AX,AX                
   int   16h    ;chitat' klavishu v AL
   
   mov   BP, AX
   mov   [symbol], AL
   mov   AH, 09h         
   mov   DX, offset symbol
   int   21h
   mov   AX, BP
                    
   cmp   AL,'-'        ;esli minus, to povyshaem flag    
   jne   positive
   
   inc   flag
positive:                     
   cmp   AL,'0'               
   jb    typeDigit     ;esli vyshe       
   cmp   AL,'9'               
   ja    typeDigit     ;esli nizhe
   and   AX,0Fh        ;F=1111      
   xchg  AX,SI         ;perestanovka       
   mul   BX            ;BX*AL=10*AL v AX
   ;------------------->may be overflow (OF=1)
   jno   propusk1
   call overflow
   mov SI, 0
   mov CX,5   
   jmp typeDigit
   ;------------------->if overflow hapenned (OF=1)
propusk1:   
   add   SI,AX         ;SI+AX
   ;------------------->may be overflow (OF=1)
   jno   propusk2
   cmp   flag, 1  ;flag=1 - otrizatelno, flag=0 - polozhitelno
   jne   of1       ;esli ne ravno, to est' esli polozhitelno
   cmp   SI,8000h
   jne of1         ;esli SI ne ravno 32768 i ne otrizatelno, to overflow
   jmp propusk2   ;esli SI ravno 32768 i otrizatelno, to ne overflow
of1:
   call overflow   
   mov SI, 0
   mov CX,5   
   jmp typeDigit   
   ;------------------->if overflow hapenned (OF=1)
propusk2:
   loop  typeDigit     ;loop na 5 raz      
   xchg  AX,SI         ;perestanovka, teper' v AX nuzhnoe znachenie     
   pop   DI 
   pop   SI 
   pop   BX 
   pop   CX        
RET
ASC2HEX endp
 
 
OutInt proc
    push CX
    test AX, AX    ;sravnenie s null
    jns  oi1       ;esli net znaka

    mov  CX, AX
    mov  AH, 02h
    mov  DL, '-'
    int  21h
    mov  AX, CX
    neg  AX
oi1:  
    xor  CX, CX
    mov  BX, 10 
oi2:
    xor  DX,DX
    div  BX       ;AX/BX=AX/10   AX=chastnoe, DX=ostatok - cifra, chto nado vyvesti
    push DX       ;zanosim ee v stack
    inc  CX       ;uvelichivaem counter
    test AX, AX   ;sravnenie s null, esli ne null, znachit ne nado bol'she delit'
    jnz  oi2      ;esli ne null
    mov  AH, 02h
oi3:
    pop  DX       ;vyvodim cifri iz stack
    add  DL, '0'  ;preobrazyem v stroky
    int  21h      ;vyvodim
    loop oi3      ;v cycle
    pop  CX
    ret
 
OutInt endp
       
overflow proc
    mov   AH, 09h         
    mov   DX, offset Message3
    int   21h  
    ret
overflow endp    
   
exit:   
   mov AX, [SI]   ;AX->result
   call OutInt    ;vyvod odnogo chisla iz result
   mov DX, ' '
   int 21h
   inc SI
   inc SI
   dec CX         ;umenshaem counter
   cmp CX, 0
   jne exit       ;esli ne ravno
         
   lea SI, result ;SI->result
   lea DI, num    ;DI->num 
   mov CX, 2
   mov AX, [SI]   ;AX->result[0]
   inc SI
   inc SI
   mov ax,4C00h; zavershenie programmy
   int 21h
           
end START