: abort ( -- ) -1 throw ;

( https://github.com/Esp32forth-org/haraldblab/blob/main/SG90_Servo.forth )
{ SG90 Servo Motor
  Expects a 20ms (ie 50Hz) signal.
  The best results I got was with a 10 bit resolution
  and 0.5ms to 2.5ms for angles 0 to 180
  16 bit resolution didn't work properly
  8 bit couldn't get to 0 or 180 positions
  10 bit gets full range
  
  The PWM functions are 
     ledcSetup and ledcAttachPin
	 pin# channel ledcAttachPin
	 channel frequency resolution ledcSetup
	
  For a 50Hz [20ms signal] enter frequency as 50000
  For resolution 2^10 this gives a range of 0 to 1024
  
  A 0.5ms pulse is 1/40 of 1024 = 25 pwm number  => 0 deg
  A 2.5ms pulse is 5x 0.5ms value  = 125 pwm number => 180 deg
  So any ledcWrite must be between 25 and 125
  
  Again we can't get to every angle as HL-LL is only 100
  
  12 bit resolution works well
  again from 0.5ms to 2.5ms pulse for angles 0 to 180
}

LEDC
DECIMAL

14 constant sg90Pin
 2 constant sg90Channel
50000 constant channelFrequency  ( 50 Hz)
12 constant pwmResolution  ( bits to equate to full voltage )
1 VALUE LL  ( pulse of 1ms to 0 deg )
1 VALUE HL  ( pulse of 2ms moves to 180 deg )

( ------------ Utility words ----------------------- )
( SG90 servo motor requires a pulse between LL and HL for angles 0 to 180 degrees )
( check lower limit ie 5 )
: checkLowLimit ( LL n0 -- n   where n is n0 if greater than LL else n0 is LL )
  2dup         \ LL n0 LL n0
  >            \ LL n0 f  where f=true => make n=LL
  IF           \ LL n0
     drop      \ LL
  ELSE         \ LL n0
     swap drop \ n0
  THEN
;  

( check upper limit ie 28 )
: checkHighLimit  ( HL n0 -- n  where n is n0 if less than HL else no is HL )
  2dup         \ HL n0 HL n0
  <            \ HL n0 f  where i=true => n=HL
  IF           \ HL n0
    drop       \ HL
  ELSE         \ HL n0
    swap drop  \ n0
  THEN
;


( ------------ SG90 words -------------------------- ) 
: calcLLandHL  ( -- )
  ( LL is 0.5 div 20 of resolution, HL is 2.5 div 10 resolution )
  1 pwmResolution lshift 1-   ( maxPWM     max pwm value )  
  40 /             ( LL   0.5ms pulse value )  
  dup              ( LL LL )
  to LL            ( LL )   
  5 * to HL        ( 2.5ms pulse value )
;


: setup ( n1 n0 -- ) ( channel pin# )
  calcLLandHL        ( calculate LL and HL )
  sg90Channel channelFrequency pwmResolution ledcSetup drop   
  sg90Pin sg90Channel ledcAttachPin
;

( now to check the low and high together )
: rangeCheck  ( low high n0 -- n  where n0 is pwm value 0 to 2^resolution)
  checkHighLimit    ( LL n )
  checkLowLimit     ( n )
;

: moveServoTo  ( deg -- pulse )  ( 0 <= deg <= 180 )
  0 180 rot
  rangeCheck  ( low high deg -- deg )
  HL LL -     ( deg   HL-LL )
  180 */      ( n )
  LL +        ( n+LL )
  sg90Channel swap ledcWrite
;

: sg90 ( n -- )  ( send a pwm value directly to sg90 )
  sg90Channel swap
  ledcWrite
;  

setup
: m moveservoto ;
100 value delay
: sweep 0 m 1000 ms 181 0 DO I m delay ms loop 1000 ms 0 m ;
