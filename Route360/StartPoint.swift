//
//  StartPoint.swift
//  Route360
//
//  Created by Glen Liu and Joshua Halberstadt on 11/20/21.
//

import UIKit
import MapKit

class StartPoint: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var distance: Double

    init(title: String, coordinate: CLLocationCoordinate2D, distance: Double) {
       self.title = title
       self.coordinate = coordinate
       self.distance = distance
    }
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        self.distance = 0.0
    }

}
