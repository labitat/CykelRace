const int fixedResistor = 100;     // fast monteret modstand
const int variableResistor 90;  // 'bakke'-modstand

int servoPin0 = A0;               // OUTPUTpin servo sidder på (analog)
int servoPin1 = A1;               // OUTPUTpin servo sidder på (analog)
int servoStatus0 = 0;            // map'et stilling til servo
int servoStatus1 = 0;            // map'et stilling til servo


enum { READY, RUNNING, DONE } racestate; // READY = vi er klar til at køre - den ene viser står i 'nedtællingsmode'
                                         // RUNNING = løbet er i gang
                                         // DONE = den ene løber har vundet, og vi skal ikke længere indlæse data fra inputpins
                                         
int buttonPin0 = 9;              // knap til tildeling af bakke - sidder på modstanderens cykel
// skal kun være aktiv når der er lys i den
int buttonPin1 = 10;              // knap til tildeling af bakke - sidder på modstanderens cykel
// skal kun være aktiv når der er lys i den

int readerPin0 = A2;              // analogIn, læser, gennem en modstand, nuværende spænding.
// modstanden skal være dimensioneret således at vi ikke få mere end 5v ind
int readerPin1 = A3;              // analogIn, læser, gennem en modstand, nuværende spænding.
// modstanden skal være dimensioneret således at vi ikke få mere end 5v ind

int rescontrolPin0 = 2;           // tænder og slukker for ekstra modstand
int rescontrolPin1 = 3;           // tænder og slukker for ekstra modstand

int currentVoltage0 = 0;         // spænding der måles lige nu
int currentVoltage1 = 0;         // spænding der måles lige nu

int hillButton0 = 0;
int hillButton1 = 0;
int extraresActive0 = 0;         // 0 eller 1 alt efter om ekstra modstand er slået til eller ej
int extraresActive1 = 0;         // 0 eller 1 alt efter om ekstra modstand er slået til eller ej

int resetPin = 4;               // 'hemmelig' knap til reset af løb (medmindre det sker automatisk?)
int startPin = 5;               // 'hemmelig' knap til start af løb - kan være samme som resetpin (toggle, 3 cycles) / kan også resette og bare starte

int tidStart  = 0;              // millis for hvornår program blev sat igang
int hilldDelay = 3000;           // 3 seconds
int hilltimerStart0 = 0;    // timer for bakke-modstand
int hilltimerStart1 = 0;    // timer for bakke-modstand

void setup() {
  int Goal = 200;                  // definerer målet for løbet (som også er max på skalaen)
  int Status0 = 0;                 // holder styr på hvor "langt" rytter 0 er nået 
  int Status1 = 0;                 // holder styr på hvor "langt" rytter 1 er nået

  Serial.begin(9600);
}

void loop() {
  currentVoltage0 = analogRead(readerPin0);
  currentVoltage1 = analogRead(readerPin1);

  // map currentVoltage0 efter en ca-skala (0 = 0V, 254 = 12v f.eks.)
  Status0 = (regn effekt ud, efter kendt spænding og kendt modstand og læg sammen med tidligere wStatus);
  servoStatus0 = map(wStatus, 0,0, wGoal, 117); // servoerne kan kun bevæge sig ca 0-120 grader.
  analogWrite(servoPin0, servoStatus0);
  // map currentVoltage1 efter en ca-skala (0 = 0V, 254 = 12v f.eks.)
  Status1 = (regn effekt ud, efter kendt spænding og kendt modstand og læg sammen med tidligere wStatus);
  servoStatus1 = map(wStatus1, 0,0, wGoal, 117); // servoerne kan kun bevæge sig ca 0-120 grader.
  analogWrite(servoPin1, servoStatus1);

  // vi skal tage stilling til om rytter 0 eller 1 må tildele den anden en "bakke"
  // hvis rytter 0 er 15w foran rytter 1, så kan der tildeles en bakke


  // er knappen blevet trykket
  // hvis ja, sæt ekstra modstand ind og sæt timer igang (uden delay)
  // start evt også noget 'lysshow'
  // hvis ekstra res er slået til, aflæs nuværende tid for at se om strafperioden er udløbet
  // udløbet? slå esktra res fra


  Serial.println(sensorValue);
}


// nulstil viserne mm. og gøre klar til næste løb
void reset(){
    
} 
