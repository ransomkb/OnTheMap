//
//  FindLocationViewController.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/16/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import AddressBook
import CoreLocation
import MapKit
import UIKit

class FindLocationViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    var newLocation: Bool = true
    var alertMessage: String?
    
    var userLocation: StudentLocation?
    let regionRadius: CLLocationDistance = 40000
    var locationManager = CLLocationManager()
    var coordinates: CLLocationCoordinate2D?
    var placemark: CLPlacemark!
    var pinDatum:PinData?
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var previousLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        OTMClient.sharedInstance().searchForAStudentLocation({ (success, errorString) -> Void in
            if success {
                println("Succeeded in Searching.")
                if (errorString == nil) {
                    println("Retrieved Existing User's Location.")
                    self.newLocation = false
                    self.userLocation = OTMClient.sharedInstance().userLocation
                } else {
                    println("\(errorString!)")
                    let locDictionary = OTMClient.createUserLocation()
                    OTMClient.sharedInstance().userLocation = StudentLocation(dictionary: locDictionary as! [String : AnyObject])
                    
                    println("OTMClient userLocation dictionary: \(OTMClient.sharedInstance().userLocation?.studentDictionary)")
                    self.userLocation = OTMClient.sharedInstance().userLocation
                    self.previousLabel.text = "Previous: None"
                    self.newLocation = true
                }
            }
        })

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.startUpdatingLocation()
        if let place = placemark {
            textField.text = "\(placemark.locality), \(placemark.administrativeArea)  \(placemark.country)"
        }
        
        self.findButton.hidden = false
        self.previousLabel.hidden = false
        self.messageLabel.hidden = false
        self.mapView.hidden = true
        self.submitButton.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    override func viewWillDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
        
        self.findButton.hidden = false
        self.previousLabel.hidden = false
        self.messageLabel.hidden = false
        self.mapView.hidden = true
        self.submitButton.hidden = true

        super.viewWillDisappear(animated)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func cancelActivities(sender: AnyObject) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.activityIndicatorView.stopAnimating()
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func findMyLocation(sender: UIButton) {
        
        println("Finding My Location")
        if !self.textField.text.isEmpty {
            let addressString = self.textField.text
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(addressString, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
                if let anError = error {
                    self.alertMessage = "GeoCode Failed with Error: \(anError.localizedDescription)"
                    self.alertUser()
                    println(self.alertMessage)
                } else if placemarks.count > 0 {
                    let place = placemarks[0] as! CLPlacemark
                    let location = place.location
                    self.coordinates = location.coordinate
                    self.userLocation!.latitude = self.coordinates!.latitude
                    self.userLocation!.longitude = self.coordinates!.longitude
                    self.userLocation!.mapString = addressString
                    println("\(self.userLocation!.mapString) ; \(self.userLocation!.latitude) \(self.userLocation!.longitude)")
                    
                    self.setCenterLocation()
                    self.centerMapOnLocation(OTMClient.sharedInstance().myLocation!)
                    
                    self.pinDatum = PinData(title: "\(self.userLocation!.firstName) \(self.userLocation!.lastName)", urlString: "\(self.userLocation!.mediaURL)", coordinate: self.coordinates!)
                    self.mapView.addAnnotation(self.pinDatum)
                    
                    self.findButton.hidden = true
                    self.previousLabel.hidden = true
                    self.messageLabel.hidden = true
                    self.mapView.hidden = false
                    self.submitButton.hidden = false
                    
                    self.textField.text = "http://www.google.com"
                }
            })
        } else {
            self.alertMessage = "The Text Field was empty. Please enter a location such as Osaka, Japan or Santa Cruz, CA."
            self.alertUser()
        }
    }
    
    @IBAction func submitMyLocationData(sender: UIButton) {
        
        if !self.textField.text.isEmpty {
            let text = self.textField.text
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.activityIndicatorView.startAnimating()
            }
            
            self.userLocation!.mediaURL = text
            
            println("FindLocation userLocation dictionary: \(self.userLocation!.studentDictionary)")
            //self.userLocation!.studentDictionary[]
            println("FindLocation userLocation mediaURL: \(self.userLocation!.mediaURL)")
            OTMClient.sharedInstance().userLocation = self.userLocation!
            
            if newLocation {
                OTMClient.sharedInstance().createUserLocation({ (success, errorString) -> Void in
                    if success {
                        println("User Location was created.")
                        self.returnToRootController()
                    } else {
                        self.alertMessage = errorString
                        self.alertUser()
                    }
                })
            } else {
                OTMClient.sharedInstance().updateUserLocation({ (success, errorString) -> Void in
                    if success {
                        println("User Location was updated.")
                        self.returnToRootController()
                    } else {
                        self.alertMessage = errorString
                        self.alertUser()
                    }
                })
            }
        } else {
            self.activityIndicatorView.stopAnimating()
            self.previousLabel.text = "Please try again."
            self.alertMessage = "The Text Field was empty. Please enter a URL such as www.google.com"
            self.alertUser()
        }
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        println("Centering Map.")
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func setCenterLocation() {
        OTMClient.sharedInstance().myLocation = CLLocation(latitude: self.userLocation!.latitude, longitude: self.userLocation!.longitude)
    }
    
    func returnToRootController() {
        println("Preparing to return to Map View Controller.")
        OTMClient.sharedInstance().getStudentLocations({ (success, errorString) -> Void in
            if success {
                println("Done Getting Student Locations")
                if (errorString == nil) {
                    println("Retrieved \(OTMClient.sharedInstance().students.count) Student Locations.")
                    self.setCenterLocation()
                    
                    self.pinDatum = PinData(title: "\(self.userLocation!.firstName) \(self.userLocation!.lastName)", urlString: "\(self.userLocation!.mediaURL)", coordinate: self.coordinates!)
                    OTMClient.sharedInstance().pinDatum = self.pinDatum
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.activityIndicatorView.stopAnimating()
                        //self.navigationController!.popToRootViewControllerAnimated(true)
                        
//                        let mapController = self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
//                        mapController.pinData.append(self.pinDatum!)
                        
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
//                        let children = controller.childViewControllers
//                        for child in children {
//                            println("Child' \(child.title!)")
//                            
//                        }
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                } else {
                    self.alertMessage = errorString
                    self.alertUser()
                }
            }
        })
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            if (error != nil) {
                var errorString = "Reverse geocoder failed with error: " + error.localizedDescription
                self.alertMessage = errorString
                self.alertUser()
                self.previousLabel.text = errorString
                return
            }
            
            if placemarks.count > 0 {
                self.placemark = placemarks[0] as! CLPlacemark
                self.locationManager.stopUpdatingLocation()
                println(self.placemark.locality)
                println(self.placemark.postalCode)
                println(self.placemark.administrativeArea)
                println(self.placemark.country)
                if let place = self.placemark {
                    self.textField.text = "\(place.locality), \(place.administrativeArea)  \(place.country)"
                }
            }
        })
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.mapView.showsUserLocation = (status == .AuthorizedAlways)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        var errorString = "Error while updating location " + error.localizedDescription
        self.alertMessage = errorString
        self.alertUser()
        previousLabel.text = errorString
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
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    
}
