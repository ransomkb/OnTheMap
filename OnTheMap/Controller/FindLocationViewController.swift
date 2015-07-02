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
    
    var showLocationUI = true
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
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.previousLabel.text = self.userLocation!.mapString
                    }
                } else {
                    println("\(errorString!)")
                    let locDictionary = OTMClient.createUserLocation()
                    OTMClient.sharedInstance().userLocation = StudentLocation(dictionary: locDictionary as! [String : AnyObject])
                    
                    println("OTMClient userLocation dictionary: \(OTMClient.sharedInstance().userLocation?.studentDictionary)")
                    self.userLocation = OTMClient.sharedInstance().userLocation
                    self.newLocation = true
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.previousLabel.text = "No Previous Location"
                    }
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
        
        showUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    override func viewWillDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
        showLocationUI = true
        
        super.viewWillDisappear(animated)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func cancelActivities(sender: AnyObject) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.activityIndicatorView.stopAnimating()
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerTabBarController") as! ManagerTabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func findMyLocation(sender: UIButton) {
        
        println("Finding My Location")
        if !self.textField.text.isEmpty {
            startIndicatingActivity()
            
            let addressString = self.textField.text
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(addressString, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
                if let anError = error {
                    self.alertMessage = "GeoCode Failed with Error: \(anError.localizedDescription)"
                    self.alertUser()
                    println(self.alertMessage)
                    self.stopIndicatingActivity()
                } else if placemarks.count > 0 {
                    let place = placemarks[0] as! CLPlacemark
                    let location = place.location
                    self.coordinates = location.coordinate
                    self.userLocation!.latitude = self.coordinates!.latitude
                    self.userLocation!.longitude = self.coordinates!.longitude
                    self.userLocation!.mapString = "\(place.locality), \(place.administrativeArea), \(place.country)"
                    println("\(self.userLocation!.mapString) ; \(self.userLocation!.latitude) \(self.userLocation!.longitude)")
                    
                    self.setCenterLocation()
                    self.centerMapOnLocation(OTMClient.sharedInstance().myLocation!)
                    
                    self.pinDatum = PinData(title: "\(self.userLocation!.firstName) \(self.userLocation!.lastName)", urlString: "\(self.userLocation!.mediaURL)", coordinate: self.coordinates!)
                    
                    self.stopIndicatingActivity()
                    
                    self.showLocationUI = false
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.mapView.addAnnotation(self.pinDatum)
                        self.showUI()
                    }
                    
                    
                    self.textField.text = "http://www.apple.com"
                }
            })
        } else {
            self.alertMessage = "The Text Field was empty. Please enter a location such as Osaka, Japan or Santa Cruz, CA."
            self.alertUser()
        }
    }
    
    @IBAction func submitMyLocationData(sender: UIButton) {
        
        if !self.textField.text.isEmpty {
            startIndicatingActivity()
            let text = self.textField.text
            
            startIndicatingActivity()
            
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
                    self.stopIndicatingActivity()
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
                    self.stopIndicatingActivity()
                })
            }
        } else {
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
                    
                    self.stopIndicatingActivity()
                    println("Retrieved \(OTMClient.sharedInstance().students.count) Student Locations.")
                    self.setCenterLocation()
                    
                    self.pinDatum = PinData(title: "\(self.userLocation!.firstName) \(self.userLocation!.lastName)", urlString: "\(self.userLocation!.mediaURL)", coordinate: self.coordinates!)
                    OTMClient.sharedInstance().pinDatum = self.pinDatum
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //self.activityIndicatorView.stopAnimating()
                        //self.navigationController!.popToRootViewControllerAnimated(true)
                        
//                        let mapController = self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
//                        mapController.pinData.append(self.pinDatum!)
                        
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerTabBarController") as! ManagerTabBarController
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
    
    func showUI() {
        if showLocationUI {
            self.findButton.hidden = false
            self.previousLabel.hidden = false
            self.messageLabel.hidden = false
            self.mapView.hidden = true
            self.submitButton.hidden = true
        } else {
            self.findButton.hidden = true
            self.previousLabel.hidden = true
            self.messageLabel.hidden = true
            self.mapView.hidden = false
            self.submitButton.hidden = false
        }
    }
    
    func startIndicatingActivity() {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.activityIndicatorView.startAnimating()
            self.findButton.alpha = 0.5
            self.previousLabel.alpha = 0.5
            self.messageLabel.alpha = 0.5
            self.mapView.alpha = 0.5
            self.submitButton.alpha = 0.5
        }
    }
    
    func stopIndicatingActivity() {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.activityIndicatorView.stopAnimating()
            self.findButton.alpha = 1.0
            self.previousLabel.alpha = 1.0
            self.messageLabel.alpha = 1.0
            self.mapView.alpha = 1.0
            self.submitButton.alpha = 1.0
        }
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
        
        self.alertMessage = "Error while updating location " + error.localizedDescription
        self.alertUser()
        previousLabel.text = self.alertMessage
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
