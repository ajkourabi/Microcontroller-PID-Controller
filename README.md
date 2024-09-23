# Microcontroller-PID-Controller
The code in this repository was used to manipulate a microcontroller to change the temperature of a TEC module according to the user. 

This involves two main parts. 

## Matlab Oscilloscope 

Since traditional Oscilliscopes are not able to read serial data, a custom Oscilliscope was created within Matlab to enable the user to track temperature in real time, through taking data from the serial ports. 

## C Code 

This code was used to communicate with the Microcontroller, and manipulate the outputs to toggle a dedicated H-Bridge, which allowed for the increase or decrease of temperature of the [TEC](https://phononic.com/resources/what-is-a-tec-controller/#:~:text=A%20thermoelectric%20cooler%20(TEC)%20is,an%20electric%20current%20passes%20through.) unit. 

Within the C code is a an analogue to digital converter (ADC), alongside some logic that allows for receiving signals from MATLAB to heat or cool to whatever the user specifies. 
