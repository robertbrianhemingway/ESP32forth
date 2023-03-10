( Forthmobile@ project  PeterForth & Atle Bergstrom@ ) 
( thanks to Atle for his great  ideas !  ) 
( it works on the ESP32forth of Dr. Ting & Brad Nelson) 

FORTH  DECIMAL
 
18 constant PWML   5 constant dirleft1   17 constant dirleft2
15 constant PWMR   4 constant dirright1  16 constant dirright2

1 constant chLEFT    
2 constant chRIGHT
3 constant chBOTH

1  constant FORWARD 
0  constant BACKWARD
 
FORTH DEFINITIONS also LEDC   ( vocabulary ) 

: init_dir_pins  ( --)   
	    dirleft1   OUTPUT pinmode  dirleft2  OUTPUT pinmode  
	    dirright1  OUTPUT pinmode  dirright2 OUTPUT pinmode ;

: init_pwm_pins  ( --)   
                  PWML chLEFT      ledcAttachPin        PWMR chRIGHT   ledcAttachPin 
	          chLEFT 40000 10  ledcSetup        chRIGHT 40000 10   ledcSetup ;

 
: SETPINS   ( n n n n  --)   
               dirleft1 pin     dirleft2 pin  
               dirright1 pin    dirright2 pin  ;
			   
: FW     0 1  0 1 SETPINS ;
: BW     1 0  1 0 SETPINS ;
: LEFT   0 1  1 0 SETPINS ;
: RIGHT  1 0  0 1 SETPINS ;	

 
: initall   ( --)  init_dir_pins  init_pwm_pins FW ;

: motleft  ( speed -- ) DUP chLEFT swap ledcWrite chRIGHT swap ledcWrite ;
: motright ( speed -- ) DUP chRIGHT swap ledcWrite ; 

( abbreviations for fast typing)
: ml  motleft ;
: mr  motright ;
	
( MOTORS MOVE)	
: MM ( speed -- ) DUP chLEFT swap ledcWrite chRIGHT swap ledcWrite ;

initall

260 value speed
260 value slowspeed
400 value fastspeed

: run  speed mm ;

: STOP  0 mm ;

: slow  slowspeed to speed  run ;
: fast  fastspeed to speed  run ;


' slow is  user1  
' fast is  user2  
' fw  is   user3 
' bw  is   user4  
' left is  user5  
' right is user6 
' RUN  is  user7  
' stop is  user8  
	
  \\ more to follow , still on development 