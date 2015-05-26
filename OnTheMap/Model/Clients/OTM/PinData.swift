//
//  PinData.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/22/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import MapKit

class PinData: NSObject, MKAnnotation {
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    
    init(studentName: String, urlString: String, coordinate: CLLocationCoordinate2D) {
        self.title = studentName
        self.subtitle = urlString
        self.coordinate = coordinate
        
        super.init()
    }
}
