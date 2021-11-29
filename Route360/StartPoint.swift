//
//  StartPoint.swift
//  Route360
//
//  Created by Glen Liu on 11/29/21.
//

import UIKit
import MapKit

class StartPoint: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String

    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
       self.title = title
       self.coordinate = coordinate
       self.info = info
    }

}
