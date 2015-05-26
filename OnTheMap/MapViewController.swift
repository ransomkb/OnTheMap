//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/16/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var pinName: String!
    var pinLat: String!
    var pinLong: String!
    
    let regionRadius: CLLocationDistance = 4000000

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let initialLocation = CLLocation(latitude: 39.50, longitude: -98.35)
        
        centerMapOnLocation(initialLocation)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // Example Map Stuff. Got from stackoverflow. Just for testing purposes.
    func openMapForPlace() {
        var lat1: NSString = self.pinLat
        var long1: NSString = self.pinLong
        
        var latitude: CLLocationDegrees = lat1.doubleValue
        var longitude: CLLocationDegrees = long1.doubleValue
        
        let regionDistance: CLLocationDistance = 10000
        var coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        var options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        
        var placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        var mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.pinName!)"
        mapItem.openInMapsWithLaunchOptions(options)
        
    }

}

