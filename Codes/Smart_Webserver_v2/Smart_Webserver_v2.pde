#include <SPI.h>
#include <Ethernet.h>
#include <MsTimer2.h>

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,0, 195 };
byte gateway[] = { 192, 168, 0, 1 }; //ip address of the gatewa or router
byte subnet[] = { 255, 255, 255, 0 }; //ip address of the gatewa or router

Server server(80);                                      //server port
int ledPin = 4;  // LED pin
String readString = String(30); //string for fetching data from address

boolean LEDON = false; //LED status flag

void setup(){
//start Ethernet
  Ethernet.begin(mac, ip, gateway, subnet);
//Set pin 4 to output
  pinMode(ledPin, OUTPUT);  
//enable serial datada print  
  Serial.begin(9600);
  Serial.println("Server Start!");
}
void loop(){
// Create a client connection
Client client = server.available();
  if (client) {
    while (client.connected()) {
   if (client.available()) {
    char c = client.read();
     //read char by char HTTP request
    if (readString.length() < 100) 
      {
        //store characters to string 
        readString += c; //replaces readString.append(c);
      }  
        //output chars to serial port
        Serial.print(c);
        //if HTTP request has ended
        if (c == '\n') {
          //dirty skip of "GET /favicon.ico HTTP/1.1"
          if (readString.indexOf("?") <0)
          {
            //skip everything
          }
          //else
                      
          String hours,minutes,seconds,doneness ="";
          char h[2],m[2],s[2],d[1];
          if(readString.indexOf("hour")>0)
          {
            int hour_index = readString.indexOf("hour=");//search the start index of hour GET /?hour=01&min=01&sec=01 HTTP/1.1
            //Serial.println("start hour index : " + String(hour_index));
            hours = readString.substring(hour_index +5, hour_index+7);
            Serial.println("hour is : " + hours);
          }          
          if(readString.indexOf("min")>0) 
          { 
            int min_index = readString.indexOf("min=");
            //Serial.println("start min index : " + String(min_index));
            minutes = readString.substring(min_index +4, min_index+6);
            Serial.println("min is : " + minutes);
          }          
          if(readString.indexOf("sec")>0 )
          {
            int sec_index = readString.indexOf("sec=");
            //Serial.println("start sec index : " + String(sec_index));
            seconds = readString.substring(sec_index +4, sec_index+6);
            Serial.println("seconds is : " + seconds);            
          }   
          
          if(readString.indexOf("done")>0)
          {
            int done_index = readString.indexOf("done=");
            doneness = readString.substring( done_index+5, done_index+6);
            //done_index = doneness.indexOf("+");
            //doneness = doneness.substring(0,done_index);
            Serial.println("doneness is : " + doneness);            
          }
          
          if(hours !="" && minutes !="" && seconds !="" && doneness != "")
          {
            h[0] = hours.charAt(0);h[1] = hours.charAt(1);            
            m[0] = minutes.charAt(0); m[1] = minutes.charAt(1);
            s[0] = seconds.charAt(0);s[1] = seconds.charAt(1);
            d[0] = doneness.charAt(0);

            
            //hours.toCharArray(h,2); 
            //minutes.toCharArray(m,2);
            //seconds.toCharArray(s,2); 
            //doneness.toCharArray(d,6);
            
            //Serial.println("Hour : "+ String(h[0]));
            //Serial.println("Hour : "+ String(h[1]));
            //Serial.println("Min : "+ String(m[0]));
            //Serial.println("Min : "+ String(m[1]));
            Serial.println("sec : "+ String(s[0]));
            Serial.println("sec : "+ String(s[1]));
            Serial.println("doneness : "+ String(d[0]));
            
            
          }
  
        
           
          // output HTML data starting with standard header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println();
          
          client.println("<body bgcolor=\"#D8CEF6\">");
          //send first heading
          client.println("<font color='blue'><h1>Smart Toaster</font></h1>");
          client.println("<hr />");
          client.println("<hr />");
          //output some sample data to browser
         
          //drawing simple table
          client.println("<font color='red'><h2>Select time for toasting:</font></h2> ");
          client.println("<br />");
          client.println("<table border=3 width=\"80%\" height=\"40%\">");
          client.println("<form name='time' method=get>");
          client.println("<tr><td>Hours</td><td>minutes</td><td>seconds</td><td>doneness</td></tr>");
          client.println("<tr><td><select name=hour id=\"hour\"><option value=\"01\">01</option><option value=\"02\">02</option><option value=\"03\">03</option></select></td>");
          client.println("<td><select name=min id=\"min\"><option value=\"01\">01</option><option value=\"02\">02</option><option value=\"03\">03</option><option value=\"04\">04</option>");
          client.println("<option value=\"05\">05</option></select></td>");
          client.println("<td><select name=sec id=\"sec\"><option value=\"10\">10</option><option value=\"20\">20</option>");
          client.println("<option value=\"30\">30</option><option value=\"40\">40</option><option value=\"50\">50</option></select></td>");
          client.println("<td><select name=done ><option value=\"L\">light </option><option value=\"M\">medium</option><option value=\"D\">dark  </option></select></td>");
          client.println("</tr><tr><td/><td/><td/><td align='center'><input type=submit style=\"height: 50px; width: 70px\" value=start></td></tr>");
          client.println("</form></table>");
          client.println("<br />");          
          client.println("<hr />");
          client.println("<hr />");
          client.println("</body></html>");
          //clearing string for next read
          readString="";
          //stopping client
          client.stop();
            }
          }
        }
      }
 }     






