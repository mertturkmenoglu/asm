stackseg		SEGMENT PARA STACK 'stack'
			DW 50 DUP(?)
stackseg 		ENDS

dataseg		SEGMENT PARA 'data'
dizi			DB 100 DUP(?)
n			DB ?
altSinir		DW -128
ustSinir		DW 127
CR      		EQU 13
LF      		EQU 10
MSG1    		DB 'DIZI UZUNLUGUNU VERINIZ: ',0
MSG2    		DB CR, LF, 'SAYIYI VERINIZ: ', 0
HATA    		DB CR, LF, 'DIKKAT !!! SAYIYI VERMEDINIZ YENIDEN GIRIS YAPINIZ.!!! ', 0
MSG3   		DB ' ', 0
SONUC   		DB CR, LF, 'TOPLAM ', 0

dataseg		ENDS

codeseg		SEGMENT PARA 'code'
			ASSUME DS:dataseg, CS: codeseg, SS: stackseg			; Segmentlere erismek için gerekli tanimlar
ANA			PROC FAR	
			
			PUSH DS										; Onceki programin kendi data segmentine erismesi icin gecmis ds yi stack e atar
			XOR AX, AX									; OFFSET adresi olarak AX  i sifirlar
			PUSH AX										; stack e atar															
				
			MOV AX, dataseg								; Kendi data segmentimize erismek icin
			MOV DS, AX									; gerekli tanimlar
			
NOKU:		MOV AX, OFFSET MSG1							; Mesaj offset ini AX e alir
			CALL PUT_STR									; Mesaji ekrana yazdirir
			CALL GETN									; Klavyeden dizi uzunlugunu AL yazmacina okur
			CMP AL, 0										; Dizi uzunlugunun
			JE NOKU										; Kontrol edilmesi
			CMP AL, 100									; Yanlissa tekrar
			JAE NOKU										; Okunmasi
			
			MOV n, AL									; Dizi uzunlugunu n degiskenine atar
			CALL DIZIOKU									; Dizi elemanlarini okuyacak olan yordami cagirir
														; Quick sort fonksiyonu low index ve high index isimli iki
														; parametre alir. Bu parametreler AX registerina aktariliyor
														; Yordam icerisinde AX e erisiliyor
			MOV AH, n									; AH <- highIndex = n-1
			DEC AH										; AH = n - 1
			MOV AL, 0									; AL <- lowIndex = 0
			
			CALL QUICKSORT								; Quick sort yordam cagrisi
			
			CALL DIZIYAZDIR								; Sirali diziyi ekrana yazdiracak olan diziyazdir yordam cagrisi

			RETF											; Ana prosedurun bitisi
ANA 			ENDP										; Prosedur sonu


DIZIOKU 		PROC NEAR									; Dizi okuma yordami
			PUSH CX										; Kullanilan registerlarin 
			PUSH SI										; Onceki degerlerini korumak icin
			PUSH AX										; stack e atilmasi
			
			XOR CX, CX									; Dongu sayisi CL uzerinde tutulacak. CH in da sifirlanmasi gerekiyor
			MOV CL, n									; CL <- n
			XOR SI, SI									; Dongu indisi SI olacak, SI sifirlaniyor
			
DONGU1:													; Diziyi okumak icin dongu
			MOV AX, OFFSET MSG2							; Mesaj offseti AX e aliniyor
			CALL PUT_STR									; Mesaj ekrana yazdiriliyor
			CALL GETN									; Dizi elemani AX e okunuyor
			CMP AX, ustSinir								; Hatali giris kontrolu
			JNL HATAGIR									; Hata mesajina atla
			CMP AX, altSinir								; Hatali giris kontrolu 
			JNG HATAGIR									; Hata mesajina atla
			MOV dizi[SI], AL								; Okunan degeri diziye al
			INC SI										; Dongu indisini arttir
			LOOP DONGU1									; Dongu basina don
			JMP DEVAM
HATAGIR:		
			MOV AX, OFFSET HATA							; Hata mesajinin yazdirilmasi
			CALL PUT_STR
			JMP DONGU1									; Ayni indis için tekrar okuma
DEVAM:		POP AX										; Yordam cagrisindan onceki registerlarin
			POP SI										; degerlerinin stackten
			POP CX										; geri cekilmesi
			RET											; Dizioku prosedurunun bitmesi
DIZIOKU 		ENDP										; Prosedur sonu
			

QUICKSORT 	PROC NEAR									; Quick sort prosedurunun baslangici
			PUSH BX										; Yordam cagrisindan
			PUSH SI										; Onceki register degerlerinin korunmasi icin
			PUSH AX										; Degerler stack e atiliyor
			
			CMP AH, AL									; low < high kontrolu yapiliyor
			JNG bitis										; degilse fonksiyon sonuna gidilir
			CALL PARTITION								; Partition fonksiyonu cagriliyor
														; pivotIndex, SI uzerinden donuruyor
			
			MOV BX, SI									; pivotIndex byte register a atilmak icin BX e aliniyor
			PUSH AX										; high ve low indis degerlerini korumak icin stack e atiliyor
			MOV AH, BL									; quick sort kendisini low, pivotIndex-1 
			DEC AH										; parametreleriyle tekrar cagiriyor
			CALL QUICKSORT								; Rekursif olarak kendini cagiriyor
			POP AX										; high ve low indis degerlerini stackten geri aldik
			MOV AL, BL									; quick sort bu sefer kendisini 
			INC AL										; pivotIndex+1, high parametreleriyle
			CALL QUICKSORT								; tekrar cagiriyor
bitis:	
			POP AX										; Fonksiyon cagrisindan onceki register degerlerinin 
			POP SI										; stackten geri cekilip
			POP BX										; registerlara atanmasi
			
			RET											; quick sort yordaminin bitmesi
QUICKSORT 	ENDP										; prosedur sonu

PARTITION	PROC NEAR									; partition fonksiyonu baslangici

			PUSH BX										; Kullanilan registerlarin
			PUSH CX										; fonksiyon cagrisindan onceki degerlerini
			PUSH DX										; korumak icin stack e
			PUSH DI										; atilmasi
			
			XOR BX, BX									; dizi indisi olarak kullanilacak degerin BL ye atilmasi gerekiyor. 
														; BH da sifirlanmali BX <- 0
			XOR DX, DX									; DX temp degisken gorevi icin sifirlaniyor
			MOV BL, AH									; highIndex'in indis olarak kullanilabilmesi icin BX e atilmasi gerekiyor
			MOV DH, dizi[BX]								; DH = pivot 
			
			MOV BL, AL									; BL <- lowIndex
			MOV SI, BX									; SI <- lowIndex
			DEC SI 										; SI  = low - 1
			
			XOR CX, CX									; Dongu sayisi CL de tutulacak. CH sifirlanmali
			MOV CL, ah									; Dongu high-low kez doner
			SUB CL, AL 									; CX = high - low 				
			MOV DI, BX 									; DI dongu degiskeni
P1:			
			CMP DH, dizi[DI]								; dizi[j] <= pivot mu kontrolunun yapilmasi
			JL artirim										; degilse dongu indisini artirmaya git
			INC SI										; i++ isleminin yapilmasi	
			MOV DL, dizi[SI]								; dizi[i] ve dizi[j] nin yer degistirmesi
			XCHG DL, dizi[DI]								; icin registera atilip
			MOV dizi[SI], DL								; exchange edilmesi
artirim: 		INC DI										; dongu indisinin artirilmasi
			LOOP P1										; dongu basi P1 e donulmesi
			
			INC SI 										; i += 1
			XOR BX, BX									; BX index olarak kullanilacak sifirlanmali
			MOV BL, AH 									;  BL = high	
			MOV DL, dizi[SI]								; dizi[i] ve dizi[high]	
			XCHG DL, dizi[BX]								; degerleri swap edilmek icin
			MOV dizi[SI], DL								; register a alinip exchange islemleri yapiliyor
			
			POP DI										; fonksiyon oncesindeki register degerlerinin
			POP DX										; geri alinmasi icin
			POP CX										; degerler stackten
			POP BX										; geri aliniyor
				
			RET											; fonksiyon sonu
PARTITION	ENDP



GETC    PROC NEAR
        
        ;------------------------------------------------------------------------------------------;
        ; KLAVYEDEN BASILAN KARAKTERI AL YAZMACINA ALIR VE EKRANDA GOSTERIR.;
        ; ISLEM SONUCUNDA SADECE AL ETKILENIR                                                     ;
        ;------------------------------------------------------------------------------------------;
        
        MOV AH, 1H
        INT 21H
        RET
GETC    ENDP


PUTC    PROC NEAR
        
        ;---------------------------------------------------------------------------------------------;
        ; AL YAZMACINDAKI DEGERI EKRANDA GOSTERIR. DL VE AH DEGISIYOR. AX VE DX;
        ; YAZMACLARININ DEGERLERINI KORUMAK ICIN PUSH POP YAPILIR                       ;
        ;---------------------------------------------------------------------------------------------;
        
        PUSH AX
        PUSH DX
        MOV DL, AL
        MOV AH, 2
        INT 21H
        POP DX
        POP AX
        RET
PUTC    ENDP


GETN    PROC NEAR    
    
        ;-----------------------------------------------------------------------------------------------;
        ; KLAVYEDEN BASILAN SAYIYI OKUR, SONUCU AX YAZMACI UZERINDEN DONDURUR  ;
        ; DX: SAYININ ISARETLI OLUP OLMADIGINI BELIRLER. 1(+), -1(-) DEMEK                 ;
        ; BL: HANE BILGISINI TUTAR                                                                                  ;
        ; CX: OKUNAN SAYININ ISLENMESI SIRASINDAKI ARA DEGERI TUTAR.                      ;
        ; AL: KLAVYEDEN OKUNAN KARAKTERI TUTAR (ASCII)                                              ;
        ; AX ZATEN DONUS DEGERI OLARAK DEGISMEK ZORUNDADIR. ANCAK DIGER            ;
        ; YAZMACLARIN ONCEKI DEGERLERI KORUNMALIDIR.                                               ;
        ;-----------------------------------------------------------------------------------------------;
        
        PUSH BX
        PUSH CX
        PUSH DX
GETN_START:
        MOV DX, 1       ; SAYININ SIMDILIK + OLDUGUNU VARSAYALIM
        XOR BX, BX      ; OKUMA YAPMADI HANE 0 OLUR
        XOR CX, CX      ; ARA TOPLAM DEGERI DE 0 OLUR
NEW:    
        CALL GETC       ; KLAVYEDEN ILK DEGERI AL'YE OKU
        CMP AL, CR
        JE FIN_READ     ; ENTER TUSUNA BASILMIS ISE OKUMA BITER
        CMP AL, '-'     ; AL, '-' MI GELDI?
        JNE CTRL_NUM    ; GELEN 0-9 ARASI BIR SAYI MI?
NEGATIVE:
        MOV DX, -1      ; - BASILDI ISE SAYI NEGATIF, DX = -1 OLUR
        JMP NEW         ; YENI HANEYI AL
CTRL_NUM:
        CMP AL, '0'     ; SAYININ 0-9 ARASINDA OLDUGUNU KONTROL ET
        JB ERRORR
        CMP AL, '9'
        JA ERRORR        ; DEGIL ISE HATA MESAJI VERILECEK
        SUB AL, '0'     ; RAKAM ALINDI, HANEYI TOPLAMA DAHIL ET
        MOV BL, AL      ; BL'YE OKUNAN HANEYI KOY
        MOV AX, 10      ; HANEYI EKLERKEN * 10 YAPILACAK
        PUSH DX         ; MUL KOMUTU DX'I BOZAR ISARET ICIN SAKLANMALI
        MUL CX          ; DX:AX = AX * CX
        POP DX          ; ISARETI GERI AL
        MOV CX, AX      ; CX DEKI ARA DEGER * 10 YAPILDI
        ADD CX, BX      ; OKUNAN HANEYI ARA DEGERE EKLE
        JMP NEW         ; KLAVYEDEN YENI BASILAN DEGERI AL
ERRORR:
        MOV AX, OFFSET HATA
        CALL PUT_STR    ; HATA MESAJINI GOSTERIR
        JMP GETN_START  ; O ANA KADAR OKUNANLARI UNUT YENIDEN ALMAYA BASLA
FIN_READ:
        MOV AX, CX      ; SONUC AX UZERINDEN DONECEK
        CMP DX, 1       ; ISARETE GORE SAYIYI AYARLAMAK LAZIM
        JE FIN_GETN    
        NEG AX          ; AX = -AX
FIN_GETN:
        POP DX
        POP CX
        POP DX
        RET
GETN    ENDP



PUTN    PROC NEAR
;---------------------------------------------------------------------------------------------;
; AX DE BULUNAN SAYIYI ONLUK TABANDA HANE HANE YAZDIRIR. 			 ;
; CX: HANELERI 10 A BOLEREK BULACAGIZ, CX=10 OLACAK					 ;
; DX: 32 BOLMEDE ISLEME DAHIL OLACAK SONUCU ETKILEMESIN DIYE 0 OLMALI  ;
;--------------------------------------------------------------------------------------------;
		PUSH CX
		PUSH DX
		XOR DX, DX		; DX 32 BIT BOLMEDE SONUCU ETKILEMESIN DIYE 0 OLMALI
		PUSH DX			; HANELERI ASCII KARAKTER OLARAK YIGINDA SAKLAYACAGIZ
						; KAC HANEYI ALACAGIMIZI BILMEDIGIMIZ ICIN YIGINA 0 
						; DEGERI KOYUP ONU ALANA KADAR DEVAM EDELIM
		MOV CX, 10		; CX = 10
		CMP AX, 0
		JGE CALC_DIGITS
		NEG AX			; SAYI NEGATIF ISE AX POZITIF YAPILIR
		PUSH AX			; AX SAKLA
		MOV AL, '-'		; ISARETI EKRANA YAZDIRIR
		CALL PUTC		
		POP AX			; AX'I GERI AL
	CALC_DIGITS:
		DIV CX			; DX:AX = AX / CX   AX = BOLUM DX = KALAN
		ADD DX, '0'		; KALAN DEGERINI ASCII OLARAK BUL
		PUSH DX   		; YIGINA SAKLA
		XOR DX, DX		; DX = 0
		CMP AX, 0		; BOLEN 0 KALDI ISE SAYININ ISLENMESI BITTI DEMEK
		JNE CALC_DIGITS ; ISLEMI TEKRARLA
	DISP_LOOP:
						; YAZILACAK TUM HANELER YIGINDA EN ANLAMLI HANE USTTE
						; EN AZ ANLAMLI HANE EN ALTA VE ONUN ALTINDA DA SONA VARDIGIMIZI
						; ANLAMAK ICIN KONAN 0 DEGERI VAR
		POP AX 			; SIRAYLA DEGERLERI YIGINDAN ALALIM
		CMP AX, 0		; AX = 0 OLURSA SONA GELDIK DEMEKTIR
		JE END_DISP_LOOP
		CALL PUTC		; AL DEKI ASCII DEGERI YAZ
		JMP DISP_LOOP	; ISLEME DEVAM ET
	END_DISP_LOOP:
		POP DX
		POP CX
		RET
PUTN 	ENDP


PUT_STR		PROC NEAR
;----------------------------------------------------------------------------------------------------;
; AX DE ADRESI VERILEN SONUNDA 0 OLAN DIZGEYI KARAKTER KARAKTER YAZDIRIR     ;
; BX DIZGEYE INDIS OLARAK KULLANILIR ONCEKI DEGERI SAKLANMALIDIR                    ;
;----------------------------------------------------------------------------------------------------;
		PUSH BX
		MOV BX, AX
		MOV AL, BYTE PTR [BX]
	PUT_LOOP:
		CMP AL, 0
		JE PUT_FIN
		CALL PUTC
		INC BX
		MOV AL, BYTE PTR [BX]
		JMP PUT_LOOP
	PUT_FIN:
		POP BX
		RET
PUT_STR 	ENDP
			
			
DIZIYAZDIR		PROC NEAR

				PUSH CX						; register degerlerinin korunmasi
				PUSH SI
				PUSH AX
		
				XOR CX, CX					; dongu n kez donecek
				MOV CL, n					; CX sifirlanip CL ye atiliyor
				XOR SI, SI					; dizi indisi SI
YAZI_DON:
				XOR AX, AX					; Deger AL ye alinacak AX sifirlanmali
				MOV AL, dizi[SI]				; Deger AL ye aliniyor
				CBW							; En anlamli bit AH a yaziliyor
				CALL PUTN					; Sayi ekrana yaziliyor
				MOV AX, OFFSET MSG3			; Araya bosluk karakteri 
				CALL PUT_STR					; yazdiriliyor
				INC SI						; i+=1
				LOOP YAZI_DON				; dongu basina don
		
				POP AX						; registerlarin onceki degerlerinin geri alinmasi
				POP SI
				POP CX
				RET
DIZIYAZDIR 		ENDP

codeseg 			ENDS
				END ANA
			
			
			



			
			
			
			