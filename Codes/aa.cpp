#include <hidef.h>      /* common defines and macros */
#include <mc9s12dg128.h>     /* derivative information */
#include <stdio.h>
#pragma LINK_INFO DERIVATIVE "mc9s12dg128b"



void init_port(void);
void delay (long int count);
void init_timer7();
void interrupt 15 T7_handler(void);

void  init_SCI(unsigned int baud);
char _1_to_U(char cInput);
void printMsg(char *ptrMsg);
void display_crt(char *ptrMsg);
char my_getch(void);
void my_putch(char cWrite);
char my_kbhit(void);

unsigned char step[8][5]={0x01, 0x09,0x03, 0x08,0x02
					,0x03 ,0x01, 0x02,0x01,0x02
					,0x02,0x03,0x06,0x01,0x04
					,0x06,0x02,0x04,0x02,0x04
					,0x04,0x06,0x0C,0x02,0x08
					,0x0C,0x04,0x08,0x04,0x08
					,0x08,0x0C,0x09,0x04,0x01
					,0x09,0x08,0x01,0x08,0x01};
					
unsigned char half,full,forward,back,hold,adv20,back20 = 0;
char sMsg[] = "SELECT OPTION \n\r S=Slow R=Fast F=Forward B=Backward D=Hold A=Advance 20 C=Go back 20 \n\r\n\r";
 
void main(void) {
  char cChoice;
  //char *pMsg;

  init_SCI(9600);	
  init_port();
  init_timer7();
  EnableInterrupts;
  
  
  printMsg(sMsg);

    
  while(1) {
    //if any keys are pressed
    if(my_kbhit() == 1) {
     cChoice = my_getch();
     delay(30);
     
     if(_1_to_U(cChoice) == 'S') //slow->half
     {
       half = 1; 
     }else if(_1_to_U(cChoice) == 'R')//Fast->full 
     {
       full =1; 
     }else if(_1_to_U(cChoice) == 'F')//forward     
     {
       forward = 1; 
     }else if(_1_to_U(cChoice) == 'B')//backward 
     {
       back = 1;
     }else if(_1_to_U(cChoice) == 'D')//hold
     {
       hold=1;
     }else ifif(_1_to_U(cChoice) == 'A')//advance 20 step 
     {
       adv20=1;
     }else if(_1_to_U(cChoice) == 'C')//go back 20 steps 
     {
       back20=1;
     }//end if else
     
    }//end if
  }//end while
 
  
  
}//end main


void delay (long int count) {
 while(count){
   count--;
  }
 }
   
   
void init_port(void)
{
	DDRA=0xff;//output
	 
	DDRB_BIT0=0;//input for half/full step
	DDRB_BIT1=0;//input for forward/backward	
	DDRB_BIT2=0;//input for hold
}

void init_timer7()
{
	TIOS_IOS7=1;
	TSCR1_TEN =1;
	TSCR1_TFFCA=1;
	//TFLG1_C7F=1;
	TSCR2 = 0X06;// DIVIDED BY 1->4US
	TC7 = TCNT+1000;
	TIE_C7I = 1;//T2 ON

}
 
/*
init_SCI
initialize SCI
PASSED VARS: unsigned int baud(baud rate)
RETURNED: void
*/
void init_SCI(unsigned int baud) {
  SCI0BD=(4000000/(long)(16*(long)baud));
  SCI0CR2_TE=1;
  SCI0CR2_RE=1;
}

/*
my_getch
read character from data register
PASSED VARS: void
RETURNED: void
*/
char my_getch(void) {
  char cRead;
  while(SCI0SR1_RDRF != 1) {}
  cRead = SCI0DRL; 

  return cRead;
}

/*
my_putch
write a character to data register
PASSED VARS: char cWrite
RETURNED: void
*/
void my_putch(char cWrite) {
	
	while(SCI0SR1_TDRE !=1) {}
	while(SCI0SR1_TC !=1) {}//check transmit complete
  SCI0DRL = cWrite;  
  
}

/*
my_kbhit
detect a key press
PASSED VARS: void
RETURNED: void
*/
char my_kbhit(void) {
  char cFlag = 0;
  while(SCI0SR1_RDRF !=1) {}
  cFlag =1; 
  
  return cFlag;
}


/*
*	change lower case to upper case
*	accept only alphabet
*/
char _1_to_U(char input)
{
	if(input>= 0x61 || input <=0x7a)//lower case
	{
		input -= 0x20;//make the upper case
	}
	return input;
}

/*
printMsg
print string
PASSED VARS: char *ptrMsg(pointer ptrMsg)
RETURNED: void
*/
void printMsg(char *ptrMsg)
{
	while(*ptrMsg != 0x00)
	{
		my_putch(*ptrMsg);
		ptrMsg++;
	}
}


void interrupt 15 T7_handler()
{
  
	static volatile unsigned char row=0;//initial start position 
	static volatile unsigned char col=0;//initial start position 
  static volatile unsigned char state = 0;//state
    	
	//unsigned char col,row=0;

	TC7 = TC7+1000;//reset
	PORTA=0;
	
	//BIT0 =0 HALF, BIT0=1 FULL
	//BIT1=0 BACKWARD, BIT1=1 FORWARD
	if(PORTB_BIT2 ==1) {
	  col = 0;
	  row = state;
	}else if((PORTB_BIT0== 0) && (PORTB_BIT1==0) && !PORTB_BIT2) {
	  col = 1;
	  row--;//half backward
	  
	}else if((PORTB_BIT0== 0) && (PORTB_BIT1==1) && !PORTB_BIT2) {
	  //half forward
	  col = 2;
	  row++;
	}else if((PORTB_BIT0== 1) && (PORTB_BIT1==0) && !PORTB_BIT2) {
	  //full backward	 
	  col =3;  
	  row -=2;
	}else if((PORTB_BIT0== 1) && (PORTB_BIT1==1) && !PORTB_BIT2) {
     //full forward
    row +=2;
    col = 4;
     
  }  
 
  row= row%8;
  PORTA=step[row][col];    
  state = row;
}


      