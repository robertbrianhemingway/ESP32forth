\ DHT11, DHT22 1-wire Control Code - ESP32FORTH
\ Frank Lin 2022.7.20
\ ORIGINAL ARTICLE : https://ohiyooo2.pixnet.net/blog/post/406078286
\ Digital I/O Access Codes
\
\
\ DHT Sensor, 1-wire data Pin
\
14 constant DHTPin \ Pin14 as DHT data Pin

cr ." DHT11 & DHT22" cr
 
: >OUTPUT ( pin --) \ set the direction of digital I/O to output
    output pinMode
  ;
: <INPUT ( pin --) \ set the direction of digital I/O to input
    input pinMode
  ;
: PULLUP ; immediate \ dummy for syntax sweeter
: ->High ( pin --) \ put digital I/O to High
    high digitalWrite
  ;
: ->Low ( pin --) \ put digital I/O to Low
     low digitalWrite
  ;
: Pin@ ( pin -- status) \ read the state of digital I/O, 0=low, 1=high
   digitalRead
  ;
: ticks ( -- ticks )
   ms-ticks
  ;

: wait ( --) \ wait until pulse-high
   begin DHTPin Pin@ until 
  ;
   
\
\ DHT 1-wire signal:
\ start: 50uS Low
\ signal 1: 70 uS Pulse High
\ signal 0: 26 - 28 uS Pulse High
 
\
\ 112uS / 0.642uS = 174
\ 67.175uS / 0.642uS = 104
\
   
: signal@ ( -- true=1/false=0)
   174 ( ~112uS)
   for 
       DHTPin Pin@ 0= ( pulse low?)
       if r> 104 ( ~ 67.175uS) < exit ( length > 70 = 44.825 uS)
       then
   next
   ." Error! Signal not match with expectation!" cr
   abort
  ;
 
: 8bits@ ( -- Data)
   0 ( data)
   7 for
        wait 
        signal@ if 1 r@ lshift or then
     next
  ;
: 40bits@ ( -- n1 n2 n3 n4 n5)
    4 for 8bits@ next
  ;
\
\ Start Signal
\ 18mS Low, to active communication  
\ then 20 - 40uS High
\ then wait DHT sends 80uS Low, 80uS High
\ then receive 40bits data transmition from DHT

\
: start! ( --)
   DHTPin >OUTPUT
   DHTPin ->Low
     20 ms
   DHTPin ->High
     20 usecs    ( ~ 14uS)
   DHTPin <INPUT  
  ;
: DHT@ ( -- n1 n2 n3 n4 CheckSum)
   start!  
   20 usecs              ( ~ 20uS)
   wait
   80 usecs              ( ~ 82uS) 
   40bits@
  ;
 
: >DHT11 ( RHint RHdec Tint Tdec Checksum -- RH Temp)
   nip over - >r ( RHint RHdec Tint | R: checksum')
   nip over r> -  ( RHint Tint deltaChksum )
   ( abort" Error: CheckSum not match!!" )
   ( RHint Tint CS )
   abs   ( .[xx] can't handle -ve checksum )
   -rot  ( CS RH Temp )
  ;
   
: ?negate ( n1 n2 -- n3)
    $80 and if negate then
  ;
 
: >DHT22 ( RH.H RH.L TH TL Checksum -- RH Temp)
   >r 2dup + >r  
   swap 8 lshift or >r ( RH.H RH.LR: T CS1 CS)
   2dup + >r ( RH.H RH.LR: CS2 T CS1 CS)
   swap 8 lshift or ( RH R: CS2 T CS1 CS)
   r> r> swap ( RH T CS2 R: CS1 CS)
   r> + ( RH T CS3 R: CS)
   256 u/mod drop
   r> <>
   ( abort" Error: CheckSum not match!!" )
   drop
   
   $7fff over and swap ?negate
  ;
: DHT11@ ( -- CS RH T)
    DHT@ >DHT11      ( CS RHint Tint )
    ( 10 * >r 10 * r> )  ( integer output only )
  ;

: DHT22@ ( -- RH T)
    DHT@ >DHT22
  ;
 
: .[xx]  <# #s #> type ;
: .[xx.x] <# # [char] . hold #s #> type ;
 
: DHT11
   cr
   10 0 DO
     DHT11@
     ." DHT11 :"
     ." Temp. = " .[xx] ." C , "
     ." Rel.Humid = " .[xx] ." % " 
     ." (CS:" .[xx] ." )"
     cr
     2000 ms
   LOOP
  ;
 
: DHT22
   cr
   10 0 DO
     DHT22@  ( -- RH*10 Temp*10 )
     ." DHT22 :"
     ." Temp. = " .[xx.x] ." C , "
     ." Relative Humidity = " .[xx.x] ." %" cr
     2000 ms
   LOOP
  ; 