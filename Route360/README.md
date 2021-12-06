Route360 README file:

This project is written using the language Swift. The code should be compiled using Xcode 13.0 or later on macOS. A short video presentation of the app can be found here: https://youtu.be/Tc40LsJ3bLI. In order to get the code running, follow these steps.

Compilation:
    1. Ensure you are on macOS Big Sur 11.3 or later.
    2. Install Xcode v13.0 or later via the App Store.
    3. Unzip the Route360 project file.
    4. Double-click file "Route360.xcodeproj".
        a. If prompted select "Trust & Open" and then the project will open in Xcode.
        b. The project file also contains all of the configurations that are needed for running the project in the simulator.



Running Route360 in a Simulator:
    1. Ensure Xcode is running and the project "Route360.xcodeproj" is open.
    2. In the menu bar select Product -> Destination -> iPhone 12 Pro Max (Or any other iOS 15 compatible iPhone).
    3. In the menu bar select Product -> Run.
        a. This will open the iOS simulator app and run the code.
    4. In the simulator, when prompted select "allow while using app" to enable location services.
    5. By default the location of the simulator should be set to Harvard University per the .gpx file attached to the project.
        a. If the location of the simulator is not Harvard University, try rerunning the program 1-3 more times by selecting Product -> Run (and selecting "Replace" when prompted)
        a. In order to change the spoofed location, in the menu bar, select Debug -> Simulate Location -> Select City.
            i. Be aware that if you want to simulate locations other than Harvard University you will need to change this attribute each time the code is run, or change the project scheme setting as described in step 9 of running the app on your iPhone.
        b. When running the app on your own iPhone, the app will use built-in GPS (instructions below).
       
 
        
Running Route360 on your iPhone (more difficult):
    1. Ensure Xcode is running and the project "Route360.xcodeproj" is open.
    2. Plug iPhone into your Mac.
    3. Unlock your iPhone and if needed trust the computer.
    4. With Xcode open, in the menu bar, select Product -> Destination -> Name of iPhone.
    5. Now in the Xcode file viewer select the root folder for the project (it has a blue icon next to it).
    6. Using the tabs at the top of the window select "Signing & Capabilities" to the right of "General".
    7. Select a "Personal Team".
        a. If no team is listed, select "Add an Account" and sign in using your Apple ID. Then select the newly created Personal Team.
    8. Now on the same page choose a "Bundle Identifier".
        a. This can be any phrase that has not been taken yet (e.g. Lastname-Route360). Then press the return key to confirm it is valid.
    9. Now select Product -> Scheme -> Edit Scheme.
        a. On the prompt that comes up select the "Run" tab on the left and the "Options" tab in the center. Then set the "Default Location" to None.
                i. This will ensure that the app uses the onboard GPS of your phone instead of the spoofed GPS location used by the simulator.
    10. Now in the menu bar select Product -> Run
    11. When prompted on your Mac, enter you password and select "Always Allow"
    12. If a prompt comes up on your iPhone regarding an unknown developer select Cancel. In Xcode a warning will pop up as well, this can be dismissed. 
    13. On your iPhone, go to the Settings app and select General -> VPN & Device Management. Select the listing that starts with "Apple Development:". Now tap Trust and confirm if necessary.
    14. Now go back to Xcode and in the menu bar select Product -> Run.
        a. After a few moments, the app Route360 will install and launch on your iPhone.
  
  
        
How to Use Route360:

Route360 is an app designed to generate a running route of a specified distance using either your current location or a desired starting location. This section will be broken into categories by functionality. We will work our way from left to right across the UI and end with a few general comments.

1. Generate Running Route from Current Location:
    a. Select the location arrow in the top left of the UI.
    b. Enter a distance (in miles) that you would like to run (decimals can be used as well).
    c. Select "Done".
        i. The app will then generate a running loop of a specified distance.
        ii. You may need to zoom out to see the entire route (in the simulator use the option key to facilitate zooming).
    d. The app will also drop a pin at your current location so that you know where you started.
    
    
2. Generate Running Route from Other Location:
    a. Select the search bar at the top center of the UI.
    b. Search for a location where you would like to start.
        i. The suggested results are based on the field of view displayed on the map. Zoom in for more accuracy.
        ii. Note the addresses listed under items to ensure you find the correct location.
    c. Select a location in the list.
    d. Now enter a distance (in miles) that you would like to run (decimals can be used as well).
    e. Select "Done".
        i. The app will then generate a running loop of a specified distance.
        ii. You may need to zoom out to see the entire route (in the simulator use the option key to facilitate zooming).
    f. The app will also drop a pin at the starting location so that you know where to start.
    
    
3. Extra Functionality:
    a. Information Page:
        i. At any point you can select the information icon in the top right of the UI. This will bring up a short summary of how to use Route360.
        ii. When you are done, you can either select done in the top right or simply swipe the page down.
        
    b. See Pin Details:
        i. Once a pin has been dropped on the map by the route finder, you can select that pin at any time.
        ii. The pin will display either "Current Location" or the name of the starting point.
        iii. You can also select the information button next to the name of the pin to see the latitude and longitude of that point on the earth.
            1. Select "Done" to close the pin location details.
        
    c. Set Map Tracking Mode:
        i. The map has three modes for tracking a device. These modes can be toggled using the tracking button in the top right of the UI directly below the information button. The three modes are as follow:
            1. Follow Mode: The tracking button is filled in (this mode is configured on app launch). Follow mode means that the map will keep the blue "Current Location" dot in the center of the screen (and thus the map will 'follow' the user).
            2. Follow With Heading Mode: The tracking button is pointing directly up with a line above it. Follow with heading mode means that the map will follow the user, but will also rotate based on whichever way the iPhone is pointing. This mode uses compass data to rotate the map and track the user's heading.
            3. Trailing Mode: The tracking button just shows an outline. Trailing mode disconnects the map from the user's current location. The map will not move with the user, it will only move by hand.
    
    d. Dark Mode:
        i. The app nicely supports light and dark mode by adapting the color of the UI to match the mode.
        ii. To change the appearance of the device in the simulator:
            1. Go to the home screen. Select the Settings app (on the first page of apps). Scroll down and select "Developer". Toggle "Dark Appearance" on or off.
        iii. To change the appearance of the UI on an iPhone:
            1. Go to the home screen. Open the Settings app. Select "Display & Brightness". Under appearance choose light or dark.
            
            
4. Anticipated Questions:
    a. How do I compile and run this code on a Windows machine?
        i. Unfortunately, iOS apps written in Swift do not easily run on any Windows IDE. We recommend finding a colleague who would be willing to let you borrow a Mac in order to run and test the code in Xcode using MacOS.
        
    b. Will the app accidentally make me run on a highway?
        i. Ideally, No. The routing algorithm constrains the routes to use roads and paths suitable for walking.
        
    c. Why are the suggested search results bad?
        i. First, make sure that the map is zoomed relatively close to the location you wish to search. The searching API finds recommendations based on the part of the map displayed on the screen.
        ii. Second, the searching API is given by Apple. Sometimes it just does not do a good job finding results.
        
    d. What if there are no possible loops around?
        i. If there is a lack of roads (say you are in the countryside), the app will navigate the user on a route the includes running on the same terrain twice. This is even true of some regular routes when it is necessary to add a little bit of extra distance to make the loop the correct distance.
        
    e. Can I get turn-by-turn directions?
        i. Unfortunately, this is not a functionality of Route360 yet.
