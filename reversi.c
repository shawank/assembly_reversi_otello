#include<stdio.h>
#include<stdbool.h>

int board[8][8];
bool chanceBlack = true;
bool gameOver = false;
bool blackCanMove = true;
bool whiteCanMove = true;
void printBoard(){

	///////////////////////////////////
	printf("  ");
	for (int i = 0; i < 8; i++)
	{
		printf(" %d ",i);
	}
	printf("\n");
	//////////////////////////////////
	for (int i = 0; i < 8; i++)
	{	printf("%d ",i);
		for (int j = 0; j < 8; j++)
		{	
			if(board[i][j]==0)
				printf(" _ ");
			else if(board[i][j]==1)
				printf(" %d ",1);
			else
				printf(" %d ",2);
		}
		printf("\n");
	}
	printf("\n");
}
bool checkValidity(int rowNumber,int columnNumber){
	if (rowNumber>7||columnNumber>7||rowNumber<0||columnNumber<0)
		return false;

	int player = 1;
	int opponent = 2;
	if(!chanceBlack){
		player = 2;
		opponent = 1;
	}
	bool flag = false;
	int a_inc[] = {-1, 1, 0, 0, -1, 1, 1, -1};
	int b_inc[] = {0, 0, -1, 1, -1, 1, -1, 1};
	int a; int b;
	for (int i = 0; i < 8; i++)
	{
		flag = false;
		a = rowNumber;
		b = columnNumber;
		while ((a > 0 || a_inc[i] != -1) && (a < 7 || a_inc[i] != 1) && (b > 0 || b_inc[i] != -1) && (b < 7 || b_inc[i] != 1)  && board[a + a_inc[i]][b + b_inc[i]] == opponent)
		{
			a = a + a_inc[i];
			b = b + b_inc[i];
			flag = true;
		}
		if (flag && (a > 0 || a_inc[i] != -1) && (a < 7 || a_inc[i] != 1) && (b > 0 || b_inc[i] != -1) && (b < 7 || b_inc[i] != 1) && (board[a + a_inc[i]][b + b_inc[i]] == player) && (board[a + a_inc[i]][b + b_inc[i]] == player))
		{
			return true;
		}
	}
	return false;
}

void move(int rowNumber, int columnNumber){
	int player = 1;
	int opponent = 2;

	if(!chanceBlack){
		player = 2;
		opponent = 1;
	}
	int a_inc[] = {-1, 1, 0, 0, -1, 1, 1, -1};
	int b_inc[] = {0, 0, -1, 1, -1, 1, -1, 1};
	int a; int b;
	for (int i = 0; i < 8; i++)
	{
		a = rowNumber;
		b = columnNumber;
		while ((a > 0 || a_inc[i] != -1) && (a < 7 || a_inc[i] != 1) && (b > 0 || b_inc[i] != -1) && (b < 7 || b_inc[i] != 1)  && board[a + a_inc[i]][b + b_inc[i]] == opponent)
		{
			a = a + a_inc[i];
			b = b + b_inc[i];
		}
		// if ((a != 0 || a_inc[i] != -1) && (a != 7 || a_inc[i] != 1) && (b != 0 || b_inc[i] != -1) && (b != 7 || b_inc[i] != 1) && (board[a + a_inc[i]][b + b_inc[i]] == player))
		if ( (a > 0 || a_inc[i] != -1) && (a < 7 || a_inc[i] != 1) && (b > 0 || b_inc[i] != -1) && (b < 7 || b_inc[i] != 1) && (board[a + a_inc[i]][b + b_inc[i]] == player))
		{
			while (a != rowNumber || b != columnNumber)
			{
				board[a][b] = player;
				a = a - a_inc[i];
				b = b - b_inc[i];
			}
		}
	}
	board[rowNumber][columnNumber]=player;
	return;
}
bool canBlackMove(){
	bool temp = chanceBlack;
	chanceBlack = true;
	for (int i = 0; i < 8; i++){
		for (int j = 0; j < 8; j++){
			if(checkValidity(i,j)==true){
				chanceBlack = temp;
				return true;
			}
		}
	}
	chanceBlack = temp;
	return false;
}
bool canWhiteMove(){
	bool temp = chanceBlack;
	chanceBlack = false;
	for (int i = 0; i < 8; i++){
		for (int j = 0; j < 8; j++){
			if(checkValidity(i,j)==true){
				chanceBlack = temp;
				return true;
			}
		}
	}
	chanceBlack = temp;
	return false;
}

void whoWon(){
	int count[3];
	for (int i = 0; i < 8; i++)
	{
		for (int j = 0; j < 8; j++)
		{
			count[board[i][j]] += 1;
		}
	}
	if ( count[1] > count[2])
		printf("Black won");
	else if (count[1] == count[2])
		printf("It's a draw");
	else
		printf("white won");
	return;
}

void initialize(){
	board[3][3]=1;
	board[3][4]=2;
	board[4][3]=2;
	board[4][4]=1;
}
int main(void){
	int rowNumber = 0;
	int columnNumber = 0;
	bool wasValid = false;
	initialize();
	printBoard();
	while(!gameOver){
		//this code check if one of the players can move otherwise gets out of loop
		blackCanMove = canBlackMove();
		whiteCanMove = canWhiteMove();
		if(!blackCanMove&&!whiteCanMove)        {gameOver = true;break;}
		if(chanceBlack&&blackCanMove) 			
			printf("1's chance\n");
		else printf("2's chance\n");
		if(chanceBlack&&blackCanMove){
			do{
				scanf("%d%d",&rowNumber,&columnNumber);
				wasValid = checkValidity(rowNumber,columnNumber);
			}
			while(!wasValid);
			move(rowNumber,columnNumber);
			printBoard();
		}
		else if(!chanceBlack&&whiteCanMove){
			do{
				scanf("%d%d",&rowNumber,&columnNumber);
				wasValid = checkValidity(rowNumber,columnNumber);
			}
			while(!wasValid);
			move(rowNumber,columnNumber);
			printBoard();
		}
		if(chanceBlack) chanceBlack = false;
		else chanceBlack = true;
	}
	printBoard();
	whoWon();
}
