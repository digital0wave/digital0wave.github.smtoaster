#include <SPI.h>
#include <Ethernet.h>
#include"Smart.h"

#include <SoftwareSerial.h>

#define FALSE 0
#define TRUE  1

//DEFINES FOR TOAST VALUES

#define lRl 0x40
#define lRh 0x42
#define mRl 0x36
#define mRh 0x47
#define dRl 0x32
#define dRh 0x39
#define lGl 0x30
#define lGh 0x37
#define mGl 0x30
#define mGh 0x37
#define dGl 0x30
#define dGh 0x36
#define lBl 0x48
#define lBh 0x51
#define mBl 0x46
#define mBh 0x54
#define dBl 0x46
#define dBh 0x53

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,0, 195 };
byte gateway[] = { 192, 168, 0, 1 }; //ip address of the gatewa or router
byte subnet[] = { 255, 255, 255, 0 }; //ip address of the gatewa or router

Server server(80);                                      //server port

//String readString = String(50); //string for fetching data from address
#define STRING_BUFFER_SIZE 40
char buffer[STRING_BUFFER_SIZE];
char flag = false;

Smart toaster;

unsigned char carr[3];

boolean getColour(char *rgb);
void colour_init(void);
boolean testToast(char level, char r, char g, char b);

SoftwareSerial Color90(2, 3);

void setup(){
//start Ethernet
  Ethernet.begin(mac, ip, gateway, subnet);

//enable serial datada print  
  Serial.begin(4800);
  Serial.println("Server Start!");
  toaster =  Smart::Smart();//call Timer
 
    
}
void loop(){
// Create a client connection
Client client = server.available();
  if (client) {
    int bufindex = 0; // reset buffer
    char c;
    if (client.connected() && client.available()) {
        
        buffer[0] = client.read();        
        buffer[1] = client.read();
        //Serial.print(buffer[0]);
        //Serial.print(buffer[1]);
        bufindex = 2;
        // read the first line to determinate the request page
        while (buffer[bufindex-2] != '\r' && buffer[bufindex-1] != '\n') { // read full row and save it in buffer
          c = client.read();
          //Serial.print(c);
          if (bufindex<STRING_BUFFER_SIZE) buffer[bufindex] = c;
          bufindex++;
        }
        //Serial.println(buffer);
      
         // client.println("<table width=\"300\"></table>");
        client.println("HTTP/1.1 200 OK");
        client.println("Content-Type: text/html");
        client.println();
        client.println("<html><body bgcolor=\"#D8CEF6\">");    
        client.println("<a href=\"/setting\">Setting</a>&nbsp &nbsp<a href=\"/status\" target=\"_blank\">Status</a>");
        client.println();
        char * startSetting =  strstr(buffer, "/setting");
        char * startStatus =  strstr(buffer, "/status");        
        unsigned char index,i = 0;
       
          //char[] hours,mins,secs,doneness=;//add space for null terminator
           if(startSetting)
            {   
                             
               String hours ="";
               String mins ="";
               String secs ="";
               String doneness ="";//add space for null terminator
              
              //searching hours
              startSetting = strstr(buffer, "hr");
              index =0;//rese
              if(startSetting)
              {
                index = index+3;//reset initial point for searching hour
               
                for(i=0;i< 2; i++)
                {
                  hours += startSetting[index++];                  
                }
                //Serial.print("hours : "); Serial.println(hours);
              }
              //searching minutes
              //GET /setting?hr=00&m=01&sc=10&d=L HTTP/1P

              startSetting = strstr(buffer, "m");
              index = 0;//reset index
              if(startSetting)
              {
                index = index +2;//reset initial point for searching min
                for(i=0; i<2; i++)
                {
                  mins += startSetting[index++];  
                            
                }
                //Serial.print("mins : "); Serial.println(mins);
                
              }
              
              //searching seconds
              //GET /setting?h=01&m=01&sc=10&d=L HTTP/1.1
              startSetting = strstr(buffer, "sc");
              index = 0;//reset index
              if(startSetting)
              {
                index = index +3;//reset initial point for searching sec
                for(i=0; i<2; i++)
                {
                  secs += startSetting[index++];                  
                }
                Serial.print("secs : "); Serial.println(secs);
                
              }
              
               //searching doneness
              //GET /setting?hour=01&min=01&sec=10&d=L HTTP/1.1
              startSetting = strstr(buffer, "d");
              index = 0;//reset index
              if(startSetting)
              {
                index = index +2;//reset initial point for searching doneness
                 for(i=0; i<1; i++)
                {
                  doneness +=startSetting[index++];    
                   Serial.print("doneness : "); Serial.println(doneness.charAt(0));         
                }
                //Serial.print("doneness : "); Serial.println(doneness);
              }
              //call timer to start toasting
             
               if(hours != "")
               {
                    

                    toaster.StringSetupAlarm( hours, mins, secs );
                    while(toaster.CHECKDONE())
                    {
                      if(toaster.OLD_NEW_SEC())
                      {
                       //oaster.PRINTTIME(); //
                      }
                      
                    } //end while
                    Serial.println("Start Toaster!!!!!!!!!!");
                    STEPMOT(1);//init motor
                    //Serial.println("Start Motor!!!!!!!!!!");
                    colour_init(); //start colour sensor
                    while(flag == 0){
                      do{                             
                            flag = getColour(carr);   
                        }while(flag == 0);
                       flag = testToast(doneness.charAt(0),carr[0], carr[1], carr[2]);
                       Serial.print("R :");Serial.print(carr[0], HEX); Serial.print(" G :");Serial.print(carr[1], HEX); Serial.print(" B :");Serial.println(carr[2], HEX);
                    }//end while
                    //toast is ready
                    flag = 0;
                    STEPMOT(0);
                        
             }//end while 
             hours,mins,secs,doneness= "";       
             memset(buffer, 0, 40);//clear buffer

             //clearing string for next read
            //send first heading
            client.println("<h1>Smart Toaster</h1>");
            client.println("<hr />");
            
            //output some sample data to browser
           
            //drawing simple table
            client.println("<h2>Select time for toasting:</h2>");
            client.println("<br />");
            client.println("<table border=3 width=\"80%\" height=\"40%\">");
            client.println("<form name='time' method=get>");
            client.println("<tr><td>Hours</td><td>Minutes</td><td>Seconds</td><td>Doneness</td></tr>");
            client.println("<tr><td><select name=hr ><option value=\"00\">00</option><option value=\"02\">02</option><option value=\"03\">03</option></select></td>");
            client.println("<td><select name=m><option value=\"00\">00</option><option value=\"01\">01</option><option value=\"02\">02</option><option value=\"03\">03</option>");
            client.println("<option value=\"05\">05</option></select></td>");
            client.println("<td><select name=sc ><option value=\"10\">10</option><option value=\"20\">20</option>");
            client.println("<option value=\"30\">30</option><option value=\"40\">40</option><option value=\"50\">50</option></select></td>");
            client.println("<td><select name=d ><option value=\"L\">light</option><option value=\"M\">medium</option><option value=\"D\">dark </option></select></td>");
            client.println("</tr><tr><td/><td/><td/><td align='center'><input type=submit  value=start></td></tr>");
            client.println("</form></table>");
            client.println("<br />");          
            client.println("<hr />");           
            client.println("</body></html>");
            //clearing string for next read
            
          }
       

           bufindex = 0;//for next 
      
          }
          
        //delay for client to receive
        delay(1);
        client.stop();
    }
 

}//end loop
          
boolean getColour(unsigned char *rgb)
{
  
  unsigned char rByte[9];   //data recieved
  boolean rr;               //flag for correct data
   
  Color90.begin(4800);      //start software serial connection
  Color90.print("= (00 $ m) !"); //read color data (send m command)
  pinMode(3,INPUT);    //recieve color data from colorpal
  
  //read color data from colorPAL
  
  rByte[0] = Color90.read();   //check if data coming in is color info or not
  if( rByte[0] == '$' ) {
    
    //get 9 bytes, 3 for each colour (RGB)
    for(int i=0; i<9; i++) {
      rByte[i] = Color90.read();
      //store 9 bytes in temp array        
    }
   	
        rr = TRUE;  //signal that color data was obtained with call to getColour
        
        
        //transfer to new rgb array	
	// DISPLAY RGB VALUES OBTAINED
	rgb[0] = (rByte[1] * 16)+ (rByte[2] - 0x30); //RED IN RED BYTE
	rgb[1] = (rByte[4] * 16)+ (rByte[5] - 0x30); //GRN IN GRN BYTE
	rgb[2] = (rByte[7] * 16)+ (rByte[8] - 0x30); //BLU IN BLU BYTE
		
  }
  else
    {     
      rr = FALSE;  //getColour did not receive any color data
    }
  
  
  return rr;  //return flag for if colour data was collected
  
}//getcolor



////////////////////////////////////////
//    colour_init()
//
//    initiation sequence to enable 
//    the colorpal color sensor to
//    read and output colour
///////////////////////////////////////
void colour_init(void)
{  
  Color90.begin(4800);

  //follow sequence for startup as shown in datasheet for colorPAL
  pinMode(2,INPUT);
  pinMode(3,INPUT);
  digitalWrite(2,HIGH); // Enable the pull-up resistor
  digitalWrite(3,HIGH); // Enable the pull-up resistor

  pinMode(2,OUTPUT);
  pinMode(3,OUTPUT);
  digitalWrite(2,LOW);
  digitalWrite(3,LOW);
  
  pinMode(2,INPUT);
  pinMode(3,INPUT);
  
 
  
  while( digitalRead(2) != HIGH || digitalRead(3) != HIGH ) {
    
    delay(50);
  }
  
  pinMode(2,OUTPUT);
  pinMode(3,OUTPUT);
  digitalWrite(2,LOW);
  digitalWrite(3,LOW);
  delay(80);
  
  pinMode(2,INPUT);
  pinMode(3,OUTPUT);
  delay(100);    
  
  
  
}//c_init


////////////////////////////////////////////////////
//      testToast()
//
//      FUNCTION FOR CHECKING IF TOAST IS READY
//
//      function takes rgb values from color sensor
//      and compares the values to defined ranges 
//      for three different toasting levels
//      (l, m, d) the toasting level to check for
//      is also input as a char. if the values are 
//      in range it indicated the toasting is done 
//      and will return TRUE. will return FALSE
//      if color data is not in range.
//
//      USE:
//   |-----------------------------------|
//   |   do{                             |
//   |      flag = getColour(carr);      |
//   |     }while(flag == 0);            |
//   |-----------------------------------|
//
//      to wait until colour data is collected (1 sample)
//
//
//
////////////////////////////////////////////////////
boolean testToast(char level, char r, char g, char b){

//have defines for lRl, lRh, mRl, mRh, dRl, dRh
//		   lGl, lGh, mGl, mGh, dGl, dGh
//		   lBl, lBh, mBl, mBh, dBl, dBh

//declare variables
	//ranges
	char rRl;
	char rRh;
	char rGl;
	char rGh;
	char rBl;
	char rBh;
	//flags
	char rgbflag = 0x00;
	boolean tdone = FALSE;
	

//check level input for toasted level to check for Light, Medium, Dark
switch(level){

		case 'l':
		case 'L':
			//set range to l
			rRl = lRl;
			rRh = lRh;
			rGl = lGl;
			rGh = lGh;
			rBl = lBl;
			rBh = lBh;
			break;
			
		case 'm':
		case 'M':
			//set range to m
			rRl = mRl;
			rRh = mRh;
			rGl = mGl;
			rGh = mGh;
			rBl = mBl;
			rBh = mBh;
                        
			break;
			
		case 'd':
		case 'D':
			//set range to dark
			rRl = dRl;
			rRh = dRh;
			rGl = dGl;
			rGh = dGh;
			rBl = dBl;
			rBh = dBh;
			break;
			
		default:
			break;
		}//end switch
			
//check each colour (rgb) if in range
//check REDs

if(r >= rRl && r <= rRh){
	rgbflag += 0x01;   //red in range
Serial.println("r+ ");
}


//check GRNs

if(g >= rGl && r <= rGh){
  Serial.println("g+ ");
	rgbflag +=  0x02; //grn in range
}


//check BLUs

if(b >= rBl && r <= rBh){
  Serial.println("b+ ");
	rgbflag += 0x04;   //blu in range
}


//if all three colours (or just two?) are in range than output TRUE

if(rgbflag == 0x07)
{
//RETURN TRUE

tdone = TRUE;
}


return tdone;

}//tt
