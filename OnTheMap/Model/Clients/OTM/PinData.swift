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
    
    var subtitle: String {
        return urlString
    }
    
    // practice for learning about map items and placemarks
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonURLProperty): subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
}
