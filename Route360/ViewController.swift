//
//  ViewController.swift
//  Route360
//
//  Created by Glen Liu and Joshua Halberstadt on 11/20/21.
//

import UIKit
import MapKit
import CoreLocation

// used to define the functions used in handling map search
protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

// Used to convert Strings to Doubles
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
     }
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        addMapTrackingButton()
        title = "Route360"
        navigationItems()
        configureSearchTable()
    }
    
    // Whenever the view is on screen determine current location
    override func viewDidAppear(_ animated: Bool) {
        determineCurrentLocation()
    }
    
    func configureSearchTable() {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        
        // creates searchbar in the top navigation bar
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        // format searchbar to fit correctly and have correct placeholder
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Find Starting Point"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        // gives the search table access to the current location of the map
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    // navigation buttons in the navigation bar
    private func navigationItems() {
        navigationController?.navigationBar.tintColor = .label
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "info.circle"),
                style: .done,
                target: self,
                action: #selector(infoButtonTapped)
            )
        ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "location.fill"),
            style: .done,
            target: self,
            action: #selector(startCurrentLocation)
        )
    }
    
    // when info button is selected brings up secondary view controller with instructions for app use
    @objc func infoButtonTapped(_ sender: Any) {
        // instantiate SecondContoller from storyboard
        let story = UIStoryboard(name: "Main", bundle: nil)
        let controller = story.instantiateViewController(identifier: "SecondController")
        let navController = UINavigationController(rootViewController: controller)
        
        // when done button is tapped, call dismiss function
        let selector = #selector(dismiss as () -> Void)
        
        // add navigation button (done button) to the info view
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: selector)
        controller.navigationItem.rightBarButtonItem?.tintColor = .label
        
        // bring up information page
        self.navigationController!.present(navController, animated: true, completion: nil)
    }
    
    // dismiss view controller; activated by when the done button is tapped
    @objc func dismiss() {
        self.dismiss(animated: true)
    }

    
    // This is called when routes need to be drawn
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        // Generate a random color solely to be able to distinguish lines
        renderer.strokeColor = UIColor(hue: 0.5472, saturation: 1, brightness: 1, alpha: 1.0)
        return renderer
    }
    
    // This is called when an annotation needs to be shown
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is StartPoint else { return nil }
        
        let identifier = "StartPoint"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            // Create a new annotation view if one isn't in the queue
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let button = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    // This is called when the i button of an annotation view is tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Make sure that the annotation that is sent is from a StartPoint
        guard let location = view.annotation as? StartPoint else {return}
        let latitude: String = String(location.coordinate.latitude)
        let longitude: String = String(location.coordinate.longitude)
        // Show user latitude and longitude of starting point
        let ac = UIAlertController(
            title: "Start Point",
            message: "latitude: \(latitude)\n longitude: \(longitude)",
            preferredStyle: .alert)
        // Add done button so user can leave the alert
        let doneAction = UIAlertAction(title: "Done", style: .default) {_ in
        }
        
        ac.addAction(doneAction)
        present(ac, animated: true)
    }
    
    // If user wants to start at current location
    @objc func startCurrentLocation(_ sender: Any) {
        let ac = UIAlertController(
            title: "Start at current location",
            message: nil,
            preferredStyle: .alert)
        
        ac.addTextField()
        ac.textFields![0].placeholder = "Enter distance (in miles)"
        ac.textFields![0].keyboardType = UIKeyboardType.decimalPad

        let submitAction = UIAlertAction(title: "Done", style: .default) { [weak self, weak ac] action in
            guard let distance = ac?.textFields?[0].text else { return }
            // Make sure all of these are doubles
            guard let doubleDistance = distance.toDouble() else { return }
            self?.submit(doubleDistance)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    // Runs when user wants to find loop from current location
    func submit(_ distance: Double) {
        guard let currentLatitude = currentLocation?.coordinate.latitude else {return}
        guard let currentLongitude = currentLocation?.coordinate.longitude else {return}
        let newStartPoint = StartPoint(title: "Current Location", coordinate: CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude), distance: distance)
        // Remove all previous annotations
        self.mapView.removeAnnotations(mapView.annotations)
        // Also delete all old overlays
        self.mapView.removeOverlays(mapView.overlays)
        mapView.addAnnotation(newStartPoint)
        findRoutes(distance: distance, startPoint: newStartPoint)
    }
    
    func submit(_ locationName: String, _ distance: Double, _ placemark: MKPlacemark) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = locationName
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            
            for item in response.mapItems {
                // There will only be one location
                if item.name == locationName {
                    if let name = item.name, let location = item.placemark.location {
                        let newStartPoint = StartPoint(title: name, coordinate: location.coordinate, distance: distance)
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        // Also delete all old overlays
                        self.mapView.removeOverlays(self.mapView.overlays)
                        self.mapView.addAnnotation(newStartPoint)
                        // Zoom to pin
                        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
                        self.mapView.setRegion(region, animated: true)
                        
                        self.findRoutes(distance: distance, startPoint: newStartPoint)
                    }
                    // Can break because we only need the first one
                    break
                }
            }
        }
    }
    
    // When location changes, update currentLocation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        do { currentLocation = locations.last }
    }
    
    // if location fails to update, throw an error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }

    // finds the current location of the ios device
    func determineCurrentLocation() {
        mapView.delegate = self
        
        // show current location dot on map
        mapView.showsUserLocation = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        // best accuracy for current location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // check that Location Services are on an authorized
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    // Allows user to select how the map follows device location/orientation
    func addMapTrackingButton() {
        let trackButton = MKUserTrackingButton(mapView: mapView)
        // set size and color attributes for the track button
        trackButton.tintColor = .label
        trackButton.backgroundColor = .systemBackground.withAlphaComponent(0.7)
        trackButton.layer.borderColor = UIColor.label.cgColor
        trackButton.layer.borderWidth = 1
        trackButton.layer.cornerRadius = 5
        trackButton.translatesAutoresizingMaskIntoConstraints = false
        trackButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        trackButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        // add trackButton to the screen as a subview
        mapView.addSubview(trackButton)
        
        // shows scale of the map when zooming
        let scale = MKScaleView(mapView: mapView)
            scale.legendAlignment = .trailing
            scale.translatesAutoresizingMaskIntoConstraints = false
        
        // add scale indication to screen as a subview
        view.addSubview(scale)
        
        // set default tracking mode when app starts
        mapView.setUserTrackingMode(.follow, animated: true)
        
        // move compass below tracking button
        mapView.layoutMargins = UIEdgeInsets(
            top: 60,
            left: 0,
            bottom: 0,
            right: 8)
        
        // set tracking button and scale diagram to correct location on screen
        NSLayoutConstraint.activate([trackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                                        trackButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
                                        scale.trailingAnchor.constraint(equalTo: trackButton.leadingAnchor, constant: -10),
                                        scale.centerYAnchor.constraint(equalTo: trackButton.centerYAnchor),
                                    ])
    }
    
    /* Algorithm idea:
     Given a distance d, we find a marker d/4 away, find another marker d/4 away, find a last one d/4 away, then find a route to then back from the marker
      To find this marker, we go equal amount distance longitude and latitude such that longitude + latiude = d/3
     69 miles in y direction is 1 degree latitude
     54.6 miles in x direction is 1 degree longitude
     To provide alternate routes, we find different markers
     */
    func findRoutes(distance: Double, startPoint: MKAnnotation) {
        // Set the starting point to annotation's location
        let request1 = MKDirections.Request()
        
        let annotationCoordinate1 = startPoint.coordinate
        request1.source = MKMapItem(placemark: MKPlacemark(coordinate: annotationCoordinate1, addressDictionary: nil))
        let markerLatitude1 = annotationCoordinate1.latitude - distance/(4*69.0)
        let markerLongitude1 = annotationCoordinate1.longitude
        let annotationCoordinate2 = CLLocationCoordinate2D(latitude: markerLatitude1, longitude: markerLongitude1)
        request1.destination = MKMapItem(placemark: MKPlacemark(coordinate: annotationCoordinate2, addressDictionary: nil))
        request1.transportType = .walking
        
        let directions1 = MKDirections(request: request1)
        // Find routes
        directions1.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            // Iterate through array and add each route to the map
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
            }
        }
        
        // Go to third pin
        let request2 = MKDirections.Request()
        request2.source = MKMapItem(placemark: MKPlacemark(coordinate: annotationCoordinate2, addressDictionary: nil))
        let markerLatitude2 = annotationCoordinate2.latitude
        let markerLongitude2 = annotationCoordinate2.longitude - distance/(4*54.6)
        let annotationCoordinate3 = CLLocationCoordinate2D(latitude: markerLatitude2, longitude: markerLongitude2)
        request2.destination = MKMapItem(placemark: MKPlacemark(coordinate: annotationCoordinate3, addressDictionary: nil))
        request2.transportType = .walking
        let directions2 = MKDirections(request: request2)
        // Find routes
        directions2.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            // Iterate through array and add each route to the map
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
            }
        }
        
        // Go to final pin
        let request3 = MKDirections.Request()
        request3.source = MKMapItem(placemark: MKPlacemark(coordinate: annotationCoordinate3, addressDictionary: nil))
        let markerLatitude3 = annotationCoordinate3.latitude + distance/(4*69.0)
        let markerLongitude3 = annotationCoordinate3.longitude
        let annotationCoordinate4 = CLLocationCoordinate2D(latitude: markerLatitude3, longitude: markerLongitude3)
        request3.destination = MKMapItem(placemark: MKPlacemark(coordinate: annotationCoordinate4, addressDictionary: nil))
        request3.transportType = .walking
        let directions3 = MKDirections(request: request3)
        // Find routes
        directions3.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            // Iterate through array and add each route to the map
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)

            }
        }
        
        // Go home
        let request4 = MKDirections.Request()
        request4.source = MKMapItem(placemark: MKPlacemark(coordinate: annotationCoordinate4, addressDictionary: nil))
        request4.destination = request1.source
        request4.transportType = .walking
        let directions4 = MKDirections(request: request4)
        // Find routes
        directions4.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            // Iterate through array and add each route to the map
            for route in unwrappedResponse.routes {
                //route.polyline.size.width = 10
                self.mapView.addOverlay(route.polyline)
            }
        }
    }
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the entered pin
        selectedPin = placemark
        
        // clear existing pins
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        // find name of new pin
        guard let name = placemark.name else { return }
        
        // ask user for input distance
        let ac = UIAlertController(
            title: "Start at " + name,
            message: nil,
            preferredStyle: .alert)
        ac.addTextField()
        ac.textFields![0].placeholder = "Enter distance (in miles)"
        ac.textFields![0].keyboardType = UIKeyboardType.decimalPad
        
        
        let submitAction = UIAlertAction(
            title: "Done",
            style: .default) { [weak self, weak ac] action in
                guard let locationName = placemark.name else {return}
                guard let distance = ac?.textFields?[0].text else {return}
                guard let doubleDistance = distance.toDouble() else { return }
                self?.submit(locationName, doubleDistance, placemark)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
}

