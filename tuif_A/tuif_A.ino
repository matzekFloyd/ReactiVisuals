#include <Bounce2.h>
#include <Encoder.h>

Encoder myEnc(12, 24);

int ledGruen = 6;
int ledGelb = 8;
int ledRot = 10;


//Arduino Sketch
// Button 1 kommt an Pin 2, Button 2 an Pin 10
const int buttonPin1 = 2;
const int buttonPin2 = 4;
 
// Zum Zwischenspeichern der Button-Zustände
int buttonState1 = 0;
int buttonState2 = 0;
int potiState;
 
// Enthält den String, der an den PC geschickt wird
String data;

Bounce debouncer1 = Bounce();   // Erstellt ein Bounce-Objekt namens debouncer
Bounce debouncer2 = Bounce();   // Erstellt ein Bounce-Objekt namens debouncer

boolean previousState1 = false; // Speichert den vorigen Zustand des Tasters
boolean switchState1 = false;   // Speicherung den Zustand des Toggle-Schalters
boolean previousState2 = false; // Speichert den vorigen Zustand des Tasters
boolean switchState2 = false;   // Speicherung den Zustand des Toggle-Schalters
 
// Serielle Schnittstelle einrichten, pinModes setzen
void setup() {
  Serial.begin(9600);
  pinMode(buttonPin1, INPUT_PULLUP);
  pinMode(buttonPin2, INPUT_PULLUP);
   pinMode(ledGruen, OUTPUT);   
   pinMode(ledGelb, OUTPUT);   
   pinMode(ledRot, OUTPUT);   

  debouncer1.attach(buttonPin1);  // Zuweisung des Pins an debouncer
  debouncer1.interval(5);         // interval in ms
  debouncer2.attach(buttonPin2);  // Zuweisung des Pins an debouncer
  debouncer2.interval(5);         // interval in ms
}

long oldPosition  = -999;
 
void loop() {
  
  // Beise Buttons auslesen
  buttonState1 = button1();
  buttonState2 = button2(); 
  potiState = potentiometer();
  if(buttonState1 == 1) digitalWrite(ledGruen, HIGH);
  else digitalWrite(ledGruen, LOW);
  if(buttonState2 == 1) digitalWrite(ledRot, HIGH);
  else digitalWrite(ledRot, LOW);
  if(buttonState1 == 1 && buttonState2 == 1) digitalWrite(ledGelb, HIGH);
  else digitalWrite(ledGelb, LOW);
  // und in einen einfachen String zusammenbauen
  data = normalizeData(buttonState1, buttonState2, potiState);
  // dieser String (z.B. S10E+Zeilwenwechsel) wird dann seriell ausgegeben.
  Serial.println(data);
  // Um die serielle Ausgabe zu beobachten, einfach nach dem Programmstart den seriellen Monitor in der Arduino Umgebung starten
  delay(20);
}
 
// normalizeData fügt die Werte der beiden Buttons zusammen und ergänzt den String um ein eindeutiges Start- und Endezeichen
String normalizeData(int b1, int b2, int poti) {
 
  String B1string = String(b1);
  String B2string = String(b2);
  String potiString = String(poti);
 
  // Erzeugt Werte wie S00E, S10E, S01E, S11E
  String ret = String("S") + B1string + B2string + potiString + String("E");
  return ret;
}

int button1(){
  debouncer1.update();  // debouncer muss in jeder loop-Ausführung upgedated werden

  // Get the updated value :
  boolean currentState1 = !debouncer1.read(); // k

 
  if(!previousState1 && currentState1){
    // steigende Flanke gefunden. Zustand des Umschalters wird invertiert.
    switchState1 = !switchState1;
    //digitalWrite(13, switchState);
    //Serial.println(switchState1);
  }
  // fallende Flanke? nur wenn voriger State TRUE war und jetziger State FALSE ist
  else if (previousState1 && !currentState1) {
    // fallende Flanke gefunden. Keine Zustandsänderung ist notwendig.
  }
 
  previousState1 = currentState1;
  return switchState1;
}

int button2(){
  debouncer2.update();  // debouncer muss in jeder loop-Ausführung upgedated werden

  // Get the updated value :
  boolean currentState2 = !debouncer2.read(); // k

 
  if(!previousState2 && currentState2){
    // steigende Flanke gefunden. Zustand des Umschalters wird invertiert.
    switchState2 = !switchState2;
    //digitalWrite(13, switchState);
    //Serial.println(switchState1);
  }
  // fallende Flanke? nur wenn voriger State TRUE war und jetziger State FALSE ist
  else if (previousState2 && !currentState2) {
    // fallende Flanke gefunden. Keine Zustandsänderung ist notwendig.
  }
 
  previousState2 = currentState2;
  return switchState2;
}

int potentiometer(){
  long newPosition = myEnc.read();
  if (newPosition != oldPosition) {
    oldPosition = newPosition;
    Serial.println(newPosition);
  }
  return newPosition;
}
