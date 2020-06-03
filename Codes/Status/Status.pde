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
String hour = 02, minute=34, second = 45;

void setup(){
//start Ethernet
  Ethernet.begin(mac, ip, gateway, subnet);
//Set pin 4 to output
  pinMode(ledPin, OUTPUT);  
//enable serial datada print  
  Serial.begin(9600);
  Serial.println("Status Response!");
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
          // output HTML data starting with standard header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println();
          
          client.println("<body bgcolor=\"#D8CEF6\">");
          //send first heading
          client.println("<font color='blue'><h1>Status Check</font></h1>");
          client.println("<hr />");
          client.println("<hr />");
          //output some sample data to browser
         
          //drawing simple table
          client.println("<font color='red'><h2>Remaining Time :</font></h2> ");
          client.println("<br />");
          client.println("<table border=3 width=\"80%\" height=\"40%\">");

          client.println("<tr><td><h3 align=\"center\">Hours</h3</td><td><h3 align=\"center\">minutes</h3></td><td><h3 align=\"center\">seconds</h3></td></tr>");
          client.println("<tr><td>");
          client.println("<p style=\"font-size:18pt\" align=\"center\">");
          client.print(hour);
          client.print("</p>");
          client.println("</td>");
          client.println("<td>");
          client.print(minute);
          client.println("</td>");
          client.println("<td>");
          client.print(second);
          client.println("</td></tr>");
          client.println("</table>");
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






