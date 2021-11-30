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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMapTrackingButton()
        
        title = "Route360"
        navigationItems()
    
        let pennypacker = StartPoint(title: "Pennypacker", coordinate: CLLocationCoordinate2D(latitude: 42.37201109033051, longitude: -71.11369242), distance: 4.5)
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
        renderer.strokeColor = UIColor.blue
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
            self.findRoutes()
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
    
    
    func findRoutes() {
        let request = MKDirections.Request()
        
        // Set the starting point to annotation's location
        let annotationCoordinate = self.mapView.annotations[0].coordinate
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: annotationCoordinate, addressDictionary: nil))
        // Set current destination to be Hurlbut
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.3722984046454, longitude: -71.11403724575048), addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        // Find routes
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            // Iterate through array and add each route to the map
            for route in unwrappedResponse.routes {
                // Set bounds on distance (make sure to convert from meters to miles
//                if route.distance / (1609.34) > 0.9 * startPoint.distance && route.distance < 1.1 * startPoint.distance
                
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
            }
        }
    }
    
}

