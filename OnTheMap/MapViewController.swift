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
    
    let manager: ManagerTabBarController = ManagerTabBarController()
    
    
    var alertMessage: String?
    
    var pinData = [PinData]()
    var students = [StudentLocation]()
    var navBarButtonItems = [UIBarButtonItem]()
    
    let regionRadius: CLLocationDistance = 4000000
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //navBarButtonItems = [self.refreshButton, manager.userLocationButtonItem]
        //self.navigationItem.rightBarButtonItems = navBarButtonItems
        println("Loading Map View")
        mapView.delegate = self
        
        //myLocation = CLLocation(latitude: 39.50, longitude: -98.35)
        
       self.getStudentLocations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
        println("Map View Will Appear")
        //println("My Location: \(OTMClient.sharedInstance().myLocation)")
        centerMapOnLocation(OTMClient.sharedInstance().myLocation!)
        self.students = OTMClient.sharedInstance().students
        self.loadInitialData()
        self.mapView!.removeAnnotations(self.pinData)
        self.mapView!.addAnnotations(self.pinData)
        if let pin = OTMClient.sharedInstance().pinDatum {
            self.mapView!.addAnnotation(pin)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        println("Centering Map.")
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func refreshStudentLocations() {
        OTMClient.sharedInstance().getStudentLocations { (success, errorString) -> Void in
            if success {
                println("Refreshed")
                self.getStudentLocations()
            } else {
                println("Couldn't refresh Student Locations.")
                self.alertMessage = errorString
                self.alertUser()
            }
        }
    }
    
    func segueToFindLocation() {
        println("Preparing to segue to FindLocation.")
        
        let locationController = self.storyboard!.instantiateViewControllerWithIdentifier("FindLocationViewController") as! FindLocationViewController
        
        self.presentViewController(locationController, animated: true, completion: nil)
    }

    
//    @IBAction func refreshStudentLocations() {
//        println("Refreshing in Map")
//        getStudentLocations()
//    }
    
    func getStudentLocations() {
        // Moved: Did Call this in the completion handler to ensure order of operations
        OTMClient.sharedInstance().getStudentLocations({ (success, errorString) -> Void in
            if success {
                println("Done Getting Student Locations")
                if (errorString == nil) {
                    self.students = OTMClient.sharedInstance().students
                    println("Retrieved \(self.students.count) Student Locations.")
                    self.loadInitialData()
                    //println(self.pinData)
                    //println("Try to add pins in viewDidLoad.")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.mapView!.addAnnotations(self.pinData)
                    }
                } else {
                    println("\(errorString!)")
                    self.alertMessage = errorString
                    self.alertUser()
                }
            }
        })
    }
    
    //@IBAction
    
    func loadInitialData() {
        
        println("Loading Initial Data")
        
        if !self.students.isEmpty {
            pinData = [PinData]()
            for location in self.students {
                let pinDatum = PinData(title: "\(location.firstName) \(location.lastName)", urlString: location.mediaURL, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                pinData.append(pinDatum)
                //self.mapView!.addAnnotation(pinDatum)
            }
            println("\(pinData.count)")
            
        }
    }
    
    func alertUser() {
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = UIAlertController(title: "Problem", message: self.alertMessage, preferredStyle: .Alert)
            //alertController.title = "Problem"
            if let message = self.alertMessage {
                alertController.message = message
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
                //self.dismissViewControllerAnimated(true, completion: nil)
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }


}

