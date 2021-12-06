# DESIGN.md #

Route360
Author: < Glen Liu and Joshua Halberstadt >
Created: < November 20, 2021 >

## Implementation ##
Our app was implemented in the Xcode IDE using the language Swift. From a high-level perspective, we made heavy use of the Swift framework "MapKit" which allowed us to add our broad range of functionality, from finding a location through a search bar or determining user distance. We also built our app on top of the traditional framework of "UIKit," utilizing certain objects like "UILabel", "UIImage", and "UIColor."

### View Controllers ###
In terms of our UI, we have three view controllers, which are essentially different screens that can come up in the app. 
ViewController is the main view controller. It houses the map interface complete with a navigation controller that features a couple of navigation items, including the info circle and the location fill. This is where the user will find his location, where they can read more about the app, or search for another location. 
SecondController is what is shown when the user taps the i button in the navigationController. It details instructions for how to use the app. 
Lastly, LocationSearchTable is a UITableViewController which holds search results. So, when the user begins typing in the search bar in ViewController, LocationSearchTable will return possible matches of places. The user can then select one to place an annotation at that location. 

### Classes ###
Aside from our view controllers, we have one main class: StartPoint, which, most importantly, extends from the MKAnnotation class. StartPoint has a couple of attributes, namely title, coordinate, and distance. Notice that coordinate is a special CLLocationCoordinate2D object, which itself has its own properties like longitude and latitude. 
The rest of the classes, i.e AppDelegate and SceneDelegate, all come pre-coded with the initial package of an Xcode project. They provide internal communication within the app, but because they aren't necessary towards understanding our code, I'll omit discussing them. 

### The Code ###
Our code frequently uses an object called an "annotation", which is specifically an MKAnnotation object. Broadly speaking, annotations hold data that you want to display on the UI of the map. What we'll frequently do in our code is create an annotation and then type-cast it as an object of the class "StartPoint." Further, it's important to note that because StartPoints extend from the MKAnnotation class, we are able to pass in a StartPoint object as a parameter for a function that usually takes in an MKAnnotation object. On the flip side, you will also see us check that an MKAnnotation is a StartPoint before performing some function because the only annotations we want to see on the map are StartPoints from where the user can draw routes. 

### Important Functions Explained ###
submit() is an example of method overloading, in that we have multiple functions with the name submit(), however, they each take in different parameters. That being said, submit is always run when the user clicks some sort of "Done" button in order to begin finding routes from a location, whether that location be the user's current one or a different StartPoint. Then, the computer will always do two things: it will first delete all old annotations (excluding the user's icon that indicates his current location) and overlays (which are routes drawn), and then it will add a new annotation (either from the user's current location or a different StartPoint) and call findRoutes().
findRoutes() is the function that finds a loop from and to a certain location. It is the bulk of our app and is explained below.

### findRoutes() - Route-drawing Algorithm ###
Our current algorithm for determining a loop is quite simple. Given a distance d, we find a marker d/4 away, find another marker d/4 away from that one, find a last one d/4 away, then find a route back to the original StartPoint. In effect, we are drawing a rectangle, where the difference in coordinates from one consecutive marker to another is either a change in longitude coordinates equal to d/4 or a change in latitude coordinates equal to d/4. 
Note:
     69 miles in y direction is 1 degree latitude
     54.6 miles in x direction is 1 degree longitude
     
### Other functions ###
A cursory look through our code will tell you that there are many other functions that I have chosen not to discuss here. Most likely, the reason I'm not discussing it is because the function's usage is easily understood either by looking at its name and formal parameters or by taking a quick look at the code and following it intuitively. 
