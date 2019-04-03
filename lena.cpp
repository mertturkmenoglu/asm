#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <iostream>
#include "image_processing.cpp"
#include "image.h"

using namespace std;

void sagaDondur(short n, int resim);
void solaDondur(short n, int resim);

int main(void) {
	int M, N, Q, i, j, k;
	bool type;
	int efile, islem;
	char resimadi[100], sonek[10];
	do {
		printf("\n Mert TURKMENOGLU\n");
		printf("Islem yapilacak resmin yolunu (path) giriniz:\n-> ");
		scanf("%s", &resimadi);
		system("CLS");
		efile = readImageHeader(resimadi, N, M, Q, type);
	} while (efile > 1);
	printf("%s\n", resimadi);
	int** resim = resimOku(resimadi);

	short *resimdizi;
	resimdizi = (short*) malloc(N*M * sizeof(short));

	for (i = 0; i < N; i++) 
		for (j = 0; j < M; j++) 
			resimdizi[i*N + j] = (short) resim[i][j];

	int resimadres = (int) resimdizi;

	do {
		system("CLS");
		printf("\n Mert TURKMENOGLU\n");
		printf("\t     ISLEMLER\n");
		printf("------------------------------------\n");
		printf("1)  Resmi saga dondur\n");
		printf("2)  Resmi sola dondur\n");
		printf("0)  Cikis\n\n");
		printf("\"%s\" yolundaki resim icin yapilacak islemi seciniz\n-> ", resimadi);
		scanf("%d", &islem);
	} while (islem > 2 || islem < 0);
	int temp;
	switch (islem) {
		case 0:
			exit(0);
		case 1:
			sagaDondur(N, resimadres);
			strcpy(sonek, "_sag.pgm");
			break;
		case 2:
			solaDondur(N , resimadres);
			strcpy(sonek, "_sol.pgm");
			break;
		default:
			strcpy(sonek, "_orj.pgm");
			break;
	}

	for (k = 0; k < N * M; k++) {
		j = k % N;
		i = k / N;
		resim[i][j] = (int)resimdizi[k];
	}
	
	string::size_type pos = string(resimadi).find_last_of(".");
	resimadi[pos] = '\0';
	strcat(resimadi, sonek);
	resimYaz(resimadi, resim, N, M, Q);
	printf("\nIslem basariyla tamamlandi :)\n\"%s\" yolunda resim olusturuldu.\n\n", resimadi);
	system("PAUSE");
	return 0;
}

void sagaDondur(short n, int resim) {
	//KODUNUZU BURADAN BASLAYARAK YAZINIZ
	__asm {
		XOR ESI, ESI			// ESI i olarak kullanýlacak sifirlaniyor
		XOR ECX, ECX			// ECX n degerini tutacak sifirlanýyor
		MOV CX, n				// CX e n degeri aktariliyor
		LL1 :
		CMP ESI, ECX			// i<n mi kontrolu
		JAE LL1SON				// degilse transpoze sonuna git
		MOV EDI, ESI			// EDI j olacak j=i yapiliyor
		LL2 :
		CMP EDI, ECX			// j<n mi kontrolu
		JAE LL2SON				// degilse loop sonuna git

		MOV EAX, ESI			//EAX <- i
		XOR EDX, EDX			// EDX sifirlaniyor
		MOV DX, n				// EDX <- n
		MUL EDX					// EAX <- i*n
		ADD EAX, EDI			// EAX <- i*n+j
		ADD EAX, EAX			// EAX <- EAX + EAX
		MOV EBX, EAX			// EBX <- EAX

		XOR EAX, EAX			// EAX <- 0
		MOV EAX, EDI			// EAX <- j
		XOR EDX, EDX			// EDX <- 0 carpma icin
		MOV DX, n				// EDX <- n
		MUL EDX					// EAX <- j*n
		ADD EAX, ESI			// EAX <- j*n+i
		ADD EAX, EAX			// EAX <- EAX + EAX

		MOV EDX, EBX			// EDX <- i*n+j

		MOV EBX, resim			// EBX <- &resim
		ADD EBX, EDX			// EBX <- EBX + i*n+j
		XOR ECX, ECX			// ECX temp register olarak kullanýlacak
		MOV CX, WORD PTR[EBX]	// CX <- *(resim+i*n+j)
		PUSH ECX				// Stack e at

		MOV EBX, resim			// EBX <- &resim
		ADD EBX, EAX			// EBX <- EBX + j*n+i
		XOR ECX, ECX			// ECX temp register olarak kullanýlacak
		MOV CX, WORD PTR[EBX]	// CX <- *(resim+j*n+i)
		PUSH ECX				// Stack e at

		MOV EBX, resim			// EBX <- &resim
		ADD EBX, EDX			// EBX <- EBX + i*n+j
		POP ECX					// Stackteki degeri ECX e al
		MOV WORD PTR[EBX], CX	// *(resim+i*n+j) ye *(resim+j*n+i) nin degeri
								// aktarildi

		MOV EBX, resim			// EBX <- &resim
		ADD EBX, EAX			// EBX <- EBX + j*n+i
		POP ECX					// Stackteki degeri ECX e al
		MOV WORD PTR[EBX], CX	// *(resim+j*n+i) ye *(resim+i*n+j) nin eski degeri 
								// aktarildi

		XOR ECX, ECX			// Donmeden once ECX i 
		MOV CX, n				// eski haline getirir

		INC EDI					// j++
		JMP LL2					// ic while dongusu
		LL2SON :				// ic while dongusu sonu
		INC ESI					// i++
		JMP LL1					// dis while dongusu
		LL1SON :				// dis while dongusu sonu
								// transpoze islemi bitti


		XOR ECX, ECX			// ECX n degerini tutacak
		MOV CX, n				
		XOR ESI, ESI			// ESI i olarak kullanilacak i=0
		WW1 :					// Dis while dongusu basi
		CMP ESI, ECX			// i<n mi kontrolu
		JAE SAGSON				// degilse islem sonuna git
		XOR EDI, EDI			// EDI j olarak kullanilacak j=0
		MOV EBX, ECX			// EBX k olarak kullanilacak k = n
		DEC EBX					// EBX <- n -1
		WW2 :					// Ic while dongusu basi
		CMP EDI, EBX			// j<k mi kontrolu
		JAE WW2SON				// degilse ic while sonuna git

		MOV EAX, ESI			// EAX <- i
		XOR EDX, EDX			// EDX <- 0
		MOV DX, n				// DX <- n
		MUL EDX					// EAX <- i*n
		ADD EAX, EDI			// EAX <- i*n+j
		ADD EAX, EAX			// EAX <- EAX + EAX
		MOV ECX, EAX			// ECX <- EAX

		MOV EAX, ESI			// EAX <- i
		XOR EDX, EDX			// EDX <- 0
		MOV DX, n				// DX <- n
		MUL EDX					// EAX <- i*n
		ADD EAX, EBX			// EAX <- i*n+k
		ADD EAX, EAX			// EAX <- EAX + EAX
		MOV EDX, resim			// EDX <- &resim
		PUSH WORD PTR[EDX + ECX]	// *(resim+ i*n+j) stack e at
		PUSH WORD PTR[EDX + EAX]	// *(resim+i*n+k) stack e at
		POP WORD PTR[EDX + ECX]		// ters sirada stackten cekerek
		POP WORD PTR[EDX + EAX]		// swap yap
		XOR ECX, ECX				// donmeden once ECX i
		MOV CX, n					// eski haline getir
		INC EDI					// j++
		DEC EBX					// k--
		JMP WW2					// ic while dongusu
		WW2SON :				// ic while dongusu sonu
		INC ESI					// i++
		JMP WW1					// dis while dongusu
		SAGSON :				// dis while dongusu sonu
								// islem sonu

	}
}

void solaDondur(short n, int resim) {
	//KODUNUZU BURADAN BASLAYARAK YAZINIZ
	__asm {
		
		XOR ESI, ESI			// ESI i olarak kullanýlacak sifirlaniyor
		XOR ECX, ECX			// ECX n degerini tutacak sifirlanýyor
		MOV CX, n				// CX e n degeri aktariliyor
		L1 :
		CMP ESI, ECX			// i<n mi kontrolu
		JAE L1SON				// degilse transpoze sonuna git
		MOV EDI, ESI			// EDI j olacak j=i yapiliyor
		L2 :
		CMP EDI, ECX			// j<n mi kontrolu
		JAE L2SON				// degilse loop sonuna git

		MOV EAX, ESI			//EAX <- i
		XOR EDX, EDX			// EDX sifirlaniyor
		MOV DX, n				// EDX <- n
		MUL EDX					// EAX <- i*n
		ADD EAX, EDI			// EAX <- i*n+j
		ADD EAX, EAX			// EAX <- EAX + EAX
		MOV EBX, EAX			// EBX <- EAX

		XOR EAX, EAX			// EAX <- 0
		MOV EAX, EDI			// EAX <- j
		XOR EDX, EDX			// EDX <- 0 carpma icin
		MOV DX, n				// EDX <- n
		MUL EDX					// EAX <- j*n
		ADD EAX, ESI			// EAX <- j*n+i
		ADD EAX, EAX			// EAX <- EAX + EAX

		MOV EDX, EBX			// EDX <- i*n+j

		MOV EBX, resim			// EBX <- &resim
		ADD EBX, EDX			// EBX <- EBX + i*n+j
		XOR ECX, ECX			// ECX temp register olarak kullanýlacak
		MOV CX, WORD PTR[EBX]	// CX <- *(resim+i*n+j)
		PUSH ECX				// Stack e at

		MOV EBX, resim			// EBX <- &resim
		ADD EBX, EAX			// EBX <- EBX + j*n+i
		XOR ECX, ECX			// ECX temp register olarak kullanýlacak
		MOV CX, WORD PTR[EBX]	// CX <- *(resim+j*n+i)
		PUSH ECX				// Stack e at

		MOV EBX, resim			// EBX <- &resim
		ADD EBX, EDX			// EBX <- EBX + i*n+j
		POP ECX					// Stackteki degeri ECX e al
		MOV WORD PTR[EBX], CX	// *(resim+i*n+j) ye *(resim+j*n+i) nin degeri
								// aktarildi

		MOV EBX, resim			// EBX <- &resim
		ADD EBX, EAX			// EBX <- EBX + j*n+i
		POP ECX					// Stackteki degeri ECX e al
		MOV WORD PTR[EBX], CX	// *(resim+j*n+i) ye *(resim+i*n+j) nin eski degeri 
								// aktarildi

		XOR ECX, ECX			// Donmeden once ECX i 
		MOV CX, n				// eski haline getirir

		INC EDI					// j++
		JMP L2					// ic while dongusu
		L2SON :					// ic while dongusu sonu
		INC ESI					// i++
		JMP L1					// dis while dongusu
		L1SON :					// dis while dongusu sonu
								// transpoze islemi bitti


		XOR ECX, ECX			// ECX n degerini tutacak
		MOV CX, n
		XOR ESI, ESI			// ESI i olarak kullanilacak i=0
		W1 :					// Dis while dongusu baslangic
		CMP ESI, ECX			// i<n mi kontrolu
		JAE SOLSON				// degilse islem sonuna git
		XOR EDI, EDI			// EDI j olarak kullanilacak j=0
		MOV EBX, ECX			// EBX k olarak kullanilacak k = n
		DEC EBX					// EBX <- n -1
		W2 :					// Ic while dongusu basi
		CMP EDI, EBX			// j<k mi kontrolu
		JAE W2SON				// degilse ic while sonuna git

		MOV EAX, EDI			// EAX <- j
		XOR EDX, EDX			// EDX <- 0
		MOV DX, n				// DX <- n
		MUL EDX					// EAX <- j*n
		ADD EAX, ESI			// EAX <- j*n+i
		ADD EAX, EAX			// EAX <- EAX + EAX
		MOV ECX, EAX			// ECX <- EAX

		MOV EAX, EBX			// EAX <- k
		XOR EDX, EDX			// EDX <- 0
		MOV DX, n				// DX <- n
		MUL EDX					// EAX <- k*n
		ADD EAX, ESI			// EAX <- k*n+i
		ADD EAX, EAX			// EAX <- EAX+EAX
		MOV EDX, resim			// EDX <- &resim
		PUSH WORD PTR[EDX + ECX]	//*(resim+j*n+i) stack e at
		PUSH WORD PTR[EDX + EAX]	// *(resim+k*n+i) stack e at
		POP WORD PTR[EDX + ECX]		// ters sirada stackten cekerek
		POP WORD PTR[EDX + EAX]		// swap yap
		XOR ECX, ECX				// donmeden once ECX i eski haline
		MOV CX, n					// geri al
		INC EDI						// j++
		DEC EBX						// k--
		JMP W2						// ic while dongusu
		W2SON :						// ic while dongusu sonu
		INC ESI						// i++
		JMP W1						// dis while dongusu
		SOLSON :					// dis while dongusu sonu



	}
	//KODUNUZU YAZMAYI BURADA BITIRINIZ
	
}
