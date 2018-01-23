 include io.inc
	.model small	; �������Ĵ洢ģʽ
	.stack	; �����ջ�Σ�Ĭ����1KB�ռ䣩
	.data
;˵��
mes   DB '**********************************************',0AH,0DH
	DB '***            PROJECT T_LIGHT             ***',0AH,0DH 
	DB '**********************************************',0AH,0DH,'$'

;С���ݱ仯״̬
brg byte 81h
bry byte 82h
bgr byte 24h
bgy byte 44h

;led���ֶ���
led byte 3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh
;led���ֻ�����
ledst byte 0,0,0,0
;led��ʾmask
ledmk byte 08h
;���̻Ƶ�ʱ��
time byte 35,30,5
;������ʣ��ʱ��
rtime byte 0,0
;�����Ƶ�״̬����
index byte 0,1

;һ����Ҫѭ���Ĵ���
seclpn word 10

;�ӳ�ѭ����ֵ
delay1n byte 30
delay2n byte 30
delay3n word 20

;��������
idxlpn word 2
;�����ҽ���
idxrlmt byte 3

;8255�˿ںͿ�����
a8255p word 288h
b8255p word 289h
c8255p word 28ah
s8255p word 28bh
;8255������
s8255s byte 80h

;�������ܸ�λ�ĳ���
modn byte 10

.code

;�ӳ��ӳ��������������ʾ
delay proc
	push cx
	push bx
del1:mov bh,delay1n 
del2:mov bl,delay2n 
del3:mov cx,delay3n 
del:	nop
	loop del
	dec bl
	jnz del3
	dec bh
	jnz del2
	pop bx
	pop cx
	ret
delay endp

;��õ�ǰ������������ʱ��
;����Ϊ��ǰ����(0,1)λ����al
gtime proc
	push ds
	push si
	push cx
	push bx
	push dx
	push ax

	mov ax,@data
	mov ds,ax

	pop ax
	push ax

	mov si,offset index
	mov cx,offset rtime
	mov bx,offset time
	mov ah,0
	add si,ax
	add cx,ax

	mov al,[si]
	mov dx,bx
	add dx,ax
	push si
	mov si,dx
	mov al,[si]
	mov si,cx
	mov [si],al
	pop si

	pop ax
	pop dx
	pop bx
	pop cx
	pop si
	pop ds
	ret
gtime endp

;����led��ʾ����ledst
sled proc
	push ax
	push ds
	push si
	push dx
	push cx
	push bx

	mov ax,@data
	mov ds,ax
	
	mov si,offset rtime
	mov dx,offset ledst
	mov cx,idxlpn
	mov bh,0
	mov bl,modn
sdstart:
	cmp cx,0
	jz sdend
	dec cx
	mov al,[si]
	mov ah,0
	div bl 		;ah������al��
	push si
	mov si,dx
	mov [si],al
	inc si
	mov [si],ah
	pop si
	add dx,2
	inc si
	jmp sdstart
sdend:
	pop bx
	pop cx
	pop dx
	pop si
	pop ds
	pop ax
	ret
sled endp

;��ʼ��оƬ�����
init proc
	push ax
	push ds
	push dx
	push si

	mov ax,@data
	mov ds,ax

	mov dx,s8255p   ;8255���ƶ˿ڳ�ʼ��
	mov al,s8255s
	out dx,al

	;mov si,offset index
	;mov al,[si]
	mov al,0
	call gtime
	;inc si
	;mov al,[si]
	inc al
	call gtime

	call sled

	pop si
	pop dx
	pop ds
	pop ax

	ret
init endp

;��������ѭ���ӳ���
;����Ϊ��ǰ������0,1��,λ����al
incidx proc
	push ax
	push cx
	push bx
	push si

	mov bh,0
	mov bl,al

	mov ax,@data
	mov ds,ax

	mov si,offset index
	mov cl,[si+bx]
	inc cl
	cmp cl,idxrlmt
	jb ictime
	mov cl,0
ictime:
	mov [si+bx],cl
	mov al,bl
	call gtime
incend:

	pop si
	pop bx
	pop cx
	pop ax
	ret
incidx endp

;��һ���ӳ���
;������һ������ݱ仯
nstep proc
	push ax
	push ds
	push si
	push cx

	mov ax,@data
	mov ds,ax
	mov si,offset rtime
	mov al,0
	mov ah,0
	mov cx,idxlpn
nsstart:
	cmp cx,0
	jz nsend
	dec cx
	push bx
	mov bx,ax
	mov dl,[si+bx]
	dec dl
	cmp dl,0
	jz cincidx
	mov [si+bx],dl
nscon:
	pop bx
	inc al
	jmp nsstart
cincidx:
	call incidx
	jmp nscon
nsend:
	call sled
	pop cx
	pop si
	pop ds
	pop ax
	ret
nstep endp

;�����������ӳ���
ledout proc
	push ax
	push bx
	push dx
	push ds

	mov ax,@data
	mov ds,ax
	
	mov si,offset ledst
	mov ah,ledmk
	mov bx,0

ledloop:
	mov bl,[si]
	inc si
	mov al,led[bx]
	mov dx,b8255p
	out dx,al
	mov al,ah
	mov dx,a8255p
	out dx,al
	call delay
	mov al,0
	mov dx,a8255p
	out dx,al
	ror ah,1
	cmp ah,ledmk
	jnz ledloop

	pop ds
	pop dx
	pop bx
	pop ax
	ret
ledout endp

;�����С�����ӳ���
bulbout proc
	push ax
	push ds
	push si
	push bx
	push dx

	mov ax,@data
	mov ds,ax
	
	mov si,offset index
	mov al,[si]
	cmp al,0
	jz cmpr
	cmp al,1
	jz gr
	mov al,bgy
	jmp bout
cmpr:
	inc si
	mov al,[si]
	cmp al,1
	jz rg
	mov al,bry
	jmp bout
gr:
	mov al,bgr
	jmp bout
rg:
	mov al,brg
bout:
	mov dx,c8255p
	out dx,al

	pop dx
	pop bx
	pop si
	pop ds
	pop ax
	ret
bulbout endp

;һ��ѭ���ӳ���
secloop proc
	push cx

bstart:
	mov cx,seclpn
	call bulbout

secstart:
	call ledout
	loop secstart
	call nstep
	jmp bstart

	pop cx
	ret
secloop endp

;������
start:
	mov ax,@data
	mov ds,ax

	mov dx,offset mes		
      mov ah,09
      int 21h				;��ʾ��ʾ��Ϣ

	call init
	call secloop
	.exit 0
	end start