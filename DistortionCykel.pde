/*Copenhagen Game Collective +  Distortion 2012 - Cykel */

#include <Servo.h>

const int pinLED=13     ; // Onboard LED - bare til diag/alive info
const int pinCyk=A8     ; // Analog input fra cykel
const int pinSrv1=10    ; // Servo 1 pin  Sort
const int pinSrv2=11    ; //   -"-  2     Rød
const int pinKnp=A12    ; // Stor rød knap
const int pinLys = A15  ; // Lys i Knap
const int pinSegD = 4  ; // 7 Seg display - Data
const int pinSegC = 2  ; //    -"-        - Clock
const int pinSegL = 3  ; //    -"-        - Latch

const int S1_Low = 6    ; // Vinkel værdi hvor Servo 1 står pænt på null
const int S2_Low = 160  ; //    -"-                  2      -"-  (den kør omvendt)
const int S1_Hig = 147  ; // Vinkel værdi hvor Servo 1 står pænt på max
const int S2_Hig = 10   ; //    -"-                  2      -"-
const int A_Low = 300   ; // Analog måleværdi hvor spændning er "så godt som null"
const int A_Hig = 600   ; //    -"-                             "så godt som max"
const int S1_Mid = abs(S1_Hig+S1_Low)/2 ;
const int S2_Mid = abs(S2_Hig+S2_Low)/2 ;

// Bakke-"terrain". Bruges cirkulært
const byte Path[] = { 5, 3, 5, 6, 4, 7, 5, 8, 2, 3, 8, 4, 7 } ; 
const int Path_Len = sizeof(Path)/sizeof(Path[0]) ;

const unsigned long KvartKiloSekund = 100000UL ;  // Længde af et spil (milli sek) 
const unsigned long Step_Len=8000UL ; // Længde af hver trin (millisec) 
const int Knap_Max=1500 ;              // Millisekunder at trykke på lysende knap, inden straf udløses

Servo Serv1 ;
Servo Serv2 ;

enum { CntDwn, Comp, Stop, Idle } RaceState ; // Hvad laver vi
int SubState ;            // Under trin
int PathRnd ;             // tilfældig start i Path liste for hver løb
int KnapRnd ;             // tilfældig antal trin til næste knap-lys.
int StrafRun ;            // Misset knap try - straffe boks - antal trin med "ekstra"
long Score ;              // Point
const long Score_Max = KvartKiloSekund/100L ; // Possible max (if score sampled 0,1 Hz)
unsigned long Tim ;       // Timer for under trin
unsigned long Tik ;       // Timer2 for diverse
unsigned long Spil ;      // Timer for "kvart kilo sekund"

// ====================
void setup() {
// Sæt pin konfig, tænd lamper
  pinMode(pinLED,OUTPUT); digitalWrite(pinLED,HIGH) ; // Tændt i "setup" slukket ellers
  Serial.begin(9600); Serial.print("OK");                   // ==== Seriel ====
  pinMode(pinKnp,INPUT);  
  pinMode(pinLys,OUTPUT); digitalWrite(pinLys,HIGH) ;
  pinMode(pinSegD,OUTPUT); pinMode(pinSegC,OUTPUT); pinMode(pinSegL,OUTPUT);
  Seg ( B11011111 )  ;
  randomSeed(5/* <fixed sequence for test> analogRead(5)*/) ;
  Serv1.attach(pinSrv1,450,2500) ; Serv1.write(S1_Mid) ;
  Serv2.attach(pinSrv2,450,2500) ; Serv2.write(S2_Mid) ;
  delay(500) ;    // Giv servo tid at nå derhen

// sluk lamper som var tændt
  digitalWrite(pinLys,LOW) ;
  Seg ( B00001000 )  ;

// Meget kort test af visere
  for (int i=S1_Low; i<S1_Hig; i+=4) {  // lav en pæn "ramp up" til max (tester og viser)
    Serv1.write(i); Serv2.write(map(i,S1_Low,S1_Hig,S2_Low,S2_Hig)) ;
    delay(71) ; }
    Serv1.write(S1_Hig) ;  Serv2.write(S2_Hig) ; delay(500) ;
  for (int i=S1_Hig; i>S1_Low; i-=4) {  //  ditto nedad
    Serv1.write(i); Serv2.write(map(i,S1_Low,S1_Hig,S2_Low,S2_Hig)) ;
    delay(33) ; }
  Serv1.write(S1_Mid) ;  Serv2.write(S2_Mid) ; delay(500) ;    // Vent lidt mere
  Serial.println("!");                                    // ==== Seriel ====
  Seg ( B00000000 )  ;
  digitalWrite(pinLED,LOW) ; // noter setup færdig
  SubState = 0 ; RaceState = Idle ;  // Vi begynder i Idle, venter på (gen-)start
}

// ====================
void loop() {
  switch ( RaceState ) {
  case CntDwn : Do_CntDwn() ;  break ;
  case Comp : Do_Comp() ;  break ;
  case Stop : Do_Stop() ; break ;
  case Idle : Do_Idle() ; break ;
  }
}

// ====================
void Do_CntDwn() {
//  Nedtælling. Viserne begynder på hhv max og min, mødes i midten i 5 sekunds ryk */
  static byte B ;
  
// Blink knap lampe i mens
  if ( millis() - Tik > 500 ) {
    digitalWrite(pinLys,((B++)%2)?LOW:HIGH) ;
    Tik = millis() ;
  }
  
// Viser nedtælling
if ( SubState==0 ) { 
    Serv1.write(S1_Low) ; Serv2.write(S2_Hig) ;
    SubState=1 ; Tim=millis() ; Tik = Tim ;
  }
  else if ( millis()-Tim > 1000 && 1 <= SubState && SubState <= 5 ) {
    Serv1.write(map(SubState,1,5,S1_Low,abs(S1_Low+S1_Hig)/2)) ;
    Serv2.write(map(SubState,1,5,S2_Hig,abs(S2_Low+S2_Hig)/2)) ;
    SubState++ ; Tim=millis() ;
  }
  else if ( millis()-Tim > 1000 && SubState==6 ) {
    digitalWrite(pinLys,LOW) ;  // sluk knap lys
    RaceState = Comp ; SubState = 0 ;
  }
  
// Show count down as pattern...
  switch ( SubState ) {
    case 1: Seg ( B01000000 ) ; break ;
    case 2: Seg ( B11010000 ) ; break ;
    case 3: Seg ( B11011000 ) ; break ;
    case 4: Seg ( B11011101 ) ; break ;
    case 5: Seg ( B11011111 ) ; break ;
  }
}

// ====================
void Do_Comp() {
// Selve løbet. 

  static int KnapState ;          // Håndtering af knap tryk tilstande
  static int StrafAnt ;            // Antallet gange "straf" udfordring er kørt
  static unsigned long KnapTmr ;  // Måling af reaktions tid, eller blink af knap
  static int B ;                  // Blink 
  
// Viser 1 : Spændning nu.
  Maal() ;
  VisScore() ;
  
// Viser 2 : Random walk (liste med punkter)
// NB: Ændring af random værdierne og StrafAnt og StrafRun skal sammen gå op i en højre enhed.
  if ( SubState==0 ) { // initialiser alle tællere første gang
    PathRnd = random(Path_Len) ;
    KnapState = 0 ; KnapRnd = random(2,5) ; StrafRun = 0 ; StrafAnt = 0 ;
    Spil = millis() ; Tik = millis() ; Score = 0 ;
    NextStep();
    }
  else if ( millis() - Tim > (SubState==1?2:1)*Step_Len/(StrafRun>0?2:1) && SubState >0 ) // Step (dobbel tid første trin)
    NextStep() ;

// Reaktions test - tænd lampe og check knap
  if ( KnapRnd == 0 ) {
    if ( KnapState == 0 ) { 
      StrafAnt++ ;
      if ( StrafAnt > 3 ) KnapRnd = 9999 ;
      KnapTmr = millis() ; KnapState = 1 ;
    Serial.print("Tryk ") ;                                // ====== Serial DBG =====
      digitalWrite(pinLys,HIGH) ;
    }
    if ( KnapState == 1 ) {
      if ( digitalRead(pinKnp)==HIGH ) { // Nåede det inden tidsudløb
        digitalWrite(pinLys,LOW) ;
      Serial.println("Fri!") ;                                // ====== Serial DBG =====
        KnapRnd = random(2,5) ; 
        KnapState = 0 ;
      } else if ( millis() - KnapTmr > Knap_Max ) { // For langsomt!
        digitalWrite(pinLys,LOW) ;
        StrafRun = 3 ;
      Serial.println("Straf!") ;                              // ====== Serial DBG =====
        KnapRnd = random(2,5) + StrafRun ;
        KnapState = 0 ;
      }
    }
  }

// 0,1 Hz 
  if ( millis() - Tik > 100 ) {
    Tik = millis() ;
// Check om viser er tæt på hindanden. Læg en til Score
  if ( abs(S2_Hig-Serv2.read() - Serv1.read()) < 20 ) Score++ ;
    
    
//  blink knap i straf
    if ( StrafRun > 0 ) digitalWrite(pinLys,((B++)%2)?HIGH:LOW) ;
    else if ( B!=0 ) { digitalWrite(pinLys,LOW) ; B=0 ; } 
  }

// Spil slut test
  if ( millis() - Spil > KvartKiloSekund )
    { RaceState = Stop ; SubState = 0 ; }

}

// =-=-=-=-=-=-=-=-=-=-
void NextStep() {
// Sæt viser til næste trin i "Comp" fasen. Og opdater Score
  Serv2.write(map(Path[(SubState+PathRnd)%Path_Len+1]+(StrafRun>0?2:0), 0, 10, S2_Low, S2_Hig ) ) ;
//  Serial.print((SubState+PathRnd)%(Path_Len+1)) ; Serial.print(":"); // ======= Serial DBG =======
//  Serial.print(Path[(SubState+PathRnd)%(Path_Len+1)]) ;            // ======= Serial DBG =======
  Serial.print(Score);Serial.print(":");Serial.println(constrain(map(Score, 0,Score_Max, 0,9),0,9));                       // ======= Serial DBG =======
  KnapRnd-- ; 
  if ( StrafRun > 0 ) StrafRun-- ;
  SubState++ ;  Tim = millis() ;
}

// ====================
void Do_Stop() {
// Slut. Varer i 5 sekunder. 
  Seg ( 0 ) ;                      // Sluk score
  Serv1.write(S1_Hig) ;            // viserne i "umulig" 
  Serv2.write(S2_Low) ;            //
  digitalWrite(pinLys,HIGH) ;      // Tænd knap
  if ( SubState == 0 ) { 
    Tim = millis() ; SubState = 1 ; 
  } else {
    if ( millis() - Tim > 5000 ) { // 5 sec
      SubState = 0 ; RaceState = Idle ;
    }
  }    
}

// ====================
void Do_Idle() {
// Slut&start. Vis Score, blinkende
  static int B ;
  
// Viser 2 i midt.
  if ( SubState == 0 ) { 
    SubState = 1 ; Tim = millis() ; Tik = millis() ;
    Serv2.write(S2_Mid) ; 
  }

// Viser 1 aktiv måling af analog
    Maal() ;
//  Knaplys er echo af knap    
    if ( digitalRead(pinKnp)==HIGH ) // ajourfør knap lys med knap tilstand
      digitalWrite(pinLys,HIGH) ;
      else digitalWrite(pinLys,LOW) ;
// Check om knap er nede i 3 sekunder - Gå til CountDown
  if ( digitalRead(pinKnp)==LOW ) 
    Tim = millis() ;
  else if ( millis() - Tim > 3000 ) {
    RaceState = CntDwn ; SubState = 0 ; 
  } 
// Blink score
  if ( millis() - Tik > 500 ) {
    B = (B+1)%2 ;
    if ( B ) Seg ( 0 ) ; else VisScore() ;
    Tik = millis() ;
  }
}

// ====================
void Maal() {
// Overfør måling på analog pin til visere 1
// Da det er svært at cykle helt jævnt laver vi et par sekunders løbende gennemsnit.
// vi reducere måle frekvensen til højst 0,1Hz
  static long unsigned Tmr = 0 ;
  static int Vaerdier[] = { 0,0,0,0,0, 0,0,0,0,0 };   // målepunkter
  const int NyV_Max=sizeof(Vaerdier)/sizeof(Vaerdier[0]) ;
  static int NyV = 0 ;            // Hvilken målepunkt skiftes
  static long Vaerdi = 0 ;
  if ( millis() - Tmr > 100 ) {
    Vaerdi -= Vaerdier[NyV] ;
    Vaerdier[NyV] = analogRead(pinCyk) ;
    Vaerdi += Vaerdier[NyV] ;
    NyV = (NyV+1)%NyV_Max ;
//    Serial.print(NyV);Serial.print(":");Serial.print(Vaerdier[NyV]);Serial.print(" ");Serial.println(Vaerdi/NyV_Max);
    Tmr = millis() ;
  }
  Serv1.write(constrain(map(Vaerdi/NyV_Max, A_Low, A_Hig, S1_Low, S1_Hig ),S1_Low,S1_Hig) ) ;
}

// ====================
void VisScore() {
// Viser et enkel ciffer   
const int sevenSeg[10] = {
  0xD7, // 0 dec 1101 0111 bin
  0x81, // 1 dec 1000 0001 bin
  0xCE, // 2 dec 1100 1110 bin
  0xCB, // 3 dec 1100 1011 bin
  0x99, // 4 dec 1001 1001 bin
  0x5B, // 5 dec 0101 1011 bin
  0x5F, // 6 dec 0101 1111 bin
  0xC1, // 7 dec 1100 0001 bin
  0xDF, // 8 dec 1101 1111 bin
  0xDB  // 9 dec 1101 1011 bin
};
//     Serial.println(Score) ; 
  Seg( sevenSeg[constrain(map(Score, 0,Score_Max, 0,9),0,9)]) ;
}

void Seg( byte Pat ) { 
// Output 7 seg binary pattern
  digitalWrite(pinSegL,LOW) ;
  shiftOut(pinSegD, pinSegC, MSBFIRST, Pat) ;
  digitalWrite(pinSegL,HIGH) ;
}
