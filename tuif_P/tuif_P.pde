import TUIO.*;
import processing.serial.*;

TuioProcessing tuioClient;
ParticleSystem ps;

PImage curTriangle, triangle_white, triangle_red, triangle_green, triangle_yellow;

float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

boolean verbose = false;
boolean callback = true;

Serial myPort;

TuioObject tobj;

// Serial frame: "S" + B1 + B2 + poti + "E" + newline (e.g. S100E)
String portStream;
int B1in = 0;
int B2in = 0;
int poti;

void setup() {
  ps = new ParticleSystem(new PVector(0, 0));

  triangle_white = loadImage("triangle_white.png");
  curTriangle = triangle_white;
  triangle_red = loadImage("triangle_red.png");
  triangle_green = loadImage("triangle_green.png");
  triangle_yellow = loadImage("triangle_yellow.png");

  String[] ports = Serial.list();
  if (ports.length == 0) {
    println("No serial ports found.");
  } else {
    int portIndex = min(2, ports.length - 1);
    println("Opening serial port:", ports[portIndex]);
    myPort = new Serial(this, ports[portIndex], 9600);
    myPort.bufferUntil('\n');
  }

  noCursor();
  fullScreen();
  noStroke();

  if (!callback) {
    frameRate(60);
    loop();
  } else {
    noLoop();
  }

  font = createFont("Arial", 18);
  scale_factor = height / table_size;

  tuioClient = new TuioProcessing(this);
}

void serialEvent(Serial port) {
  if (myPort != null && port == myPort) {
    portStream = port.readString();
  }
}

void applySerialFrame() {
  if (portStream == null) return;
  String s = trim(portStream);
  if (s.length() >= 5 && s.charAt(0) == 'S' && s.charAt(4) == 'E') {
    B1in = int(s.substring(1, 2));
    B2in = int(s.substring(2, 3));
    poti = int(s.substring(3, 4));
    curTriangle = triangle_white;
    if (B1in == 1) {
      curTriangle = triangle_green;
    }
    if (B2in == 1) {
      curTriangle = triangle_red;
    }
    if (B1in == 1 && B2in == 1) {
      curTriangle = triangle_yellow;
    }
  }
}

void draw() {
  applySerialFrame();

  background(0);
  ps.addParticle();

  textFont(font, 18 * scale_factor);

  ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
  for (int i = 0; i < tuioObjectList.size(); i++) {
    tobj = tuioObjectList.get(i);
    changeParticleSystemPosition();

    pushMatrix();
    translate(tobj.getScreenX(width), tobj.getScreenY(height));
    rotate(tobj.getAngle());
    int sym = tobj.getSymbolID();
    if (sym == 0 || sym == 1 || sym == 2) {
      ps.run(sym);
    }
    popMatrix();
  }
}

void addTuioObject(TuioObject tobj) {
  if (verbose) {
    println("add obj " + tobj.getSymbolID() + " (" + tobj.getSessionID() + ") " + tobj.getX() + " " + tobj.getY() + " " + tobj.getAngle());
  }
}

void updateTuioObject(TuioObject tobj) {
  if (verbose) {
    println("set obj " + tobj.getSymbolID() + " (" + tobj.getSessionID() + ") " + tobj.getX() + " " + tobj.getY() + " " + tobj.getAngle()
      + " " + tobj.getMotionSpeed() + " " + tobj.getRotationSpeed() + " " + tobj.getMotionAccel() + " " + tobj.getRotationAccel());
  }
}

void removeTuioObject(TuioObject tobj) {
  if (verbose) {
    println("del obj " + tobj.getSymbolID() + " (" + tobj.getSessionID() + ")");
  }
}

void refresh(TuioTime frameTime) {
  if (verbose) {
    println("frame #" + frameTime.getFrameID() + " (" + frameTime.getTotalMilliseconds() + ")");
  }
  if (callback) {
    redraw();
  }
}

void changeParticleSystemPosition() {
  PVector result = new PVector(tobj.getScreenX(width), tobj.getScreenY(height));
  ps.particleSystemPos = result;
  ps.origin.set(result.x, result.y);
}
