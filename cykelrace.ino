const int fixedResistor = 100;     // fast monteret modstand
const int variableResistor 90;  // 'bakke'-modstand

int servoPin = A0;               // OUTPUTpin servo sidder på (analog)
int buttonPin = 9;              // knap til tildeling af bakke - sidder på modstanderens cykel
                        // skal kun være aktiv når der er lys i den

int readerPin = A1;              // analogIn, læser, gennem en modstand, nuværende spænding.
                        // modstanden skal være dimensioneret således at vi ikke få mere end 5v ind
int rescontrolPin = 2;           // tænder og slukker for ekstra modstand

int servoStatus = 0;            // map'et stilling til servo
int currentVoltage = 0;         // spænding der måles lige nu

int hillButton = 0;
int extraresActive = 0;         // 0 eller 1 alt efter om ekstra modstand er slået til eller ej

int resetPin = 2;               // 'hemmelig' knap til reset af løb (medmindre det sker automatisk?)
int startPin = 3;               // 'hemmelig' knap til start af løb - kan være samme som resetpin (toggle, 3 cycles) / kan også resette og bare starte

int resStart  = 0;              // millis for hvornår timer blev sat igang
int hilldDelay = 3000;           // 3 seconds

void setup() {
  int wGoal = 200;                  // definerer målet for løbet (som også er max på skalaen)
  int wStatus = 0;                 // holder styr på hvor langt en rytter er nået

  Serial.begin(9600);
}

void loop() {
  currentVoltage = analogRead(readerPin);
  // map currentVoltage efter en ca-skala (0 = 0V, 254 = 12v f.eks.)
  wStatus = (regn effekt ud, efter kendt spænding og kendt modstand og læg sammen med tidligere wStatus);
  servoStatus = map(wStatus, 0,0, wGoal, 117); // servoerne kan kun bevæge sig ca 0-120 grader.
  analogWrite(servoPin, servoStatus);

  hillButton = digitalRead(rescontrolPin);
  if (hillButton == 1) {
    extraresActive = 1;
    // aktiver ekstra modstand
    resStart = millis();
    digitalWrite(rescontrolPin, HIGH);
    // disable the hillButton.. with state? 
  }
  // er knappen blevet trykket
  // hvis ja, sæt ekstra modstand ind og sæt timer igang (uden delay)
  // start evt også noget 'lysshow'
  // hvis ekstra res er slået til, aflæs nuværende tid for at se om strafperioden er udløbet
  // udløbet? slå esktra res fra
  

  Serial.println(sensorValue);
}
