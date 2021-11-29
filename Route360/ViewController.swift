//
//  ViewController.swift
//  Route360
//
//  Created by Glen Liu on 11/29/21.
//

import UIKit
import MapKit


class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let pennypacker = StartPoint(title: "Pennypacker", coordinate: CLLocationCoordinate2D(latitude: 42.37265009033051, longitude: -71.113721461528942), info: "Best start point!")
        
        mapView.addAnnotation(pennypacker)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is StartPoint else { return nil }
        
        let identifier = "StartPoint"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "StartPoint")
        
        if annotation
    }

}

