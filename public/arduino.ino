#include <SPI.h>
#include <Ethernet.h>

byte mac[] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}; // Set the MAC address of this Arduino.
byte server[] = {255,255,255,255}; // ip address of destination server.
IPAddress ip(255,255,255,255); // ip address for this Arduino.

const int interval = 1000;
int counter = 0;
int startTime = 0;
int timeElapsed = 0;
const int readingsLength = 30;
int readings[readingsLength]; // = {130,38,428,18,240,4,64,135,231,199,...};

EthernetClient client;

void setup(){
  Ethernet.begin(mac);
  Serial.begin(9600);
  startTime = millis();
}

void loop()
{
  timeElapsed = millis() - startTime;
  if(timeElapsed >= interval){
    readings[counter] = analogRead(A1);
    Serial.println(readings[counter]);
    startTime = millis();
    timeElapsed = 0;
    
    counter++;
  }
  
  
  if(counter == readingsLength ){
    counter = 0;
      String dataString = "noise=";
  for(int i = 0; i< readingsLength; i++){
      dataString += String(readings[i]);
      dataString += ",";
  }
  
  if(client.connect(server, 80)){
    client.println("POST /jroom/ HTTP/1.1");
    client.println("HOST: HOSTNAME");
    client.print("Content-Length: ");
    client.println(dataString.length(), DEC);
    client.print("Content-Type: application/x-www-form-urlencoded\n");
    client.println("Connection: close\n");
    client.println(dataString);
    client.println();
    client.stop();
  }
  }
}