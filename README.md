# Interactive Music Shell (IMS)
<HTML> https://github.com/WhiteShorthair/ims.git

## Objectives
In this project, implementing interactive music shell which requests user's input and output the results about artist and track's information and store added artist and track's information into ruby build-in database file.

## Design Detail
In the implementation, divide interactive data process into three parts.
1. ims.rb:
* The main class in IMS which provides UI and request user to input a command.
* Then pass the user's input to interpreter.
2. interpreter.rb: 
* Interpret user's input passed from ims.rb. 
* Parse the input and interpret to corresponding command using a keyword-command hash table.
* Pass the parsed command to processor.rb and process the command with database file.
3. processor.rb: 
* Parse the command and check whether it is valid as input format defined.
* Parse the command into details and access database file to check if input data is valid. (example if inputed artist or track already exits in database)
* Process data and store the data to database file when necessary.
* Output message after processing.

## Functions
* Help - display available commands
* Exit - save state of artist and track then exit
* Info - display a high level summary of the state
* Info track [track id] - display info about a certain track by number
* Info artist [artist id] - display info about a certain artist, by id
* Add Artist [artist name] - add a new artist to storage. e.g. add artist john osborne
* Add Track [track name] by [artist name] - add a new track to storage. e.g. add track watching the sky turn green by jo
* Play Track [track number] - record that an existing track was played at the current time. e.g. play track 13
* Count tracks by [artist id] - display how many tracks are known by a certain artist. e.g. count tracks by jo
* List tracks by [artist id] - display the tracks played by a certain artist. e.g. list tracks by jo

## Some interesting design
1. **Extract information from input use both keyword-command table and regular expression**<br>
For user can input more flexibly, in this implementation, I used regular expression to parse user input. However regular expression may be more complexity than general parsing, firstly parse input into command category by first keyword using parsing then extract information using regular expression for further process.

2. **Generating artist ID**<br>
In this application, artist id is a shortcut of inputting artist name which DJ can access to certain artist quickly. Thus, in this application, the rule to generate artist ID is extract initials of artist first name and last name. If there is another exists in database with the same artist ID, add sequencing number from 1 after abbreviation of artist name.

3. **Message**<br>
Since this is an interactive application, when user inputs an invalid input, application should let user know why the input is invalid. Thus, in my implementation, in each step, the error messages are diverse.<br>
* If user input invalid format, the interpreter.rb will return a message with correct format.
* If use input an not existing track or artist, the processor.rb will return a message notifying user that the track and artist not existing in database.<br>
<br>
Also, after each process, the result with new added track and artist ID and other process results will be shown in message.


