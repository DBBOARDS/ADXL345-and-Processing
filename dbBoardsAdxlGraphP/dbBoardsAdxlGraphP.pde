/*-------------------------------------------------------------------------------------------------------------------------------------
  dbBoardsAdxlGraphP.pde
    Use with dbBoardsAdxlGraphA.ino

  Summary:
    This program reads the adxl345 sensor data for the x, y, and z axis over serial from an Arduino and
    generates a live graph of the data for all three axis.

  Programmer:
    Duncan Brandt @ DB Boards, LLC
    Created: Jan 05, 2018
  
  Development Environment Specifics:
    Processing 3.3.6
  
  Hardware Specifications:
    DB Boards SPI ADXL345, DB3000
    Arduino Drawing Board (UNO) DB1000

  Beerware License:
    This program is free, open source, and public domain. The program is distributed as is and is not
    guaranteed. However, if you like the code and find it useful I would happily take a beer should you 
    ever catch me at the local.
*///-----------------------------------------------------------------------------------------------------------------------------------

import processing.serial.*;              // Start serial for logging the port options
Serial accel;                            // Call the serial instance accel
int xPixels = 550;                       // Our graph is 550 pixels wide
int[] x = new int[xPixels];              // This array will store each value of x along the x(time) axis
int[] y = new int[xPixels];              // This array will store each value of y along the x(time) axis
int[] z = new int[xPixels];              // This array will store each value of z along the x(time) axis
boolean X = false, Y = false, Z = false; // These variables note when the x, y, and z values have been recieved for the new set

void setup(){                            // The setup program runs one time and first after startup
  size(750, 750);                        // Create a screen for our graph that is 750 x 750 pixels
  textSize(30);                          // Make the text font 30 pixels tall
  textAlign(CENTER);                     // Use the x and y values in text("text",x,y) as the center point of the text
  strokeWeight(1);                       // Make all graph lines one pixel wide
  printArray(Serial.list());             // Print the List of Serial ports to identify the port needed
  accel = new Serial(this,Serial.list()[0],9600);        // Use the printed list to identify the correct array location (often [0])
  for(int i = 0; i < xPixels; i++){      // This for loop runs once for every x pixel on the graph
    x[i] = 0;                            // Before reading new values, set every x value at 0
    y[i] = 0;                            // Before reading new values, set every y value at 0
    z[i] = 0;                            // Before reading new values, set every z value at 0
  }
}
void draw(){                             // The draw program runs on a continuous loop after setup finishes
  background(255);                       // Cover the previous graphics with a white background
  fill(0);                               // Make the fill color black to draw the graph text
  stroke(0);                             // Make the stroke color black for the graph lines
  line(100,100,100,650);                 // Draw the verticle x(time) = 0 boundary line
  line(100,375,650,375);                 // Draw the Horizontal force=0 x axis
  text("DB Boards SPI ADXL Graph", 375, 70);              // Draw the title text above the graph
  text("1G", 50, 375 - 112);             // Draw text at 1G roughly 135 on the y axis
  text("0", 50, 380);                    // Draw text at 0G
  text("-1G", 50, 375 + 140);            // Draw text at -1G
  for(int a = 0; a < xPixels-1; a++){    // This for loop happens once less then xPixels so that it can use a+1 safely
    x[a] = x[a+1];                       // Shift the enitre x graph one pixel to the left to make room for the new x value
    y[a] = y[a+1];                       // Shift the enitre y graph one pixel to the left to make room for the new y value
    z[a] = z[a+1];                       // Shift the enitre z graph one pixel to the left to make room for the new z value
  }
  getAccelFromArduino();                 // Parse and Store the new x, y, and z values from dbBoardsAdxlGraphA.ino
  drawAccelGraph();                      // Draw the shifted graph with the new values
}

void getAccelFromArduino(){              // Parse and Store the new x, y, and z values from dbBoardsAdxlGraphA.ino
  boolean nextSet = false;               // This boolean is true when ther is a new x, y, and z value
  while(!nextSet){                       // Keep parsing data from the Arduino until there is a new x, y, and z
    if(accel.available() > 4){           // If there is enough available bytes to relay a negative 3 digit number proceed
      int inByte = accel.read();         // Gather the next byte from the Arduino
      if(inByte == 120 && !X) parseAccelValue("x");       // If the value is x, parse and store the next number as x if needed
      else if(inByte == 121 && !Y) parseAccelValue("y");  // If the value is y, parse and store the next number as y if needed
      else if(inByte == 122 && !Z) parseAccelValue("z");  // If the value is z, parse and store the next number as z if needed
      if(X && Y && Z){                   // If there is a new value for each axis, prep to update the graph
        X = false;                       // Reset the X boolean for the next set
        Y = false;                       // Reset the Y boolean for the next set
        Z = false;                       // Reset the Z boolean for the next set
        nextSet = true;                  // Escape the parsing loop to update the graph
      }
    }
    else delay(1);                       // Required delay for the graphics processer
  }
  nextSet = false;                       // Reset boolean for next set
}
void parseAccelValue(String axis){       // Read the bytes required for the next whole number
  int inByte = accel.read();             // Bring in the next byte from the Arduino
  int negative = 1;                      // This is used to parse a negative number
  if(inByte == 45){                      // If the byte = "-"
    negative = -1;                       // Change the multiplier to a negative one
    inByte = accel.read();               // Get the next byte
  }
  int a = inByte-48;                     // Convert from ASCII to decimal and save the digit
  inByte = accel.read();                 // Grab the next digit
  while(inByte > 47 && inByte < 58){     // Keep getting digits until the next variable comes
    a = a*10 + inByte - 48;              // Move the decimal and add the next digit
    inByte = accel.read();               // Grab the next byte to check again
  }
  if(a > -200 && a < 200){               // If the number is on the graph
    if(axis == "x"){                     // If the variable is x
      x[549] = a*negative;               // Record the new x value to the graph
      X = true;                          // Note that the X value has been recieved for this set
    }
    else if(axis == "y"){                // If the variable is y
      y[549] = a*negative;               // Record the new y value to the graph
      Y = true;                          // Note that the Y value has been recieved for this set
    }
    else if(axis == "z"){                // If the variable is z
      z[549] = a*negative;               // Record the new z value to the graph
      Z = true;                          // Note that the Z value has been recieved for this set
    }
  }
}
void drawAccelGraph(){                   // Use updated data to redraw the graph
  for(int b = 0; b < xPixels-1; b++){    // Loop through every x value on the graph
    stroke(255,0,0);                     // Make the x line red
    line(100+b,375-x[b],100+b+1,375-x[b+1]);              // Draw the x line   
    stroke(0,255,0);                     // Make the y line green
    line(100+b,375-y[b],100+b+1,375-y[b+1]);              // Draw the y line
    stroke(0,0,255);                     // Make the z line blue
    line(100+b,375-z[b],100+b+1,375-z[b+1]);              // Draw the z line
  }
  fill(255,0,0);                         // Make the text color red
  text("X",670, 375-x[549]+10);          // Draw an X at the new value for x
  fill(0,255,0);                         // Make the text color green
  text("Y",670, 375-y[549]+10);          // Draw a Y at the new value for y
  fill(0,0,255);                         // Make the text color blue
  text("Z",670, 375-z[549]+10);          // Draw a Z at the new value for z
}
