# I am a function
In this little game you use an ultrasonic distance sensor (connected to an Arduino) to draw a given graph of a function on the screen. Move back and forth to let the Nyancat follow the path of the graph on the screen.

## Hardware required
An ultrasonic distance sensor (I use a HC-SR04) connected to an Arduino.
* Vcc to 5V
* Gnd to Gnd
* Trig to pin 8
* Echo to pin 9

Upload funktion.ino to the Arduino board.

## Software required
Download Processing from https://processing.org/.

Put the image file in the same directory as the function.pde sketch.

You may have to change the index of the Serial.list()[] array on line 56...
