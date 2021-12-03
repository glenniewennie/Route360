//
//  ViewController.swift
//  Route360
//
//  Created by Glen Liu on 11/29/21.
//

import UIKit
import MapKit
import CoreLocation


// Used to convert Strings to Doubles
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
     }
}

// Used to generate a random color - see rendererFor method
extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMapTrackingButton()
        
        title = "Route360"
        navigationItems()
    
        let pennypacker = StartPoint(title: "Pennypacker", coordinate: CLLocationCoordinate2D(latitude: 42.37201109033051, longitude: -71.11369242), distance: 4)
        mapView.addAnnotation(pennypacker)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        determineCurrentLocation()
    }
    
    
    private func navigationItems() {
        navigationController?.navigationBar.tintColor = .label
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "info.circle"),
                style: .done,
                target: self,
                action: #selector(infoButtonTapped)
            ),
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addTapped)
            )
        ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .done,
            target: self,
            action: #selector(searchTapped)
        )
    }
    
    @objc func infoButtonTapped(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let controller = story.instantiateViewController(identifier: "SecondController") 
        self.present(controller, animated: true, completion: nil)
    }
    
    
    // This is called when routes need to be drawn
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        // Generate a random color solely to be able to distinguish lines
        renderer.strokeColor = UIColor.random()
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
        let ac = UIAlertController(title: "Start Point", message: "latitude: \(latitude)\n longitude: \(longitude)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Find routes", style: .default, handler: { action in
            self.findRoutes(distance: location.distance)
        }))
        present(ac, animated: true)
    }
    
    @objc func addTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Starting point", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addTextField()
        ac.addTextField()
        ac.textFields![0].placeholder = "Enter latitude"
        ac.textFields![1].placeholder = "Enter longitude"
        ac.textFields![2].placeholder = "Enter distance"
        
        // Test coords - 30.371302863706674, -97.66758083066455
        let submitAction = UIAlertAction(title: "Done", style: .default) { [weak self, weak ac] action in
            guard let latitude = ac?.textFields?[0].text else { return }
            guard let longitude = ac?.textFields?[1].text else { return }
            guard let distance = ac?.textFields?[2].text else { return }
            // Make sure all of these are doubles
            guard let doubleLatitude = latitude.toDouble() else {return}
            guard let doubleLongitude = longitude.toDouble() else {return}
            guard let doubleDistance = distance.toDouble() else { return }
            self?.submit(doubleLatitude, doubleLongitude, doubleDistance)

        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ latitude: Double, _ longitude: Double, _ distance: Double) {
        let newStartPoint = StartPoint(title: "New Start Point", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), distance: distance)
        // Remove all previous annotations
        self.mapView.removeAnnotations(mapView.annotations)
        // Also delete all old overlays
        self.mapView.removeOverlays(mapView.overlays)
        mapView.addAnnotation(newStartPoint)
    }
    
    // Runs if user wants to search up a physical location
    @objc func searchTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Starting point", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addTextField()
        ac.textFields![0].placeholder = "Enter name of location"
        ac.textFields![1].placeholder = "Enter distance (in miles)"
        let submitAction = UIAlertAction(title: "Done", style: .default) { [weak self, weak ac] action in
            guard let locationName = ac?.textFields?[0].text else {return}
            guard let distance = ac?.textFields?[1].text else {return}
            guard let doubleDistance = distance.toDouble() else { return }
            self?.submit(locationName, doubleDistance)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ locationName: String, _ distance: Double) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = locationName
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            
            // Means there's only one location possible so user doesn't have to choose
            if response.mapItems.count == 1 {
                let item = response.mapItems[0]
                if let name = item.name, let location = item.placemark.location {
                    let newStartPoint = StartPoint(title: name, coordinate: location.coordinate, distance: distance)
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    // Also delete all old overlays
                    self.mapView.removeOverlays(self.mapView.overlays)
                    self.mapView.addAnnotation(newStartPoint)
                }
            } else {
                let ac = UIAlertController(title: "Choose your location", message: nil, preferredStyle: .actionSheet)
                // Increment through all possible locations and add them to action sheet as choices
                for item in response.mapItems {
                    if let name = item.name, let location = item.placemark.location {
                        ac.addAction(UIAlertAction(title: name, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                            let newStartPoint = StartPoint(title: name, coordinate: location.coordinate, distance: distance)
                            // Also delete all old overlays
                            self.mapView.removeOverlays(self.mapView.overlays)
                            self.mapView.removeAnnotations(self.mapView.annotations)
                            self.mapView.addAnnotation(newStartPoint)
                        }))
                    }
                }
                self.present(ac, animated: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                mapView.setRegion(viewRegion, animated: true)
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }

    func determineCurrentLocation() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Check for Location Services
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func addMapTrackingButton() {
        
        let trackButton = MKUserTrackingButton(mapView: mapView)
            trackButton.tintColor = .label
            //trackButton.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
            trackButton.backgroundColor = .systemBackground.withAlphaComponent(0.7)
            trackButton.layer.borderColor = UIColor.label.cgColor
            trackButton.layer.borderWidth = 1
            trackButton.layer.cornerRadius = 5
            trackButton.translatesAutoresizingMaskIntoConstraints = false
            trackButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
            trackButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        mapView.addSubview(trackButton)
        
        let scale = MKScaleView(mapView: mapView)
            scale.legendAlignment = .trailing
            scale.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(scale)
        
        //Move compass below tracking button
        mapView.layoutMargins = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 8)
        
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
    func findRoutes(distance: Double) {
        
        // Set the starting point to annotation's location
        let request1 = MKDirections.Request()
        let annotationCoordinate1 = self.mapView.annotations[0].coordinate
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
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
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
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
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
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
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
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
         
    }
    
    
}

