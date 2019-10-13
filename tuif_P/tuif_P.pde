import TUIO.*;

TuioProcessing tuioClient;
ParticleSystem ps;

PImage curTriangle, triangle_white, triangle_red, triangle_green, triangle_yellow;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

boolean verbose = false; // print console debug messages
boolean callback = true; // updates only after callbacks
import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port
int val1 =1;

TuioObject tobj;

Boolean buttonRed = false;

// String für empfangene Daten
String portStream;
 
// Zustände der beiden Buttons
int B1in = 0;
int B2in = 0;
int poti;

void setup()
{
  ps = new ParticleSystem(new PVector(0,0));

  triangle_white = loadImage("triangle_white.png");
  curTriangle = triangle_white;
  triangle_red = loadImage("triangle_red.png");
  triangle_green = loadImage("triangle_green.png");
  triangle_yellow = loadImage("triangle_yellow.png");

  String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');

  noCursor();
  //size(1200,600);
  fullScreen();
  noStroke();
  
  if (!callback) {
    frameRate(60); //<>//
    loop();
  } else noLoop();
  
  font = createFont("Arial", 18);
  scale_factor = height/table_size;
  
  // finally we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods in this class (see below)
  tuioClient  = new TuioProcessing(this);
}

// serialEvent wird aufgerufen, wenn das weiter oben über bufferUntil definierte Zeichen empfangen wird.
// Dann wird der Inhalt des seriellen Buffers in portStream geschrieben.
void serialEvent(Serial myPort) {
  portStream = myPort.readString();
}

float generateRandomNumber(){
  float result = random(-1, 1);
  return result;
}

void draw()
{
  background(0);
  ps.addParticle();

   
  if(tobj != null){
    //System.out.println(tobj.getSymbolID());
    if(tobj.getSymbolID() == 0){
            ps.run(0);
    } 
    if(tobj.getSymbolID() == 1){
            ps.run(1);
    }
    if(tobj.getSymbolID() == 2){
            ps.run(2);
    }
  
  if(portStream != null) {
    // Entspricht der Datenblock dem Format "SxxxE\r\n"? Wenn ja, dann weiter
    if (portStream.length() == 7 && portStream.charAt(0) == 'S' && portStream.charAt(4) == 'E') {
      // 2. und 3. Zeichen auslesen
      B1in = int(portStream.substring(1,2));   // z.B. bei "S100E" = 1
      B2in = int(portStream.substring(2,3));   // z.B. bei "S100E" = 0
      poti = int(portStream.substring(3,4));
      curTriangle = triangle_white;
      fill(255,255,255,lifespan);
      if (B1in == 1) {
        fill(0,255,0,lifespan);
        //if(tobj.getSymbolID() == 2) curTriangle = triangle_green;
        curTriangle = triangle_green;
      }    
   
      if (B2in == 1) {
        fill(255,0,0,lifespan);
        //if(tobj.getSymbolID() == 2) curTriangle = triangle_red;
        curTriangle = triangle_red;

      }

      if(B1in == 1 && B2in == 1){
        fill(255,255,0,lifespan);
        //if(tobj.getSymbolID() == 2) curTriangle = triangle_yellow;
        curTriangle = triangle_yellow;
      } 
    }
  }  
     }

  background(0);
  textFont(font,18*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
   
  ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
  for (int i=0;i<tuioObjectList.size();i++) {
     tobj = tuioObjectList.get(i);
     changeParticleSystemPosition();
     
     pushMatrix();
     translate(tobj.getScreenX(width),tobj.getScreenY(height));
     rotate(tobj.getAngle());
     if(tobj.getSymbolID() == 0) ps.run(0);
     if(tobj.getSymbolID() == 1) ps.run(1);
     if(tobj.getSymbolID() == 2) ps.run(2);
     popMatrix();
   }
}

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  if (verbose) println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  if (verbose) println("set obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
          +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  if (verbose) println("del obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}

// --------------------------------------------------------------
// called at the end of each TUIO frame
void refresh(TuioTime frameTime) {
  if (verbose) println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
  if (callback) redraw();
}

  void changeParticleSystemPosition(){
          PVector result = new PVector(tobj.getScreenX(width),tobj.getScreenY(height));   
          ps.particleSystemPos = result; 
  }

// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  PVector particleSystemPos;

  ParticleSystem(PVector position) {
    particleSystemPos = position.copy();
    origin = position.copy();
    particles = new ArrayList<Particle>();
  }

  void addParticle() {
    particles.add(new Particle(origin));
  }
  
  int generateNumber(){
    float result = random(-1,1);
    if(result >= 0) return 1;
    return 0;
  }
  
  void run(int id) {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run(id, generateNumber());
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}

// A simple Particle class

float lifespan;

class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;

  Particle(PVector l) {
    acceleration = new PVector(0, 0.075);
    velocity = new PVector(random(-1, 1), random(-2, 0));
    position = l.copy();
    lifespan = 150.0;
  }

  void run(int id, int number) {
    update();
    display(id, number);
  }

  // Method to update position
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 1.0;
  }
  
  // Method to display
  void display(int id, int number) {   
    if(id == 0){
      ellipse(position.x, position.y, map(poti,0,2,10,70), map(poti,0,2,10,70));
    } 
    if(id == 1){
      if(number == 1){
        textSize(map(poti,0,2,20,60));
        text("1", position.x, position.y);      
      }
      if(number == 0){
        textSize(map(poti,0,2,20,60));
        text("0", position.x, position.y);      
      }
    } 
    if(id == 2){
        image(curTriangle, position.x, position.y, map(poti,0,2,10,70), map(poti,0,2,10,70));        
    }
  }

  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}