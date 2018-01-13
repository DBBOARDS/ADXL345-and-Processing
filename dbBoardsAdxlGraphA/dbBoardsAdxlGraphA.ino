/*-----------------------------------------------------------------------------------------------------------
  dbBoardsAdxlGraphA.ino
  SPI ADXL345 Breakout

  Summary:
    This program reads the adxl345 sensor data for the x, y, and z axis and sends the values out over serial
    to be generated into a live graph in dbBoardsAdxlGraphP.pde
  
  Utilizing:
    Sparkfun's ADXL345 Library https://github.com/sparkfun/SparkFun_ADXL345_Arduino_Library
   
  Programmer:
    Duncan Brandt @ DB Boards, LLC
    Created: Jan 03, 2018
  
  Development Environment Specifics:
    Arduino 1.6.11
  
  Hardware Specifications:
    DB Boards SPI ADXL345, DB3000
    Arduino Drawing Board (UNO) DB1000

  Beerware License:
    This program is free, open source, and public domain. The program is distributed as is and is not
    guaranteed. However, if you like the code and find it useful I would happily take a beer should you 
    ever catch me at the local.
*///---------------------------------------------------------------------------------------------------------

#include <SparkFun_ADXL345.h>  // https://github.com/sparkfun/SparkFun_ADXL345_Arduino_Library
ADXL345 adxl = ADXL345(10);    // USE FOR SPI COMMUNICATION, ADXL345(chipSelectPin);
int x,y,z;                     // Variable used to store accelerometer data

void setup(){                  // The setup Program runs one time at power up or after reset
  Serial.begin(9600);          // Start the serial terminal with a baudRate of 9600
  adxl.powerOn();              // Power on the ADXL345

  adxl.setRangeSetting(4);     // Range settings 2g(highest sensetivity), 4g, 8g or 16g(lowest sensetivity)
  adxl.setSpiBit(0);           // Configure the device to be in 4 wire SPI mode
}
void loop(){                   // The loop program follows the setup program and repeats forever
  adxl.readAccel(&x, &y, &z);  // Read the accelerometer values and store them in x, y, and z
  sendAccelToProcessing();     // Send the x, y, and z values to the dbBoardsAdxlGraphP.pde to be displayed
  delay(30);                   // Give the Processing program time to parse and graph the data
}

void sendAccelToProcessing(){  // Send the x, y, and z values to the dbBoardsAdxlGraphP.pde to be displayed
  Serial.print("x");           // Tell the Proccessing sketch it is about to recieve an x value
  Serial.print(x);             // Send the x value to dbBoardsAdxlGraphP.pde
  Serial.print("y");           // Tell the Proccessing sketch it is about to recieve an y value
  Serial.print(y);             // Send the y value to dbBoardsAdxlGraphP.pde
  Serial.print("z");           // Tell the Proccessing sketch it is about to recieve an z value
  Serial.print(z);             // Send the z value to dbBoardsAdxlGraphP.pde
}

