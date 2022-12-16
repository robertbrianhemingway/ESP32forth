# ESP32forth
Forth words to use with ESP32 and ESP32forth

Starting early Dec22 to learn ESP32forth v7.0.6.19
These are some words developed as I learn
Starting with words to control sensors and screens and motors


When programming an ESP32 device have the following setup
- device connected via USB cable
- Arduino window open with ESP32forth_v70619_01 loaded and COM set correctly
- Notepad++ open with necessary test.f file open
- make changes to test.f and save to /data folder
- this folder should have autoexec.fs and test.f
- close the serial monitor window and upload files to spiffs using Arduino ESP32 Sketch Upload plugin
- This should restart forth on the ESP32, load in autoexec.fs which has 
-    : loadtest ." /spiffs/test.f" included ;
