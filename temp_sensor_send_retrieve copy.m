%% Arduino Project - Temperature Sensor Send and Retrieve
% * Authors: The Temp Sensor Group
% * Course: ENGR114
% * Date: Sept 5, 2017
% * Description: This script gives the user the option to send data to the IoT at ThingSpeak.org, or
% * retrieve temperature sensor data from ThingSpeak and plot it to a graph.

%%  Clear All Variables/Command Window/Close Windows

clc;
clear; 
close all;
delete(instrfindall);       % Clears any existing serial ports


%% Send Data

% create user_sendretrieve variable to use for user input in proceeding code
user_sendretrieve = []; 
% create while loop to validate user input and only break out if a valid value is inputted
while (1)
    % ask the user if they want to send or retrieve data
    user_sendretrieve = input('Please enter "send" or "retrieve":  ','s');
    % create if statement to validate user input and determine next prompt
    if strcmp(user_sendretrieve,'send')
 
                %% Open The Serial Port To Connect To The Arduino
                % Check the serial port that the Arduino is connected to by:
                % Going to the Control Panel --> Hardware and Sound --> Devices and Printers
                % and right click: FT231X USB UART, select Properties and then look under
                % Hardware Tab

                % ask user to type in the serial port connected to Arduino, this will cause an error
                % if an improper port is typed in
                user_port = input('Please enter serial port value (usually either COM4 or other):  ','s');
                arduino = serial(user_port,'BaudRate',9600);    % Creates a serial connection via user_port

                %% Ask user for how much data to write
                
                % create points_or_time variable to use for user input in proceeding code
                points_or_time = []; 
                % assign the variable write_rate to 20 to be used in calculating the number of data points to write
                % when a specific time is requested to run for, this should be adjusted if pauses later on are
                % changed
                write_rate = 20;
                % create while loop to validate user input and only break out if a valid value is
                % inputted
                while(1)                                                                            
                % ask the user to type n or t depending on if they want to run for a certain number of points or a
                % certain amount of time
                points_or_time = input('Input "n" for number of data points, or "t" for amount of time: ','s');  
                    % create if selection structure to compare to user input of either n or t
                    if points_or_time == 'n' 
                        % inform the user how fast a data point can be written to ThingSpeak using this code                                                                            
                        disp('Data writes at a rate of about 20 sec each');
                        % ask the user for how many data points they want to write
                        data_points = input('Enter the number of data points you want to write: '); 
                        break                       % break out of while loop                                              
                    elseif points_or_time == 't' 
                        % inform the user how fast a data point can be written to ThingSpeak using this code                                                                            
                        disp('Data writes at a rate of about 20 sec each');
                        % ask the user for how long they want to write data
                        time_to_run = input('Enter the number of minutes you want to write data: '); 
                        % since the write happens before the pause, the data points possible in
                        % a given time period will include a final data write within the time
                        % specification and the pause lasting past the time period, hence the "+ 1" in code
                        data_points = round(time_to_run*60/write_rate) + 1;  
                        break                       % break out of while loop                                                 
                    else  
                        % ask the user for valid input
                        disp('Please enter either n or t')
                    end                             % end if statement                             
                end                                 % end while loop                                     

                %% Send the Serial Data to the IoT (Thingspeak) with a Web API Call

                % assign 'ThingSpeak_channel' to our groups specific channel on ThingSpeak
                ThingSpeak_channel = '318597'; 
                % assign 'Write_API_Key' to our groups specific write key on ThingSpeak
                Write_API_Key = 'SBV3R3WDH1313XMQ';

                % create empty matrix to store data points pulled from Arduino
                serial_data = [];
                % create for loop to cycle for the desired number data points
                for i = 1:data_points 
                    % use fopen function to open the serial line to the arduino
                    fopen(arduino);
                    % set the serial port to read in continuous asyncronous mode forcing the serial buffer to "ask"
                    % continuously if there's a data available from Arduino, this specific line is not required to
                    % pull data from Arduino, but seems to help with receiving fragmented data
                    arduino.ReadAsyncMode = 'continuous';
                    % use fscanf function to read the string data being sent over the serial line from the Arduino
                    serial_read_str = fscanf(arduino,'%s');
    
                    % create if selection structure to handle fragmented serial data sent from the Arduino and
                    % prevent run_time errors
                    % since the data received is a string in Kelvin with 2 decimal places, the usable range of the
                    % thermistor will always be a value with 5 digits and a decimal (ie 6 chars), so anything less
                    % than 6 chars will close Arduino serial line and continue to next iteration of for loop
                    if length(serial_read_str) < 6
                        fclose(arduino);
                        continue
                    % if the serial data from the Arduino is 6 chars or longer and not empty, reassign the last 6 
                    % chars to serial_read variable, then convert serial_read to a number, then convert serial_read 
                    % from Kelvin to Fahrenheit
                    % this is required because the serial line often returns a full value and a partial value, where
                    % the full value has always been the last 6 characters ('always' is based on current testing
                    % amount)
                    elseif  ~isempty(serial_read_str) 
                        serial_read = serial_read_str(:,end-5:end);
                        serial_read = str2num(serial_read);
                        serial_read = (serial_read - 273.15) * (9/5) + 32.00;
                    % if anything else comes over the serial line (empty matrix), close Arduino serial line and
                    % continue to next iteration
                    % this is required because the serial line often returns an empty matrix which would otherwise
                    % cause a run_time error
                    else
                        fclose(arduino);
                        continue
                    end
    
                    % add the next serial_read value to the serial_data matrix
                    serial_data(end+1) = serial_read;
                    % convert serial_read value into a formatted string to be used for url
                    current_data_point = num2str(serial_read,'%8.2f');
    
                    % create string variables to store the proper write url location and proper data write value
                    % which are concatinated into a single url string value
                    % the concatinated url may not be required since our function uses the webwrite(url,data) format
                    % instead of webwrite(url) format as specified in MATLAB documentation
                    thingSpeakWriteURL = 'https://api.thingspeak.com/update'; 
                    data = ['api_key=',Write_API_Key,'&field1=',current_data_point];
                    url = [thingSpeakWriteURL data];
                    % create options variable of weboptions object that changes default Timeout value (5sec) to 10
                    % seconds
                    % this is required to prevent run_time errors while the code attempts to write the value to
                    % ThingSpeak and it prematurely timesout, it may need to be longer if timeout errors occur
                    options = weboptions('Timeout',10);
                    % call webrite function with (url,data,options) format to use adjusted webwrite options and
                    % store data entry ID into response value
                    response = webwrite(thingSpeakWriteURL,data,options);
    
                    fclose(arduino);                    % Closes arduino serial channel

                    % on the first iteration of the write loop, show the user the details of the ThingSpeak channel,
                    % key, data point, and data entry ID
                    if i == 1
                        % Show the User API Call and IoT Response
                        disp([char(10), 'Using ThingSpeak Channel: ', ThingSpeak_channel])
                        disp(['Using Write API Key: ', Write_API_Key])
                        disp(['Using Data Point: ', current_data_point])
                        disp(['Sent API request: ',url])
                        pause(2) % Wait 2 seconds for the response, ThingSpeak.com's response is not instant
                        disp(['Request Successful! Data Saved as entry ID: ',response, char(10)])
                    % after the first iteration of the write loop, only display the data point and the data point ID
                    else 
                        disp([char(10),'Using Data Point: ', current_data_point])
                        pause(2) % Wait 2 seconds for the response, ThingSpeak.com's response is not instant
                        disp(['Request Successful! Data Saved as entry ID: ',response, char(10)])
    
                    end                                 % end the if selection structure
                    pause(15)                           % wait 15 seconds before attempting to post another value
                end                                     % end the for loop

                disp('Data Successfully Sent to ThingSpeak IoT!')

                %% Plots a Nice Graph

                plot_data_temp_sensor(serial_data);
                
                % save the figure as 'SentData.png', which will overwrite any previous figures stored so that
                % the most current sent data is saved
                print('SentData','-dpng');

                %% Display when finished

                disp('Data collection complete!')       % displays when data collection loop is complete

      break                                             % breaks while loop
%% Retrieve Data

    elseif strcmp(user_sendretrieve, 'retrieve')
    
            %% Ask user for number of data points to retrieve
            
            % call user_input_temp_sensor function to prompt the user to enter the number of data points and
            % store in 'data_points' variable
            data_points = user_input_temp_sensor(); 
            % convert 'data_points' to a string with num2str function
            data_points_str = num2str(data_points);

            %% Retrieve the Serial Data from the IoT (Thingspeak) with a Web API Call
            
            % call web_api_temp_sensor function to pull the amount of requested data points from Thingspeak and
            % store in 'response' variable
            response = web_api_temp_sensor(data_points_str);

            %% Clean structure array data into matrix data to be used in plot
            
            % call clean_data_temp_sensor function to take the 'response' value and 'data_points' and clean them
            % into a usable matrix form for plotting and store into 'clean_data' variable
            clean_data = clean_data_temp_sensor(response, data_points);


            %% Show the User API Call and IoT Response
            
            % assign 'ThingSpeak_channel' to our groups specific channel on ThingSpeak
            ThingSpeak_channel = '318597'; 
            
            % display to the user the channel being used, the data points being retrieved, the cleaned data
            % values, and then pausing for a second
            disp(['Using ThingSpeak Channel: ', ThingSpeak_channel]) 
            disp(['Using Data Point: ', data_points_str])
            disp(['Receive API request: ',num2str(clean_data')])
            pause(1) % wait 1 second for the response, ThingSpeak.com's response is not instant

            %% Plots a Nice Graph
            
            % call the plot_data_temp_sensor function to take the clean data points and plot them in a nice
            % graph
            plot_data_temp_sensor(clean_data);
            
            % save the figure as 'RetrievedData.png', which will overwrite any previous figures stored so that
            % the most current retrieved data is saved
            print('RetrievedData','-dpng');

            break   %  break loop
    else
        disp('Please re-enter choice')      %if choice does not match criteria, restart loop
        
    end             % end if statement
end                 % end while loop



%% Define Functions:
        %%  Clean Data Function

        function [ clean_data ] = clean_data_temp_sensor( response, data_points )
        %clean_data_temp_sensor This function takes two inputs: a response from thingspeak.com 
        %with a structure array and a number of data points also designated by the user.
        %It returns data that's been "cleaned" in a standard verticle matrix that's easy to plot with.
        %   The url input requires a very specific structure to access the proper data that is being
        %   filtered and cleaned. 

        %   response = webread('https://api.thingspeak.com/channels/318597/fields/1.json?results=5')
        %   data_points = 5;
        %   
        %   clean_data =    
        %                   80.2900
        %                   78.5300
        %                   77.7400
        %                   82.2200
        %                   79.4800

        clean_data = zeros(1,data_points)';         % initialize clean_data matrix with zeros filled up to num_results input
        for i = 1:data_points                       % create for loop to write data points to increasing indicies in clean_data matrix
            % set clean_data indicies to a number created by str2num fucntion of the url_data structure
            % array, by taking the structure array at the corresponding indice using the field_str variable
            % to call the proper field
            clean_data(i) = str2num(response.feeds(i).field1);
        end

        end

        %% Plot Data Function

        function [] = plot_data_temp_sensor( clean_data )
        %plot_data_temp_sensor This function plots the inputted clean_data points versus
        %the data point number.
        % 
        % This function uses several check throughout to determine the best plot
        % setup in varying input situations. For example, when only 1 input is
        % requested, the format of the plot switches to points of marker size 14 so
        % that the data actually shows on the graph. Also, the y limits of the plot
        % adapt to the range of the data, so when the range is 0, the plot reverts
        % to standard y limits.
        %
        % clean_data is column vector of data

        figure(1)                           % create figure window

        % this if statement is required in the case of a user inputting only 1 data
        % value, where the plot must show a dot at that point, in comparison to
        % multiple data points where a simple line is used as coded in the else
        % portion of the if statement
        if numel(clean_data) == 1
            plot(clean_data,'.','MarkerSize',14)
        else
            plot(clean_data)
        end

        max_data = round(max(clean_data),4);% set max_data to the rounded max(clean_data) to prevent comparison issues
        min_data = round(min(clean_data),4);% set min_data to the rounded min(clean_data) to prevent comparison issues
        range = max_data - min_data;        % calculate range by subtracting max_data from min_data
        max_range = max_data + .05 * range; % set max_range to 5% of range added to max_data
        min_range = min_data - .05 * range; % set min_range to 5% of range subtracted from min_data

        % an if statement is required to check for the case that the range would be 
        % 0 and the limits of the y-axis would be impossible
        % when the range is 0, standard ylim is used
        if range ~= 0   
            ylim([min_range, max_range])    
        end

        % Additions to the graph for reference and identification
        xlabel('Data Points');              % x-axis label
        ylabel('Temperature (Fahrenheit)'); % y-axis label
        title('Temperature');               % Inserts a title to the plot
        grid;                               % Turns on grid

        end

        %% User Input Function

         function [ data_points ] = user_input_temp_sensor()
        %user_input_temp_sensor This function will validate the user input as well 
        %as including error checking to ensure proper inputs are chosen.
        %
        % Function should be called in the command line like this: 
        %                   ** data_points = user_input_temp_sensor()**

        % ask the user for the number of data points they would like to see,
        % ranging from 1 to 8000
        data_points = input('Enter the desired number of data points (1 to 8000): ');

        % create while loop to check for approved number of points inputted and
        % ask the user again for an approved number of points if out of range
        while ~(data_points <= 8000 && data_points >= 1);
            data_points = input('Enter a positive integer less than or equal to 8000: ');
        end

        % inform user that a valid input was received.
        disp([num2str(data_points),' is Valid'])

         end

        %% Web API Function

         function [ response ] = web_api_temp_sensor( data_points_str )
        %web_api_temp_sensor This function pulls data string from the user input in  
        %order to find specific data from thingspeak.

        %   This function will pull the data from the IoT on Thingspeak in order to
        %   populate a matrix, based on user_input, and output that matrix as
        %   response.
        %
        % Input:  data_points_str    => user input on the number of points we want
        %                                       to receive in string format
        %
        % Output: response        => json file with requested data

        ThingSpeak_channel = '318597';         

        thingSpeakReadURL = 'https://api.thingspeak.com/channels/'; 
        field_data = [ThingSpeak_channel, '/fields/1.json?results=',data_points_str]; 
        url = [thingSpeakReadURL field_data];
        response = webread(url);

        end
