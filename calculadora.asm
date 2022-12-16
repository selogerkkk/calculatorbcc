
section .data				;Constantes
	opcao db '0'
	sair db '0'
	espaco db '                                        '
	lenespaco: equ $-espaco
	msj0 db 'Ciencia da Computacao - IFMA'
	lenmsj0: equ $-msj0
	msj01 db 'Disciplina: Arquitetura de Computadores - Prof. Thiago Freire'
	lenmsj01: equ $-msj01
	msj02 db 'Alunos: Ruan Henrique, Carlos Adriano'
	lenmsj02: equ $-msj02
	msj1 db ' Escolha a operacao: ', 13, 10
	lenmsj1: equ $-msj1
	msjOpc db '1-Soma 2-Subtracao 3-Multiplicacao 4-Divisao', 13, 10
	lenmsjOpc: equ $-msjOpc
	msjn1 db 'numero 1: '
	lenmsjn equ $-msjn1
	msjn2 db 'numero 2: '
	msjres db 13, 10, 'Resultado: '
	lenmsjres equ $-msjres
	Sair db 13, 10, 10, 'Quer sair? [S/N]', 13, 10
	lenSair equ $-Sair

section .bss				;Variaveis
	numero1 resd 1
	numero2 resd 1
	resultado resd 1
	cadeia1 resb 10
	cadeia2 resb 10
	cadeiaRes resb 10
	cadeiaF resb 10
	longitude1 resb 1
	longitude2 resb 1
	sinal resb 1

section .text

%macro Input 2			;Input (1:Variavel, 2:Longitude)
	mov eax, 3
	mov ebx, 1
	mov ecx, %1
	mov edx, %2
	int 80h
%endmacro

%macro Output 2			;Output (1:Variavel 2:Longitude)
	mov eax, 4
	mov ebx, 1
	mov ecx, %1
	mov edx, %2
	int 80h
%endmacro


%macro Longitude 2	;Salvar Longitude variavel (1:Variavel 2:Longitude)
	xor esi, esi
	xor eax, eax
	contar%1:
	mov al, [%1+esi]
	cmp al, ''
	jne incrementar%1
	je final%1
	
	incrementar%1:
	inc esi
	jmp contar%1
	
	final%1:
	dec esi
	mov [%2], esi
	xor esi, esi
	xor eax, eax
%endmacro

%macro CadeiaEmNumero 3		;Converter cadeia em numero (1:Numero 2:Cadeia 3:Cadeia Longa)
	mov esi, [%3]
	dec esi
	mov ecx, [%3]
	mov ebx, 1
	cadeiaEmNum%1:
	xor eax, eax
	mov al, [%2+esi]
	sub al, 30h
	mul ebx
	add [%1], eax
	
	mov eax, ebx
	mov edx, 10
	mul edx
	mov ebx, eax
	dec esi
	LOOP cadeiaEmNum%1
%endmacro

%macro LimparCadeia 2			;Limpar cadeia (1:Cadeia 2: Cadeia Longa)
	xor eax, eax
	xor esi, esi
	mov al, ''
	mov ecx, %2
	cicloLimpar%1:
	mov [%1+esi], al
	inc esi
	LOOP cicloLimpar%1
%endmacro


;Main
global _start:
_start:
	
	Inicio:				;Limpa a tela antes de seguir
	
	xor eax, eax
	mov [numero1], eax
	mov [numero2], eax
	mov [resultado], eax
	LimparCadeia cadeia1, 10
	LimparCadeia cadeia2, 10
	LimparCadeia cadeiaRes, 10
	LimparCadeia cadeiaF, 10
	
	Output msj0, lenmsj0 
	Output espaco, lenespaco
	
	Output msj01, lenmsj01 
	Output espaco, lenespaco
	
	Output msj02, lenmsj02 
	Output espaco, lenespaco
	
	Output msj1, lenmsj1		;Inicio com opçoes
	
	Output msjOpc, lenmsjOpc
	Input opcao, 2
	mov al, [opcao]     		;Verifica a opcao
	cmp al, '1'
	jb Inicio
	cmp al, '4'
	ja Inicio
	
	Output msjn1, lenmsjn		;Processa primeiro numero
	Input cadeia1, 10
	Longitude cadeia1, longitude1
	CadeiaEmNumero numero1, cadeia1, longitude1
	
	
	Output msjn2, lenmsjn		;Processa segundo numero
	Input cadeia2, 10
	Longitude cadeia2, longitude2
	CadeiaEmNumero numero2, cadeia2, longitude2
	

	mov eax, [numero1]		;Processa operacao
	mov ebx, [numero2]
	mov dl, [opcao]
	cmp dl, '1'
	je Somar
	cmp dl, '2'
	je Subtrair
	cmp dl, '3'
	je Multiplicar
	cmp dl, '4'
	je Dividir
	
	Somar:				;Soma
	add eax, ebx
	jmp Resultado
	Subtrair:				;Subtracao
	sub eax, ebx
	jmp processarSubtracao
	Multiplicar:			;Multiplicacao
	mul ebx
	jmp Resultado
	Dividir:			;Divisao
	xor edx, edx
	idiv ebx
	push edx
	jmp Resultado
	
	processarSubtracao:			;Processar a Subtracao por si e negativo
	cmp eax, 0
	jg Resultado
	jl negativo
	negativo:
	neg eax
	mov bl, '-'
	mov [sinal], bl
	jmp Resultado
	
	;Converte o numero resultado (eax) em cadeia de caracteres
	
	Resultado:
	xor esi, esi
	mov ebx, 10
	acadeia:
	xor edx, edx
	idiv ebx
	add edx, 30h
	mov [cadeiaRes+esi], edx
	inc esi
	cmp eax, 0
	jne acadeia
	
	Invertercadeia:
	mov eax, cadeiaRes 		;Inverte cadeia (resultado)
	mov esi, 0
	mov edi, 9
	mov ecx, 10
	inverter:
	xor ebx, ebx
	mov bl, [eax+esi]
	mov [cadeiaF+edi], bl
	inc esi
	dec edi
	LOOP inverter
	
	Output msjres, lenmsjres	;Imprime resulado
	Output sinal, 1
	Output cadeiaF, 10
	
	Output Sair, lenSair 		;Sair ou continuar
	Input sair, 2
	mov al, [sair]
	cmp al, 'n'
	je Inicio
	
	mov eax, 1			;Sair	
	int 80h