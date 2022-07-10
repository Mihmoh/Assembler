.model small

.stack 100h 

.data
    stroka db 202,202 dup ('$') ;nasha stroka
    vvedi db "Enter string: $"  ;privetstvennoe soobshenie
    kysh db "Eto nado delete  $"  ;privetstvennoe soobshenie
    razmer dw ?                 ;razmer stroki
    index dw ?
.code
.386
start:   
    mov ax,@data;podsoedinenie segmenta dannyh
    mov ds,ax
    
    lea dx, vvedi ;adress stroki 'vvedi' v DX
    call vyvod    ;output this stroky
    lea dx, stroka;adress stroki 'stroka' v DX
    call vvod     ;vvesti stroky
    
    lea dx, stroka
    call vyvod    ;output this stroky
    call enter
    
    mov cx,razmer    
    mov si,0      ;index stroki
    mov di,0      ;index nachala ocherednogo slova
    mov ax,si     ;nachalo pervogo slova
    ;________________________

slovo:      
    mov al,stroka[si]
    cmp al,24h ;24h=$
    je hvatit  ;zakanchivaem razdelenie na slova
    cmp al,20h ;20h=probel
    je stop_slovo;otpravlyaemsya v otdelenie slova
    dec cx    ;CX--
    inc si    ;SI++
    jmp slovo    
    
stop_slovo:
    inc si
    dec cx
    inc bx         ;menyaem schyotchiki na sluchay neskolkih probelov podryad
    
    mov al,stroka[si]
    cmp al,20h     ;esli sledyuschiy symbol=probel, to propyskaem ego
    je slovo
    
    dec si
    inc cx
    dec bx
    
    mov index,si   ;sohranyaem tekyshiy index
    push si
    push di
    push cx
    mov si,di      ;perenosimsya na nachalo slova
    mov cx,0       ;budem schitat' dliny slova

loop1:
    cmp index,si        ;proveryaem doshli li do tekyshego indexa
    je otdelili_slovo
  
    mov dl,stroka[si]   ;vyvodim posimvolno slovo
    mov ah,02h    
    int 21h    
    
    inc si
    inc cx
    cmp dl,2Fh
    jg chislo_li
    
    jmp loop1
    
chislo_li:  
    cmp dl,3Ah
    jl da
    
    jmp loop1
    
da:
    inc bx   ;esli symvol - cifra, to uvelichivaem bx
    
    jmp loop1    
    
otdelili_slovo:
 
    call enter
    
    cmp bx,cx ;esli BX=CX, to vsyo slovo sostoit iz cifr i ego nado udalit'
    je delete
    
    mov bx,0
    
    pop cx 
    pop di
    pop si    
    
    dec cx    ;CX--
    inc si    ;SI++
    mov di,si ;stavim nachalo slova na tekyshyu position
    jmp slovo
    
delete:
    lea dx, kysh
    call vyvod
    call enter
    mov si,di
    inc si
         
udalyaem:    
    mov al,stroka[si]   ;peremeschaem sledyushiy v predydushiy
    mov stroka[si-1],al    
    cmp al,24h
    je udalili_1
    inc si         ;SI++
    jmp udalyaem 
    
    
    
udalili_1:    
    dec razmer
    dec bx
    cmp bx,0
    je udalili_vsyo
    mov si,di
    inc si
    jmp udalyaem
    
udalili_vsyo:
    inc di
    mov si,di
    jmp slovo 
    
;_________________________;
hvatit:                   ;
                          ;
    inc si                ;
    dec cx                ;
    inc bx         ;menyaem schyotchiki na sluchay neskolkih probelov podryad
                          ;
    mov al,stroka[si]     ;
    cmp al,20h     ;esli sledyuschiy symbol=probel, to propyskaem ego
    je hvatit             ;
                          ;
    dec si                ;
    inc cx                ;
    dec bx                 ;e
                           ;t
    mov index,si            ;o
    push si                  ;
    push di                   ;
    push cx                    ;v
    mov si,di                  ;s                    
    mov cx,0                    ;y
                                 ;o
loop2:                            ; 
    cmp index,si                   ;ch
    je tochno_hvatit                ;t
    mov dl,stroka[si]                ;o
    mov ah,02h                        ;b
    int 21h                            ;
    inc cx                             ; 
    inc si                              ;v
                                        ;
    cmp dl,2Fh                          ;p
    jg chislo_li2                        ;o
                                         ;s
    jmp loop2                            ;l
                                         ;e
chislo_li2:                              ;d
    cmp dl,3Ah                           ;n
    jl da2                               ;i
                                         ;y
    jmp loop2                            ;
                                          ;
da2:                                       ;
    inc bx   ;esli symvol - cifra, to uvelichivaem bx
                                           ;
    jmp loop2                             ;r
                                          ;a 
tochno_hvatit:                             ;z         
                                            ;
    cmp bx,cx ;esli BX=CX, to vsyo slovo sostoit iz cifr i ego nado udalit'
    je delete2                               ;
                                             ;s
    pop cx                                    ;d     
    pop di                                     ;e
    pop si                                      ;l
    dec cx    ;CX--                              ;a
    inc si    ;SI++                               ;t'
    mov di,si                                     ;
                                                  ;p
    jmp vyhod                                     ;r
                                                  ;o
delete2:                                          ;h
    lea dx, kysh                                  ;o
    call vyvod                                    ;d
    call enter                                    ;
    mov si,di                                     ; 
    inc si                                        ;
                                                  ;
udalyaem2:                                        ;
    mov al,stroka[si]   ;peremeschaem sledyushiy v predydushiy
    mov stroka[si-1],al                           ;
    cmp al,24h                                    ;
    je udalili_2                                  ;
    inc si         ;SI++                          ;
    jmp udalyaem2                                 ;
                                                  ;
udalili_2:                                        ;
    dec razmer                                    ;
    dec bx                                        ;
    cmp bx,0                                      ;
    je udalili_vsyo2                              ;
    mov si,di                                     ;
    inc si                                        ;
    jmp udalyaem2                                 ;
                                                  ;
udalili_vsyo2:                                    ;
    inc di                                        ;
    mov si,di                                     ;
    jmp vyhod                                     ;
                                                  ;
loop3:                                            ;
    cmp index,si                                  ;
    je vyhod                                      ;
    mov dl,stroka[si]                             ;
    mov ah,02h                                    ;
    int 21h                                       ;
    inc si                                        ;
    jmp loop3                                     ;
;_________________________________________________;
vyhod:                                                    
    lea dx, stroka                                   
    call vyvod    ;output this stroky

    mov ax,4C00h; zavershenie programmy
    int 21h
    
;Procedures (Functions)

vyvod proc     ;function, kotoraya vyvodit stroky  
    push ax      ;zanesti vse obshie registry v stack
    push bx
    push cx
    push dx
    
    mov DL, 0Dh;symbol perehoda na nachalo current stroki
    mov Ah, 02h;output symbol iz DL
    int 21h 
    
    mov DL, 0Ah;cursor na odny position vniz
    mov Ah, 02h;output symbol iz DL
    int 21h          
    
    pop dx       ;vynesti vse obshie registry iz stack
    pop cx 
    pop bx
    pop ax
    mov ah,9   ;output stroki po adresy DS:DX
    int 21h
    
    ret    
vyvod endp

enter proc
    
    push ax      ;zanesti vse obshie registry v stack
    push bx
    push cx
    push dx
    
    mov DL, 0Dh;symbol perehoda na nachalo current stroki
    mov Ah, 02h;output symbol iz DL
    int 21h 
    
    mov DL, 0Ah;cursor na odny position vniz
    mov Ah, 02h;output symbol iz DL
    int 21h          
    
    pop dx       ;vynesti vse obshie registry iz stack
    pop cx 
    pop bx
    pop ax    
    
    ret    
enter endp

vvod proc      ;function of vyvod
    
    push ax    ;zanesti ax v stack
    push bx    ;zanesti bx v stack
    push cx    ;zanesti cx v stack
    mov cx,200 ;kolichestvo schityvaemyh symbols
    mov bl,0Dh
    mov si,0 
    
read_1_symbol:
       
    
    mov ah,01h ;read iz STDIN symbol
    int 21h
    
    dec cx     ;CX--
    cmp bl,al  ;sravnit SI i AL na enter
    
    je stop    ;esli schitali enter to vsyo
    jcxz stop  ;esli CX=200 to vsyo
    
    mov stroka[si], al ;zapisyvaem v stroky symbol
    inc si
    
    jmp read_1_symbol
    
stop:
    
    pop cx     ;vynesti cx iz stack
    pop bx     ;vynesti bx iz stack
    pop ax     ;vynesti ax iz stack
    mov razmer, si
    ret
     
vvod endp 

end start