( 221216 Connecting a 3v3 PIR to ESP32 DOIT Devkit V1 using ESP32forth v7.0.6.19 )
( led on pin D13 )

interrupts

13 constant pirLED
26 constant pirData
0  value ledOnAt_ticks

: setup ( -- )
    pirLED dup output pinmode
	  ." LED on " . cr
    pirData dup input   pinmode
	  ." PIR data pin on " . cr
		 
    low pirLED pin	
    	
;
		 
: ledON ( -- )
    high pirLED pin
;

: ledOFF ( -- )
    low pirLED pin
;

: ledToggle ( -- )
  pirLED digitalRead  \ high|low
  0=                  \ invert 
  pirLED pin
;

( make an ISR )
: isrPirData  ( -- )
    ledToggle
	ms-ticks to ledOnAt_ticks
;

( link pin to interrupt )
: pinHighEdge  ( xt pin -- )
  dup #GPIO_INTR_POSEDGE gpio_set_intr_type throw
  swap pirData gpio_isr_handler_add throw
;
  
setup  
' isrPirData pirData pinHighEdge  \ make the link
cr ." setup and isr linkage complete" cr