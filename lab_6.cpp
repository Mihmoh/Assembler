#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#define SIZE 10
float arr[SIZE];
float resultArrFPU[SIZE];
#pragma inline

void inputArray() {
	printf("input array:\n");
	for (int i = 0; i < SIZE; i++)
	{
		printf("arr[%d] = ", i);
		while (!scanf("%f", &arr[i]))
			rewind(stdin);
		rewind(stdin);
	}
}

void asmAlgorithm() {

	_asm {
		finit	;инициализировать FPU
		mov ecx, 10
		xor esi, esi

		metka :
		fld arr[esi]; загрузить вещественное в стек
			fsin; синус st[0]
			fstp resultArrFPU[esi]; считать вещественное из стека
			add esi, 4
			loop metka
			fwait; ожидание готовности сопроцессора
	}
}

void outputArray() {
	printf("Result array of FPU algorithm:\n");
	for (int i = 0; i < SIZE; ++i) {
		printf("%.3f \n", resultArrFPU[i]);
	}
}


int main()
{
	inputArray();
	asmAlgorithm();
	outputArray();
	printf("Enter 0 to finish\n");
	scanf("%f", &arr[0]);
	return 0;
}
