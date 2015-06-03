//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/16/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // maybe don't need these
    var pinName: String!
    var pinLat: String!
    var pinLong: String!
    
    var pinData = [PinData]()
    var students:[StudentLocation] = [StudentLocation]()
    
    let regionRadius: CLLocationDistance = 4000000

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        println("Loading Map View")
        mapView.delegate = self
        
        let initialLocation = CLLocation(latitude: 39.50, longitude: -98.35)
        centerMapOnLocation(initialLocation)
        
        // Moved: Did Call this in the completion handler to ensure order of operations
        OTMClient.sharedInstance().getStudentLocations({ (success, errorString) -> Void in
            if success {
                println("Done Getting Student Locations")
                if (errorString == nil) {
                    self.students = OTMClient.sharedInstance().students
                    println("Retrieved \(self.students.count) Student Locations.")
                    self.loadInitialData()
                    println(self.pinData)
                    println("Try to add pins in viewDidLoad.")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.mapView!.addAnnotations(self.pinData)
                    }
                } else {
                    println("\(errorString!)")
                }
            }
        })

        //self.mapView!.addAnnotations(self.pinData)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("View Will Appear")
        //self.mapView!.reloadInputViews()
        //self.loadInitialData()
        self.mapView!.removeAnnotations(self.pinData)
        self.loadInitialData()
        self.mapView!.addAnnotations(self.pinData)
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
    
    func loadInitialData() {
        
        println("Loading Initial Data")
        
        if !self.students.isEmpty {
            for location in self.students {
                let pinDatum = PinData(title: "\(location.firstName) \(location.lastName)", urlString: location.mediaURL, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                pinData.append(pinDatum)
                //self.mapView!.addAnnotation(pinDatum)
            }
        }
    }

}

