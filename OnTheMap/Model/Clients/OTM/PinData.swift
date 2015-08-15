//
//  PinData.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/22/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import AddressBook
import MapKit

// Object to hold all of the data each pin needs.
class PinData: NSObject, MKAnnotation {
    let title: String
    let urlString: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, urlString: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.urlString = urlString
        self.coordinate = coordinate
        
        super.init()
    }
    
    // Create computed value from urlString for subtitle value of a pin.
    var subtitle: String {
        return urlString
    }
}
