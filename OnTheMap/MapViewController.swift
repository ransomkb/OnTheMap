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
    
    var alertMessage: String?
    
    // Data source for annotations.
    var pinData = [PinData]()
    
    // Array for storing fetched student locations
    var students = [StudentLocation]()
    
    // Array for two right button items
    var navBarButtonItems = [UIBarButtonItem]()
    
    // Set the initial zoom level.
    let regionRadius: CLLocationDistance = 4000000
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    
    // One right nav button for updating array of student locations
    var refreshButtonItem: UIBarButtonItem {
        
        // Use the standard refresh icon.
        return UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshStudentLocations")
    }
    
    // Another right nav button for setting user's location
    var userLocationButtonItem: UIBarButtonItem {
        
        // Use image of a pin for the button
        let pinImage = UIImage(named: "pin")
        return UIBarButtonItem(image: pinImage, style: .Plain, target: self, action: "segueToFindLocation")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add right nav button items to array.
        var navItem:UINavigationItem = self.navigationBar.items[0] as! UINavigationItem
        navBarButtonItems = [self.refreshButtonItem, self.userLocationButtonItem]
        
        // Add array of nav items to UINavigationItem.
        navItem.rightBarButtonItems = navBarButtonItems
        
        println("Loading Map View")
        
        // Set self as the map view delegate.
        mapView.delegate = self
        
        // Try to get all the student locations from Udacity.
        getStudentLocations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
        println("Map View Will Appear")
        
        // Center map on user's location, if they allow.
        centerMapOnLocation(OTMClient.sharedInstance().myLocation!)
        
        // Add pin annotations of each student location sent by Udacity (if any) to map view.
        if let pin = OTMClient.sharedInstance().pinDatum {
            self.mapView!.addAnnotation(pin)
        }
    }
    
    // Button that will log the user out of Udacity.
    @IBAction func logOut(sender: AnyObject) {
        
        // Set shared OTMClient loggedIn to false.
        OTMClient.sharedInstance().loggedIn = false
        
        // Create instance of LoginViewController on storyboard.
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        
        // Present LoginViewController.
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // Center the map on the user's location.
    func centerMapOnLocation(location: CLLocation) {
        println("Centering Map.")
        
        // Set the coordinate of the region based on the preset regionRadius variable.
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        // Set the region for the map view.
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    // Update the student location data source.
    func refreshStudentLocations() {
        
        // Fetch existing student locations from Udacity.
        getStudentLocations()
    }
    
    // Segue to allow the user to set / update their location for Udacity.
    func segueToFindLocation() {
        println("Preparing to segue to FindLocation.")
        
        // Create an instance of FindLocationViewController on storyboard.
        let locationController = self.storyboard!.instantiateViewControllerWithIdentifier("FindLocationViewController") as! FindLocationViewController
        
        // Present the FindLocationViewController.
        self.presentViewController(locationController, animated: true, completion: nil)
    }
    
    // Fetch existing student locations from Udacity.
    func getStudentLocations() {
        OTMClient.sharedInstance().getStudentLocations({ (success, errorString) -> Void in
            
            // Use completion handler to inform self of success or failure.
            if success {
                println("Done Getting Student Locations")
                
                // Check to see if some issue exists despite successful retrieval.
                if (errorString == nil) {
                    
                    // As no issue, store retrieved student locations in self variable.
                    self.students = OTMClient.sharedInstance().students
                    println("Retrieved \(self.students.count) Student Locations.")
                    
                    // Check if the user's pin exists already.
                    if let pin = OTMClient.sharedInstance().pinDatum {
                        
                        // Pin exists, so keep it by filtering it from a subset of all pins.
                        let removePinAnnotations = self.mapView!.annotations.filter() {$0 !== OTMClient.sharedInstance().pinDatum}
                        
                        // Remove all remaining pins.
                        self.mapView!.removeAnnotations(removePinAnnotations)
                    } else {
                        
                        // Remove all pins as user's pin does not exist.
                        self.mapView!.removeAnnotations(self.pinData)
                    }

                    // Refresh the data, updating the data source for pins based on array of student locations.
                    self.loadInitialData()
                    
                    // Add pin annotations to map view on the main queue.
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.mapView!.addAnnotations(self.pinData)
                    }
                } else {
                    
                    // Alert user that there was some issue when trying to retrieve the student locations from Udacity, even though a dictionary of locations was received.
                    println("\(errorString!)")
                    
                    // Set the alert message to the errorString value.
                    self.alertMessage = errorString
                    
                    // Use a UIAlertController to inform user of issue.
                    self.alertUser()
                }
            } else {
                
                // Alert user that the attempt to retrieve the student locations from Udacity failed.
                println("\(errorString!)")
                
                // Set the alert message to the errorString value.
                self.alertMessage = errorString
                
                // Use a UIAlertController to inform user of issue.
                self.alertUser()
            }
        })
    }
    
    // Refresh the data, updating the data source for pins based on array of student locations.
    func loadInitialData() {
        
        println("Loading Initial Data")
        
        // Check that the array of student locations is not empty.
        if !self.students.isEmpty {
            
            // Create a new array for pinData.
            pinData = [PinData]()
            
            // Iterate through the array of student locations.
            for location in self.students {
                
                // Create a new pinData for each student location.
                let pinDatum = PinData(title: "\(location.firstName) \(location.lastName)", urlString: location.mediaURL, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                
                // Add the pinData to the array.
                pinData.append(pinDatum)
            }
            
            println("\(pinData.count)")
        }
    }
    
    // Use an UIAlertController to inform user of issue.
    func alertUser() {
        
        // Use the main queue to ensure speed.
        dispatch_async(dispatch_get_main_queue(), {
            
            // Create an instance of UIAlertController.
            let alertController = UIAlertController(title: "Problem", message: self.alertMessage, preferredStyle: .Alert)
            
            // Set the alert message.
            if let message = self.alertMessage {
                alertController.message = message
            }
            
            // Create action button with OK button to dismiss alert.
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
                
            }
            
            // Add the OK action.
            alertController.addAction(okAction)
            
            // Present the alert controller.
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    

}

