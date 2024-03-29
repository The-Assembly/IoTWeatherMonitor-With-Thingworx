Work In Progress

# IoTWeatherMonitor-With-Thingworx
Oct 12th @ in5 - Hands-on Internet Of Things workshop with Etisalat Digital &amp; PTC. At this session, we’ll take you step by step over the process of creating a modular IoT solution using the Etisalat Thingworx Platform to monitor weather conditions at various locations. We’ll show you how to sync data from edge devices and sensors onto the cloud in real time, model this data to fit business use cases and present it over the web using the platform’s easy-to-use UI building tools.

# Summary of steps
(Watch the live stream on http://www.facebook.com/makesmartthings)

## Pre-steps
  1. Install Thingworx Academic Simulator
  2. Install Postman 
  
## Get started on the Thingworx console
	1. Open up your web browser & navigate to http://<server IP Address>:<server port>/Thingworx/Composer/
	2. Set ProjectContext to 'AssemblyUsers'
	3. Create a new Application Key bound to your username and store the KeyID in a safe place
	4. Create a new Thing Template called WeatherStationTemplate_<userid> (eg; WeatherSystemTemplate_01) with base template GenericThing & two numeric properties - Humidity & Temperature - & a string property Status
  5. Create a new Thing called WeatherStation_<userid> with base template WeatherStationTemplate_<userid> (created in previous step)
  6. Create a Subscription in WeatherStation_<userid> to update Status based on Temperature value
    a. In Subscription Info - Check on 'Enabled' and specify Source as 'Me'
    b. In Inputs select Event as 'DataChange' & Property as 'Temperature'
    c. In the code area - enter the following code
        if (eventData.newValue.value > 30)
	  		  me.Status = "It's Hot!";
		    else
			    me.Status = "OK";
  7.  Create an Alert in WeatherStation_<userid>
    a. Under Properties & Alerts, select the Alerts tab and click Add
    b. Select the Property as 'Temperature' & Alert Type as 'Above' & Limit as '30'
	8. Test out the REST Api to access these properties by sending the following HTTP request on Postman
			http://<server IP Address>:<server port>/Thingworx/Things/WeatherStation_01/properties/Temperature
			HTTP Headers - appKey: <keyid> , Content-Type: application/json
			
## Build your mashup
	Mashup is a web application built on the Thingworx platform - drag and drop - no coding needed
	1. Create a new mashup called SmartHomeDashboard_<userid>
	2. Add labels and shapes for LED & Lock properties
	3. In the Data tab, add SmartHomeSystem_<userid> object & the GetPropertyValues function - select MashupLoaded
	4. Drag GetPropertyValues->AllData->LED and drop on the LED Shape->Data property to bind function.  Do the same for Lock.
	5. Add Autorefresh widget - bind Refresh to GetPropertyValues (to refresh on a timer)
	6. Create a new State definition called OnOffState_<userid> - add 2 values - 'true' & 'false' and set Display Value to 'ON' & 'OFF'.  Set 'ON' to a style with a green background color and 'OFF' to one with a red background color.
	7. Add the State Definition to state formatting for the two shapes in the mashup for LED and Lock

## Create a file repository
	1. Create a new Thing called FileRepo_<userid> with base template FileRepository
	2. Add a FileUpload widget to your mashup
	3. Run the mashup and use the widget to upload an image file called 'Camera.jpg' to your repository
	4. From FileRepo_<userid> - run the GetFileListingWithLinks service to view your file's details
	5. Delete the FileUpload widget from the mashup

## Display your uploaded file in your mashup
	1. Add a Value Display widget to your mashup
	2. In the Data tab, add FileRepo_<userid>->LoadImage service, select MashupLoaded
	3. Add 'Camera.jpg' for the path parameter for LoadImage
	4. Bind LoadImage->Content to Value Display->Data 

## Configure EMS on Raspberry Pi
	1. In microserver directory - edit config.json with IP Address& port of server and AppKey. Also specify HTTP server settings as 127.0.0.1 and give a port number for that as well (eg; 8000, 8080, 8084).
	2. Start wsems.exe
	3. Try CURL on Pi with HTTP request (as done earlier) - instead of specifying the server IP Address, specify the local EMS HTTP server address - you can leave out the AppKey header this time (Test commands listed in Misc/curlcommands.txt)

## Transfer files to Thingworx repository using EMS
	1. Add autobind parameters for SmartHomeSystem_<userid> in config.json - specify HTTP server port
	2. Create a directory under the microserver folder on the Pi called 'images'
	3. Add 'images' as a virtual directory in config.json
			"auto_bind": [{"name": "SmartHomeSystem_01", "port": 8080}],
			"file": {"virtual_dirs": [{"images": "images"}]}
	4. Copy an image called 'Camera.jpg' to the images folder
	5. Restart wsems
	6. In the Thingworx console, open SmartHomeSystem_<userid> and see if it is listed as connected (green icon in top left corner)
	7. Search for & open the built-in FileTransferSubsystem thing in the console
	8. Call the Copy service from FileTransferSubsystem - set targetRepo='FileRepo_<userid>', targetFile = 'Camera.jpg', targetPath = "/", sourceRepo = 'SmartHomeSystem_<userid>", sourcePath = 'images', sourceFile = 'Camera.jpg'
	9. Run GetFileListing service on FileRepo_<userid> thing to see that file copied

## Connect Pi camera, lock and LED 

![Circuit Diagram](https://user-images.githubusercontent.com/32713072/70834753-9834d580-1e14-11ea-85be-c6c02cd0c4fb.jpg) 

<p align="center"> <b> Circuit Diagram </b> </p>

<br/>

![connect-camera](https://user-images.githubusercontent.com/32713072/70834999-34f77300-1e15-11ea-8ed5-6690bb2ac3b7.gif)

<p align="center"> <b> Camera Connection </b> </p>

<br/>


## Run Python Code for functions on Pi (to be added>

## Bind SmartHomeSystem thing using LUAScriptResource
	1. Edit config.lua, add
			scripts.SmartHomeSystem_01 = {
	  	  file = "thing.lua",
  	  	template = "SmartHomeTemplate"
			}
	2. Add SmartHomeTemplate.lua to microserver directory/etc/custom/templates
	3. Run luaScriptResource.exe in the microserver directory
	
## Bind Edge Virtual Thing to Thingworx Remote Thing
	1. In console, delete LED, lock properties in SmartHomeSystem_<userid> Thing
	2. In properties, select Manage Bindings, add LED, Lock & Timestamp properties
	3. In services, select Browse Remote Services, add CaptureImage, ToggleLED, ToggleLock, UpdateLedandLock functions - test them out in console to see if they work with Pi

## Modify mashup to use bound Remote Thing functionality
	1. In Data tab, add CaptureImage, ToggleLED, ToggleLock, UpdateLedandLock from SmartHomeSystem_<userid>, select MashupLoaded only for UpdateLedandLock
	2. Bind UpdateLedandLock to Auto-refresh
	3. Bind UpdateLedandLock->ServiceInvokeCompleted to GetPropertyValues (remove GetPropertyValues connection to Refresh)
	4. Add buttons for toggling LED & lock, bind Clicked to ToggleLED & ToggleLock functions
	5. Bind ToggleLock & ToggleLED ->ServiceInvokeCompleted to GetPropertyValues
	6. Add timestamp label, bind to All Data->Timestamp from GetPropertyValues
	7. In Data tab, add FileSubSystem->Copy service (with same parameters as above)
	8. Bind CaptureImage->ServiceInvokeCompleted to the Copy service
	9. Bind Copy->ServiceInvokeCompleted to LoadImage
	10. Bind LoadImage->ServiceInvokeCompleted to GetPropertyValues (to retrieve timestamp)

