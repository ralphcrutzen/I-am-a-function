import processing.serial.*; 

PImage imgNyancat;

Serial myPort;
String inString;

// The y-location of the player is the average of the
// "nDist" most recent measured distances
int nDist = 100; // size of distance array
float distArray[] = new float[nDist];
float minDist = 25;
float maxDist = 150;

float timer; // used for countdown

int res = 800; // number of points horizontally
int nParts = 4;
float partWidth;
float partHeight;
float step; // xStep

float graph[] = new float[res];       // array of y-coords of function
float playerGraph[] = new float[res]; // array of y-coords of player
int i = 0; // current index playerGraph
float xPlayer = 0; //current position of player
float yPlayer = 0;

float score;
int level = 1;
int numLevels = 12;
String functionType [] = {
  "Constant", 
  "Lineair stijgend", 
  "Lineair dalend", 
  "Bergparabool", 
  "Dalparabool", 
  "Modulus", 
  "Wortel", 
  "Exponentieel", 
  "Logaritmisch", 
  "Sinus", 
  "Omgekeerd evenredig", 
  "Tangens"};

String state = "idle";

void setup() {
  //size(1080, 720);
  fullScreen();
  imgNyancat = loadImage("nyancat.png");
  imageMode(CENTER);
  textAlign(CENTER, CENTER);

  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 115200); 
  myPort.bufferUntil('\n');

  for (int i = 0; i < nDist; i++) {
    distArray[i] = 0;
  }

  partWidth = width/nParts;
  partHeight = height/nParts;
  step = (float)width / res;

  calcGraph();

  timer = millis();
}

void draw() {
  background(50);
  drawAxes();
  drawGraph();
  drawScore();
  drawState();
  updatePlayer();
  drawPlayer();
  drawCountdown();
}

void serialEvent(Serial myPort) {
  inString = myPort.readStringUntil('\n');

  if (inString != null) {
    inString = trim(inString);
    float distance = float(inString);

    // calculate average of most recent 100 distances
    float sum = 0;
    for (int i = 0; i < nDist - 1; i++) {
      distArray[i] = distArray[i + 1]; // move over every element
      sum += distArray[i];
    }
    distArray[nDist - 1] = distance; // add most recent distance
    sum += distance;
    float avg = sum/nDist;
    avg = constrain(avg, minDist, maxDist);
    yPlayer = map(avg, minDist, maxDist, height, 0);
  }
}

void keyPressed() {
  if (key == ' ') {
    if (state == "idle") {
      state = "countdown3";
      timer = millis();
    } else if (state == "playing" || state == "finished") {
      state = "idle";
      xPlayer = 0;
      calcGraph();
    }
  } else if (key == 'q' && level < numLevels) {
    level++;
    xPlayer = 0;
    calcGraph();
    state = "idle";
  } else if (key == 'a' && level > 1) {
    level--;
    xPlayer = 0;
    calcGraph();
    state = "idle";
  }
}

void drawCountdown () {
  if (state == "countdown3") {
    fill(0, 255, 0);
    textSize((float)width / 5);
    text("3", (float)width / 2, (float)height / 2);
    if (millis() - timer > 1000) {
      state = "countdown2";
      timer = millis();
    }
  } else
    if (state == "countdown2") {
      fill(0, 255, 0);
      textSize((float)width / 5);
      text("2", (float)width / 2, (float)height / 2);
      if (millis() - timer > 1000) {
        state = "countdown1";
        timer = millis();
      }
    } else
      if (state == "countdown1") {
        fill(0, 255, 0);
        textSize((float)width / 5);
        text("1", (float)width / 2, (float)height / 2);
        if (millis() - timer > 1000) {
          state = "playing";
          startPlaying();
        }
      }
}

void startPlaying() {
  i = 0;
  //score = -1;
  state = "playing";
}

void drawAxes() {
  strokeWeight(1);
  stroke(100);
  for (int i = 1; i < nParts; i += 1) {
    line(i*partWidth, 0, i*partWidth, height);
    line(0, i*partHeight, width, i*partHeight);
  }
  strokeWeight(10);
  line(0, height, width, height);
  line(0, height, 0, 0);
  textSize(50);
  fill(100);
  text("x", width - 50, height - 50);
  text("y", 25, 25);
}

void calcGraph() {
  int n = 0;
  switch (level) {
  case 1: // y = c
    float c = random(height/5, height*4/5);
    for (float x = 0; x < width; x += step) {
      float y = c;
      graph[n] = -y + height;
      n++;
    }
    break;
  case 2: // y = ax + b ; ascending
    float y1 = random(0, height/2);
    float y2 = random(height/2, height);
    float a = (y2 - y1) / (float)width;
    for (float x = 0; x < width; x += step) {
      float y = a*x + y1;
      graph[n] = -y + height;
      n++;
    }
    break;
  case 3: // y = ax + b ; descending
    y1 = random(height/2, height);
    y2 = random(0, height/2);
    a = (y2 - y1) / (float)width;
    for (float x = 0; x < width; x += step) {
      float y = a*x + y1;
      graph[n] = -y + height;
      n++;
    }
    break;      
  case 4: // y = ax^2 + bx + c; maximum at x = width/2
    c = random(0, height/2);
    a = -4*(random(height/2, height)-c) / (width * width);
    float b = -a*width;
    for (float x = 0; x < width; x += step) {
      float y = a*x*x + b*x + c;
      graph[n] = -y + height;
      n++;
    }      
    break;      
  case 5: // y = ax^2 + bx + c ; minimum at x = width/2
    c = random(0, height/2);
    a = -4*(random(c, height-c)) / (width * width);
    b = -a*width;
    for (float x = 0; x < width; x += step) {
      graph[n] = a*x*x + b*x + c;
      n++;
    }      
    break;
  case 6: // y = |ax + b| ; maximum at x = width/2
    b = -random(height/2, height);
    a = -b/(width/2);
    for (float x = 0; x < width; x += step) {
      float y = -abs(a*x + b) - b;
      graph[n] = -y + height;
      n++;
    }      
    break;      
  case 7: // y = sqrt(ax) + b
    y1 = random(height*3/4, height); 
    b = random(height/4);
    a = (b-y1)*(b-y1)/width;
    for (float x = 0; x < width; x += step) {
      float y = sqrt(a*x) + b;
      graph[n] = -y + height;
      n++;
    }      
    break;    
  case 8: // y = b * g^x
    b = random(height/10);
    y2 = height; //random(height*3/4, height);
    float g = pow(y2/b, 1/(float)width);
    for (float x = 0; x < width; x += step) {
      float y = b * pow(g, x);
      graph[n] = -y + height;
      n++;
    }      
    break;
  case 9: // y = a*log(x)
    y1 = random(height*3/4, height);
    a = y1/log(width);
    for (float x = 0; x < width; x += step) {
      float y = a*log(x);
      graph[n] = -y + height;
      n++;
    }      
    break;      
  case 10: // y = a*sin(bx) + c
    a = random(height/4, height/2);
    if (random(1) < 0.5) a = -a;
    b = TWO_PI / random(width/4, width/2);
    c = height / 2;
    for (float x = 0; x < width; x += step) {
      float y = a*sin(b*x) + c;
      graph[n] = -y + height;
      n++;
    }      
    break;
  case 11: // y = a/x
    float x1 = random(width/2);
    y1 = random(height/2);
    a = x1 * y1;
    for (float x = 0; x < width; x += step) {
      float y = a/x;
      graph[n] = -y + height;
      n++;
    }      
    break;
  case 12: // y = a * tan(b*x) + c
    a = random(height/4, height/2);
    if (random(1) < 0.5) a = -a;
    b = TWO_PI / random(width/2, width);
    c = height / 2;
    for (float x = 0; x < width; x += step) {
      float y = a * tan(b*x) + c;
      graph[n] = -y + height;
      n++;
    }      
    break;
  }
}

void drawGraph() {
  strokeWeight(5);
  stroke(200);
  float xPrev = 0;
  float yPrev = graph[0];
  int n = 1;
  for (float x = step; x < width; x += step) {
    if (n < res) {
      if (abs(yPrev - graph[n]) < height) {
        line(xPrev, yPrev, x, graph[n]);
      }
      xPrev = x;
      yPrev = graph[n];
      n++;
    }
  }
}

void updatePlayer() {
  if (state == "playing") {
    xPlayer += step;
    if (i < res) playerGraph[i] = yPlayer;
    i++;
    if (xPlayer > width - step) {
      xPlayer = 0;
      state = "finished";
      calcScore();
    }
  }
}

void drawPlayer() {
  colorMode(HSB);
  int p = 1;
  for (float x = step; x < xPlayer - step; x += step) {
    if (p < res) {
      stroke((x-step) % 256, 255, 255);
      line(x - step, playerGraph[p - 1], x, playerGraph[p]);
      p++;
    }
  }
  colorMode(RGB);

  //yPlayer = mouseY;
  fill((int)(i + millis()/2) % 256, 255, 200);
  //ellipse(xPlayer, yPlayer, 50, 50);
  pushMatrix();
  translate(xPlayer, yPlayer);
  float ang = 0;
  if (i > 20) {
    ang = atan((playerGraph[i-1]-playerGraph[i-21])/(20*step));
    println(playerGraph[i], playerGraph[i-1], ang);
  }
  rotate(ang);
  translate(-xPlayer, -yPlayer);
  image(imgNyancat, xPlayer, yPlayer);
  popMatrix();
}


void drawState() {
  fill(255, 255, 0);
  noStroke();
  textSize(height/20);
  String tekst = "";
  if (state == "idle") {
    tekst = "Level " + level + " - " + functionType[level-1] + "\nDruk op de spatiebalk om te starten!";
  } else if (state == "playing" || state == "countdown3" || state == "countdown2" || state == "countdown1") {
    tekst = "Level " + level + " - " + functionType[level-1];
  }
  text(tekst, width/2, height/18);
}

void calcScore() {
  float sum = 0;
  float max = height*res;
  for (int i = 0; i < res - 1; i++) {
    graph[i] = constrain(graph[i], -1, height); // to prevent a score of zero in levels with vertical asymptotes
    sum += abs(graph[i] - playerGraph[i]);
  }
  score  = round(1000.0 - sum / max * 1000.0)/10.0;
  if (score < 0) {
    score = 0;
  } else if (score > 80) {
    level++;
    if (level > numLevels) level = 1;
  }
}

void drawScore() {
  if (state == "finished") {
    for (int i = 0; i < res - 2; i++) {
      strokeWeight(1);
      colorMode(HSB);
      stroke((int)(i + millis()/4) % 256, 255, 100);
      line(i * step, graph[i], i * step, playerGraph[i]);
      strokeWeight(5);
      stroke((int)(i + millis()/4) % 256, 255, 255);
      line(i * step, playerGraph[i], (i+1)*step, playerGraph[i + 1]);
      colorMode(RGB);
    }

    fill(0, 255, 0);
    textSize((float)width / 5);
    text(score + " %", (float)width / 2, (float)height / 2);
  }
}
