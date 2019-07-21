# JourneyTracker

    This app allow the user to enable/disable the track me option which is used to track the user location.
    
    
# Workflow 

     This app contains the tabbar controller with 2 tabs one for tracking and other for listing and view the history
     
   # tracking screen
   
     It contains the mapview and track me switch, based on the track me switch action the app will work.
     
     For ON state the app track the user location and draw the route and save the value in the keychain to continue tracking the location and the reason for adding the in keychain is to hold the data till the phone resarted. SO the app will track the location if the user delete the app and install it again.
     
     For OFF state the app stope tracking the location and zoom to user location.
   
   # History Screen
   
     It contains the data are shown from the keychain it contains the From & To location, Start & End date & time, duration and location.
     
     When the user tab on the particular item it takes to the map screen to display the route & point.
     
    
