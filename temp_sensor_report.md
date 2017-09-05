**Group Member Names:** Andy Graham, Marshall Reed, Jonathan Christian,
Mussie Bariagabir **Course and Quarter:** ENGR 114 Summer 2017

**Date:** 9/5/2017

**Final project:** Temperature Sensor

The Temperature Sensor
----------------------

#### 

#### **Problem Statement:**

In order for the fish tank and hydroponic garden (located in AM103) to
be sustained, there are many working parts that must be maintained,
including the utilization of a temperature sensor. The temperature
sensor takes readings from the water of the fish tank, in order to
provide information to a lab technician as to whether the water is too
warm (a situation where either the water pump would need to be turned on
to get the water flowing and/or the grow light be turned off to allow
the water to cool down), or too cool (which any running pump would need
to be turned off, and/or the grow light turned on).

Our group has been tasked with analyzing and developing code in Arduino
and MATLAB, which interprets sensor data taken in voltage from a
thermistor, converts it to temperature, then uploads that data to an IoT
(Internet of Things) server. We must also be able to retrieve the
information for future utilization by other groups.

To accomplish the task, our group has analyzed the Arduino code from a
previous term, and made several adjustments to ensure that the code
functioned as it should. It was then tested and calibrated to ensure
that it sent correct data to the serial port. We then downloaded
previously written MATLAB code and modified it to allow for the
uploading of the data to the IoT (in this case, ThingSpeak.org). MATLAB
code was also written for the retrieval of the data, in a form that is
easy to interpret, and provides a plot of the data.

**Hardware Process Flowchart** (taken from the
ENGR114\_Arduino\_IoT\_Project\_Description file)

<img src="./media/image1.tiff" width="370" height="182" />

**Hardware Setup:**

Bill of Materials:

| Part Name        | Purpose                                                                        | Item Name                                                                         | URL                                     | Price   |
|------------------|--------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|-----------------------------------------|---------|
| Red Board        | Red board Arduino, uses to build electronic projects, in our case temp-sensor. | Arduino Circuit Board                                                             | https://www.sparkfun.com/products/13975 | $ 19.95 |
| Thermistor       | Temperature sensor                                                             | [10K Precision Epoxy Thermistor - 3950 NTC](https://www.adafruit.com/product/372) | https://www.adafruit.com/product/372    | $1.61   |
| 10k resistor     | Resisting flow of current that comes from red board to temp-sensor.            | 10k Resistor (red, black, orange, gold)                                           | https://www.sparkfun.com/products/11507 | $0.15   |
| breadboard       | To build the temp-sensor circuit schematic.                                    | Breadboard self-Adhesive (white)                                                  | https://www.sparkfun.com/products/12002 | $4.50   |
| Jumper wires     | connects breadboard to Arduino and to other piece of circuit.                  | Jumper wires-black, red, green, blue and white                                    | https://www.sparkfun.com/products/11026 | $1.95   |
| Mini B USB cable | Transferring data from Arduino to CPU                                          | USB Mini -B Cable-Red                                                             | https://www.sparkfun.com/products/11301 | $11.99  |

**Hardware Schematic** (obtained from previous year’s project on
Github.com)

<img src="./media/image2.png" width="387" height="236" />

**Hookup Guide (photograph taken by group)**
<img src="./media/image3.jpeg" width="440" height="235" />**:**

| ***Part***         | ***Pin***           | ***Connector***                                         | ***Pin***           | ***Part***          |
|--------------------|---------------------|---------------------------------------------------------|---------------------|---------------------|
| 10k Resistor       | Pin 6 (Breadboard)  | Red wire (from any side because resistor is non- polar) | 5v (voltage source) | Arduino (red board) |
| 10k Resistor       | Pin 11 (Breadboard) | Green wire                                              | A0                  | Arduino (red board  |
| Temp Sensor        | Pin 16 (Breadboard) | Black wire                                              | GRD (ground)        | Arduino (red board  |
| Temp Sensor        | Pin 11 (Breadboard) | Green wire                                              | A0                  | Arduino (red board  |
| Arduino (RedBoard) | USB port            | USB Cable (red)                                         | USB port            | CPU                 |

**MATLAB Code:**

Arduino Project - Temperature Sensor Send and Retrieve

-   Authors: The Temp Sensor Group

-   Course: ENGR114

-   Date: Sept 5, 2017

-   Description: This script gives the user the option to send data to
    > the IoT at ThingSpeak.org, or

-   retrieve temperature sensor data from ThingSpeak and plot it to
    > a graph.

Attempt to execute SCRIPT temp\_sensor\_send\_retrieve as a function:

/Users/andrewgraham/Desktop/temp\_sensor\_send\_retrieve.m

**Contents**

-   [Clear All Variables/Command Window/Close Windows](#1)

-   [Send Data](#2)

-   [Open The Serial Port To Connect To The Arduino](#4)

-   [Ask user for how much data to write](#5)

-   [Send the Serial Data to the IoT (Thingspeak) with a Web API
    > Call](#6)

-   [Plots a Nice Graph](#7)

-   [Display when finished](#8)

-   [Retrieve Data](#9)

-   [Ask user for number of data points to retrieve](#12)

-   [Retrieve the Serial Data from the IoT (Thingspeak) with a Web API
    > Call](#13)

-   [Clean structure array data into matrix data to be used in
    > plot](#14)

-   [Show the User API Call and IoT Response](#15)

-   [Plots a Nice Graph](#16)

-   [Define Functions:](#18)

-   [Clean Data Function](#19)

-   [Plot Data Function](#20)

-   [User Input Function](#21)

-   [Web API Function](#22)

**Clear All Variables/Command Window/Close Windows**

clc;

clear;

close all;

delete(instrfindall); % Clears any existing serial ports

**Send Data**

% create user\_sendretrieve variable to use for user input in proceeding
code

user\_sendretrieve = \[\];

% create while loop to validate user input and only break out if a valid
value is inputted

while (1)

% ask the user if they want to send or retrieve data

user\_sendretrieve = input('Please enter "send" or "retrieve": ','s');

% create if statement to validate user input and determine next prompt

if strcmp(user\_sendretrieve,'send')

**Open The Serial Port To Connect To The Arduino**

Check the serial port that the Arduino is connected to by: Going to the
Control Panel --&gt; Hardware and Sound --&gt; Devices and Printers and
right click: FT231X USB UART, select Properties and then look under
Hardware Tab

% ask user to type in the serial port connected to Arduino, this will
cause an error

% if an improper port is typed in

user\_port = input('Please enter serial port value (usually either COM4
or other): ','s');

arduino = serial(user\_port,'BaudRate',9600); % Creates a serial
connection via user\_port

**Ask user for how much data to write**

% create points\_or\_time variable to use for user input in proceeding
code

points\_or\_time = \[\];

% assign the variable write\_rate to 20 to be used in calculating the
number of data points to write

% when a specific time is requested to run for, this should be adjusted
if pauses later on are

% changed

write\_rate = 20;

% create while loop to validate user input and only break out if a valid
value is

% inputted

while(1)

% ask the user to type n or t depending on if they want to run for a
certain number of points or a

% certain amount of time

points\_or\_time = input('Input "n" for number of data points, or "t"
for amount of time: ','s');

% create if selection structure to compare to user input of either n or
t

if points\_or\_time == 'n'

% inform the user how fast a data point can be written to ThingSpeak
using this code

disp('Data writes at a rate of about 20 sec each');

% ask the user for how many data points they want to write

data\_points = input('Enter the number of data points you want to write:
');

break % break out of while loop

elseif points\_or\_time == 't'

% inform the user how fast a data point can be written to ThingSpeak
using this code

disp('Data writes at a rate of about 20 sec each');

% ask the user for how long they want to write data

time\_to\_run = input('Enter the number of minutes you want to write
data: ');

% since the write happens before the pause, the data points possible in

% a given time period will include a final data write within the time

% specification and the pause lasting past the time period, hence the "+
1" in code

data\_points = round(time\_to\_run\*60/write\_rate) + 1;

break % break out of while loop

else

% ask the user for valid input

disp('Please enter either n or t')

end % end if statement

end % end while loop

**Send the Serial Data to the IoT (Thingspeak) with a Web API Call**

% assign 'ThingSpeak\_channel' to our groups specific channel on
ThingSpeak

ThingSpeak\_channel = '318597';

% assign 'Write\_API\_Key' to our groups specific write key on
ThingSpeak

Write\_API\_Key = 'SBV3R3WDH1313XMQ';

% create empty matrix to store data points pulled from Arduino

serial\_data = \[\];

% create for loop to cycle for the desired number data points

for i = 1:data\_points

% use fopen function to open the serial line to the arduino

fopen(arduino);

% set the serial port to read in continuous asyncronous mode forcing the
serial buffer to "ask"

% continuously if there's a data available from Arduino, this specific
line is not required to

% pull data from Arduino, but seems to help with receiving fragmented
data

arduino.ReadAsyncMode = 'continuous';

% use fscanf function to read the string data being sent over the serial
line from the Arduino

serial\_read\_str = fscanf(arduino,'%s');

% create if selection structure to handle fragmented serial data sent
from the Arduino and

% prevent run\_time errors

% since the data received is a string in Kelvin with 2 decimal places,
the usable range of the

% thermistor will always be a value with 5 digits and a decimal (ie 6
chars), so anything less

% than 6 chars will close Arduino serial line and continue to next
iteration of for loop

if length(serial\_read\_str) &lt; 6

fclose(arduino);

continue

% if the serial data from the Arduino is 6 chars or longer and not
empty, reassign the last 6

% chars to serial\_read variable, then convert serial\_read to a number,
then convert serial\_read

% from Kelvin to Fahrenheit

% this is required because the serial line often returns a full value
and a partial value, where

% the full value has always been the last 6 characters ('always' is
based on current testing

% amount)

elseif ~isempty(serial\_read\_str)

serial\_read = serial\_read\_str(:,end-5:end);

serial\_read = str2num(serial\_read);

serial\_read = (serial\_read - 273.15) \* (9/5) + 32.00;

% if anything else comes over the serial line (empty matrix), close
Arduino serial line and

% continue to next iteration

% this is required because the serial line often returns an empty matrix
which would otherwise

% cause a run\_time error

else

fclose(arduino);

continue

end

% add the next serial\_read value to the serial\_data matrix

serial\_data(end+1) = serial\_read;

% convert serial\_read value into a formatted string to be used for url

current\_data\_point = num2str(serial\_read,'%8.2f');

% create string variables to store the proper write url location and
proper data write value

% which are concatinated into a single url string value

% the concatinated url may not be required since our function uses the
webwrite(url,data) format

% instead of webwrite(url) format as specified in MATLAB documentation

thingSpeakWriteURL = 'https://api.thingspeak.com/update';

data = \['api\_key=',Write\_API\_Key,'&field1=',current\_data\_point\];

url = \[thingSpeakWriteURL data\];

% create options variable of weboptions object that changes default
Timeout value (5sec) to 10

% seconds

% this is required to prevent run\_time errors while the code attempts
to write the value to

% ThingSpeak and it prematurely timesout, it may need to be longer if
timeout errors occur

options = weboptions('Timeout',10);

% call webrite function with (url,data,options) format to use adjusted
webwrite options and

% store data entry ID into response value

response = webwrite(thingSpeakWriteURL,data,options);

fclose(arduino); % Closes arduino serial channel

% on the first iteration of the write loop, show the user the details of
the ThingSpeak channel,

% key, data point, and data entry ID

if i == 1

% Show the User API Call and IoT Response

disp(\[char(10), 'Using ThingSpeak Channel: ', ThingSpeak\_channel\])

disp(\['Using Write API Key: ', Write\_API\_Key\])

disp(\['Using Data Point: ', current\_data\_point\])

disp(\['Sent API request: ',url\])

pause(2) % Wait 2 seconds for the response, ThingSpeak.com's response is
not instant

disp(\['Request Successful! Data Saved as entry ID: ',response,
char(10)\])

% after the first iteration of the write loop, only display the data
point and the data point ID

else

disp(\[char(10),'Using Data Point: ', current\_data\_point\])

pause(2) % Wait 2 seconds for the response, ThingSpeak.com's response is
not instant

disp(\['Request Successful! Data Saved as entry ID: ',response,
char(10)\])

end % end the if selection structure

pause(15) % wait 15 seconds before attempting to post another value

end % end the for loop

disp('Data Successfully Sent to ThingSpeak IoT!')

**Plots a Nice Graph**

plot\_data\_temp\_sensor(serial\_data);

% save the figure as 'SentData.png', which will overwrite any previous
figures stored so that

% the most current sent data is saved

print('SentData','-dpng');

**Display when finished**

disp('Data collection complete!') % displays when data collection loop
is complete

break % breaks while loop

**Retrieve Data**

elseif strcmp(user\_sendretrieve, 'retrieve')

**Ask user for number of data points to retrieve**

% call user\_input\_temp\_sensor function to prompt the user to enter
the number of data points and

% store in 'data\_points' variable

data\_points = user\_input\_temp\_sensor();

% convert 'data\_points' to a string with num2str function

data\_points\_str = num2str(data\_points);

**Retrieve the Serial Data from the IoT (Thingspeak) with a Web API
Call**

% call web\_api\_temp\_sensor function to pull the amount of requested
data points from Thingspeak and

% store in 'response' variable

response = web\_api\_temp\_sensor(data\_points\_str);

**Clean structure array data into matrix data to be used in plot**

% call clean\_data\_temp\_sensor function to take the 'response' value
and 'data\_points' and clean them

% into a usable matrix form for plotting and store into 'clean\_data'
variable

clean\_data = clean\_data\_temp\_sensor(response, data\_points);

**Show the User API Call and IoT Response**

% assign 'ThingSpeak\_channel' to our groups specific channel on
ThingSpeak

ThingSpeak\_channel = '318597';

% display to the user the channel being used, the data points being
retrieved, the cleaned data

% values, and then pausing for a second

disp(\['Using ThingSpeak Channel: ', ThingSpeak\_channel\])

disp(\['Using Data Point: ', data\_points\_str\])

disp(\['Receive API request: ',num2str(clean\_data')\])

pause(1) % wait 1 second for the response, ThingSpeak.com's response is
not instant

**Plots a Nice Graph**

% call the plot\_data\_temp\_sensor function to take the clean data
points and plot them in a nice

% graph

plot\_data\_temp\_sensor(clean\_data);

% save the figure as 'RetrievedData.png', which will overwrite any
previous figures stored so that

% the most current retrieved data is saved

print('RetrievedData','-dpng');

break % break loop

else

disp('Please re-enter choice') %if choice does not match criteria,
restart loop

end % end if statement

end % end while loop

**Define Functions:**

**Clean Data Function**

function \[ clean\_data \] = clean\_data\_temp\_sensor( response,
data\_points )

%clean\_data\_temp\_sensor This function takes two inputs: a response
from thingspeak.com

%with a structure array and a number of data points also designated by
the user.

%It returns data that's been "cleaned" in a standard verticle matrix
that's easy to plot with.

% The url input requires a very specific structure to access the proper
data that is being

% filtered and cleaned.

% response =
webread('https://api.thingspeak.com/channels/318597/fields/1.json?results=5')

% data\_points = 5;

%

% clean\_data =

% 80.2900

% 78.5300

% 77.7400

% 82.2200

% 79.4800

clean\_data = zeros(1,data\_points)'; % initialize clean\_data matrix
with zeros filled up to num\_results input

for i = 1:data\_points % create for loop to write data points to
increasing indicies in clean\_data matrix

% set clean\_data indicies to a number created by str2num fucntion of
the url\_data structure

% array, by taking the structure array at the corresponding indice using
the field\_str variable

% to call the proper field

clean\_data(i) = str2num(response.feeds(i).field1);

end

end

**Plot Data Function**

function \[\] = plot\_data\_temp\_sensor( clean\_data )

%plot\_data\_temp\_sensor This function plots the inputted clean\_data
points versus

%the data point number.

%

% This function uses several check throughout to determine the best plot

% setup in varying input situations. For example, when only 1 input is

% requested, the format of the plot switches to points of marker size 14
so

% that the data actually shows on the graph. Also, the y limits of the
plot

% adapt to the range of the data, so when the range is 0, the plot
reverts

% to standard y limits.

%

% clean\_data is column vector of data

figure(1) % create figure window

% this if statement is required in the case of a user inputting only 1
data

% value, where the plot must show a dot at that point, in comparison to

% multiple data points where a simple line is used as coded in the else

% portion of the if statement

if numel(clean\_data) == 1

plot(clean\_data,'.','MarkerSize',14)

else

plot(clean\_data)

end

max\_data = round(max(clean\_data),4);% set max\_data to the rounded
max(clean\_data) to prevent comparison issues

min\_data = round(min(clean\_data),4);% set min\_data to the rounded
min(clean\_data) to prevent comparison issues

range = max\_data - min\_data; % calculate range by subtracting
max\_data from min\_data

max\_range = max\_data + .05 \* range; % set max\_range to 5% of range
added to max\_data

min\_range = min\_data - .05 \* range; % set min\_range to 5% of range
subtracted from min\_data

% an if statement is required to check for the case that the range would
be

% 0 and the limits of the y-axis would be impossible

% when the range is 0, standard ylim is used

if range ~= 0

ylim(\[min\_range, max\_range\])

end

% Additions to the graph for reference and identification

xlabel('Data Points'); % x-axis label

ylabel('Temperature (Fahrenheit)'); % y-axis label

title('Temperature'); % Inserts a title to the plot

grid; % Turns on grid

end

**User Input Function**

function \[ data\_points \] = user\_input\_temp\_sensor()

%user\_input\_temp\_sensor This function will validate the user input as
well

%as including error checking to ensure proper inputs are chosen.

%

% Function should be called in the command line like this:

% \*\* data\_points = user\_input\_temp\_sensor()\*\*

% ask the user for the number of data points they would like to see,

% ranging from 1 to 8000

data\_points = input('Enter the desired number of data points (1 to
8000): ');

% create while loop to check for approved number of points inputted and

% ask the user again for an approved number of points if out of range

while ~(data\_points &lt;= 8000 && data\_points &gt;= 1);

data\_points = input('Enter a positive integer less than or equal to
8000: ');

end

% inform user that a valid input was received.

disp(\[num2str(data\_points),' is Valid'\])

end

**Web API Function**

function \[ response \] = web\_api\_temp\_sensor( data\_points\_str )

%web\_api\_temp\_sensor This function pulls data string from the user
input in

%order to find specific data from thingspeak.

% This function will pull the data from the IoT on Thingspeak in order
to

% populate a matrix, based on user\_input, and output that matrix as

% response.

%

% Input: data\_points\_str =&gt; user input on the number of points we
want

% to receive in string format

%

% Output: response =&gt; json file with requested data

ThingSpeak\_channel = '318597';

thingSpeakReadURL = 'https://api.thingspeak.com/channels/';

field\_data = \[ThingSpeak\_channel,
'/fields/1.json?results=',data\_points\_str\];

url = \[thingSpeakReadURL field\_data\];

response = webread(url);

end

*  
*[*Published with MATLAB®
R2017a*](http://www.mathworks.com/products/matlab/)

**Arduino Code:**

// TEMP SENSOR DATA READ

// Project: Temp Sensor group for Arduino Project

// Course: ENGR 114 Summer 2017

// Group Members: Marshall Reed, Jonathan Christian, Andy Graham, Mussie
Bariagabir

// Description: This arduino code takes voltage readings from a
thermistor, converts them to degrees Kelvin using Steinhart equation,

// then prints them to the serial port for reading by MATLAB

//

int thermistorPin = A0; // Initializes pin that the thermistor will be
connected to

double thermistorReading; // Initialize double thermistorReading for
storing thermistor values

double seriesResistor = 9720; // Value of the resistor used - measured
with multimeter

double thermistorNominal = 10790; // Resistance measured at 23.9 degrees
C

double temperatureNominal = 23.9; // Temperature for nominal resistance
value during calibration

double bCoefficient = 3950; // The beta coefficient of the termistor
(usually 3000-4000)

double steinhart; // Initialize double steinhart for calculating
Steinhart-Hart equation

double tempK; // Initialize double tempK for storing thermistor values
converted into Kelvin

double resistance; // Initialize double resistance for storing converted
thermistor value

String strTempK; // Initialize String strTempK for storing tempK value
as a string

void setup()

{

// put your setup code here, to run once:

Serial.begin(9600); // setup serial port to 9600 baud rate

}

void loop()

{

// use analogRead function to read thermistor input and store in
thermistorReading variable

// analogRead function samples at a max rate of 100 microseconds each

thermistorReading = analogRead(thermistorPin);

// convert raw thermistorReading into resistance

// this specific coding conversion comes from the thermistor supplier

resistance = 1023 / thermistorReading - 1;

resistance = seriesResistor / resistance;

// to convert the resistance to a voltage, we need to use the
Steinhart-Hart equation with

// simplified B term (due to lack of known variables)

// This equation is not exact but provides good data for the
temperatures that the thermistor

// is being used for.

// 1/T = 1/To + 1/B\*ln(R/Ro)

steinhart = resistance / thermistorNominal; // (R/Ro)

steinhart = log(steinhart); // ln(R/Ro)

steinhart /= bCoefficient; // 1/B \* ln(R/Ro)

steinhart += 1.0/(temperatureNominal + 273.15); // 1/To + 1/B \*
ln(R/Ro)

steinhart = 1.0 / steinhart; // invert

tempK = steinhart; // steinhart output is Kelvin

strTempK = String(tempK, 2); // convert tempK into a String with two
decimal places

Serial.println(strTempK); // print the Kelvin value

// wait 100 microsceonds or repeat 10x per second (change to modify
sampling rate)

delay(100);

}

#### 

#### 

#### 

#### **Results:**

The results of multiple tests on the system are that the code
successfully took readings, then sent them to the IoT, which was
successfully retrieved by a separate computer. We were able to do
multiple runs of sent data and retrieve that data at any time afterward.
The data was collected at approximately 20 second intervals, and
captured in degrees Fahrenheit.

We were able to make user prompts simple, and simplify and organize a
lot of the code which was given to us. There are certain spots in the
code that, if not entered correctly, do error and result in a breakdown
(such as the entering of the serial port number, as that port number
changes on any computer, and if not entered correctly, there is no
comparison to what it should be).

The data retrieval does plot a graph based of the number of data points
or amount of time specified by the user prompt, and the data taken. It
is always displayed as temperature vs time. The example of 300 points of
data collection in plot follows:

<img src="./media/image4.png" width="377" height="282" />

Issues:

-   Depending on status of the network in use, the state of the
    computer, and several other factors, data sometimes ended up not
    transmitting completely and the sending program needed to be re-run.

-   The calibration of the thermistor was accurate to about +/- 2.0
    degrees of the actual read temperature (taken via hand-held
    digital thermometer) at any given time. The delay in the sent data
    compared to the reading of the temperature could be a factor, but it
    is more likely due to the precision of calibration in which
    we completed. Two degrees is an acceptable variance, and can be
    recalibrated with the utilization of a more accurate thermistor or
    temperature sensor.

We were able to make user prompts simple, and simplify and organize a
lot of the code which was given to us. There are certain spots in the
code that, if not entered correctly, do error and result in a breakdown
(such as the entering of the serial port number, as that port number
changes on any computer, and if not entered correctly, there is no
comparison to what it should be).

The data retrieval does plot a graph based of the number of data points
or amount of time specified by the user prompt, and the data taken. It
is always displayed as temperature vs time. The example of 100 points of
data collection in plot follows:

#### **Future Work:**

A number of future modifications could be made to this project to better
utilize data, and make it more user friendly, such as:

-   Creating the ability to remotely upload data (being able to pull the
    temperatures using an Arduino and internet connection to transmit
    the data points when requested)

-   Temperature data gathering at regular intervals to gather trends of
    temperatures in the tank throughout the day, in order to establish
    routines of turning pumps on/off, lights on/off, or a heater on/off
    at regular times.

-   The integration of the data gathered from the temperature sensor
    with the data from other sensors to better establish trends of the
    ecosystem of the tank, and make adjustments.

-   Monitoring the change in temperature of the water when it is pumped
    into the plant boxes and after it has traveled back to the tank
    could give clues and a segment of data to lead to whether
    adjustments should be made for the method to be more effective.

-   Programming which automatically sends alerts or feedback based on
    certain conditions (e.g. trends, alerts, etc.)

-   Developing code to prompt for data retrieval for certain times of
    day, certain days; specified data from time periods which has been
    stored on the IoT server.

-   Utilization of a proper temperature sensor as opposed to a
    thermistor would yield more accurate results, more
    accurate calibration.

-   **License**

MIT License

Copyright (c) 2017 Temperature Sensor Group (Marshall Reed, Jonathan
Christian, Mussie Bariagabir, Andy Graham)
