# I am a function
In this little game you use an ultrasonic distance sensor (connected to an Arduino) to draw a given graph of a mathematical function on the screen. Move back and forth to let the Nyancat follow the path of the graph on the screen. Proceed to the next level if your score is larger than 80%.

![Screenshot](https://raw.githubusercontent.com/ralphcrutzen/I-am-a-function/master/screenshot.png)

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

## Be warned...
This is just meant to be a playful thingy, so don't expect too much... The code is not very clean, the game is only tested on a screen resulution of 1920x1080 and there are still lots of things missing, like a decent score system, highscores, sounds, localization, multiplayer, DLC and lootboxes :-)
