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

// Find the user's location and add it to / update Udacity.
class FindLocationViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    // For hiding / revealing some UI elements
    var showLocationUI = true
    
    // For showing if any location for this user already exists
    var newLocation: Bool = true
    var alertMessage: String?
    
    var userLocation: StudentLocation?
    
    // For zooming into the user's desired location
    let regionRadius: CLLocationDistance = 40000
    var locationManager = CLLocationManager()
    var coordinates: CLLocationCoordinate2D?
    
    // For showing the user's location with a pin annotation.
    var placemark: CLPlacemark!
    var pinDatum:PinData?
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var previousLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    // For finding the location entered into the text field
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set self as text field and location manager delegates.
        textField.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        // Determine if user already has a location stored with Udacity.
        OTMClient.sharedInstance().searchForAStudentLocation({ (success, errorString) -> Void in
            
            // Use completion handler to check if a location for the user was found.
            if success {
                println("Succeeded in Searching.")
                if (errorString == nil) {
                    
                    // Set variables for existing location.
                    println("Retrieved Existing User's Location.")
                    self.newLocation = false
                    self.userLocation = OTMClient.sharedInstance().userLocation
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        // Update the label showing the existing user's location stored with Udacity.
                        self.previousLabel.text = self.userLocation!.mapString
                    }
                } else {
        
                    // Found no existing user's location stored with Udacity.
                    
                    println("\(errorString!)")
                    
                    // Create a dictionary of location values derived from the shared OTMClient variables.
                    let locDictionary = OTMClient.createUserLocation()
                    
                    // Create a student location with the location dictionary.
                    self.userLocation = StudentLocation(dictionary: locDictionary as! [String : AnyObject])
                    
                    // Assign that location to the user's location variable on the shared OTMClient
                    OTMClient.sharedInstance().userLocation = self.userLocation
                    
                    println("OTMClient userLocation dictionary: \(OTMClient.sharedInstance().userLocation?.studentDictionary)")
                    
                    // Record that this is a new location.
                    self.newLocation = true
                    
                    // Inform user that this is a new location.
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.previousLabel.text = "No Previous Location"
                    }
                }
            }
        })

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Follow the user's current location, if allowed.
        locationManager.startUpdatingLocation()
        
        // Reveal and hide various UI elements.
        showUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if authorized to track current location.
        checkLocationAuthorizationStatus()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        // Stop tracking current location.
        locationManager.stopUpdatingLocation()
        
        super.viewWillDisappear(animated)
    }
    
    // Allow return key to resign text field as first responder.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Cancel activities and return to UITabBarController.
    @IBAction func cancelActivities(sender: AnyObject) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            
            // Stop activity indicator.
            self.activityIndicatorView.stopAnimating()
            
            // Create instance of UITabBarController with storyboard.
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UITabBarController") as! UITabBarController
            
            // Present the UITabBarController.
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // Find the location entered into the text field.
    @IBAction func findMyLocation(sender: UIButton) {
        
        println("Finding My Location")
        
        // Check that the text field is not empty.
        if !self.textField.text.isEmpty {
            
            // Start animating activity indicator and fade some UI elements.
            startIndicatingActivity()
            
            // Create a geocoder instance.
            let geoCoder = CLGeocoder()
            
            // Get a geocode address from the text field string;
            // Use placemarks variable in completion handler to set student location variables.
            geoCoder.geocodeAddressString(self.textField.text, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
                
                // Check for error.
                if let anError = error {
                    
                    // Alert user what the error is.
                    self.alertMessage = "GeoCode Failed with Error: \(anError.localizedDescription)"
                    
                    // Use a UIAlertController to inform user of issue.
                    self.alertUser()
                    println(self.alertMessage)
                    
                    // Stop animating activity indicator and return UI elements to full visibility.
                    self.stopIndicatingActivity()
                    
                    // Check there is at least one in the placemarks array.
                } else if placemarks.count > 0 {
                    
                    // Get the first location.
                    let place = placemarks[0] as! CLPlacemark
                    let location = place.location
                    
                    // Get the coordinate of the location.
                    self.coordinates = location.coordinate
                    
                    // Assign the latitude and longitude to the user's location.
                    self.userLocation!.latitude = self.coordinates!.latitude
                    self.userLocation!.longitude = self.coordinates!.longitude
                    
                    // Create a string representing the location address.
                    self.userLocation!.mapString = "\(place.locality), \(place.administrativeArea), \(place.country)"
                    println("\(self.userLocation!.mapString) ; \(self.userLocation!.latitude) \(self.userLocation!.longitude)")
                    
                    // Create a zoom and center for the confirmation map at the top of the page.
                    self.setCenterLocation()
                    self.centerMapOnLocation(OTMClient.sharedInstance().myLocation!)
                    
                    // Create a pin annotation for the map.
                    self.pinDatum = PinData(title: "\(self.userLocation!.firstName) \(self.userLocation!.lastName)", urlString: "\(self.userLocation!.mediaURL)", coordinate: self.coordinates!)
                    
                    // Stop animating activity indicator and return UI elements to full visibility.
                    self.stopIndicatingActivity()
                    
                    // Set the boolean for hiding and showing UI elements.
                    self.showLocationUI = false
                    
                    // Add the pin annotation to the map view.
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.mapView.addAnnotation(self.pinDatum)
                        
                        // Reveal and hide various UI elements.
                        self.showUI()
                    }
                    
                    // Fill the text field with convenience url.
                    if self.newLocation {
                        self.textField.text = "http://www.apple.com"
                    } else {
                        
                        // Provide the existing mediaURL.
                        if let location = self.userLocation {
                            self.textField.text = location.mediaURL
                        } else {
                            self.textField.text = ""
                        }
                    }
                }
            })
        } else {
            
            // Alert user that the text field was empty, so try again.
            self.alertMessage = "The Text Field was empty. Please enter a location such as Osaka, Japan or Santa Cruz, CA."
            
            // Use a UIAlertController to inform user of issue.
            self.alertUser()
        }
    }
    
    // Try to create or update the user's location data on Udacity.
    @IBAction func submitMyLocationData(sender: UIButton) {
        
        // Make sure the text field is not empty.
        if !self.textField.text.isEmpty {
            
            // Start animating activity indicator and fade some UI elements.
            startIndicatingActivity()
            
            // Get a copy of the text from the text field.
            let text = self.textField.text
            
            // Set the student location mediaURL to the text.
            self.userLocation!.mediaURL = text
            
            println("FindLocation userLocation dictionary: \(self.userLocation!.studentDictionary)")
            println("FindLocation userLocation mediaURL: \(self.userLocation!.mediaURL)")
            
            // Ensure that the shared OTMClient user location is the same as self.
            OTMClient.sharedInstance().userLocation = self.userLocation!
            
            // Check if user has an existing location.
            if newLocation {
                
                // Create the user's location via the shared OTMClient.
                OTMClient.sharedInstance().createUserLocation({ (success, errorString) -> Void in
                    
                    // Check completion handler for creation success.
                    if success {
                        println("User Location was created.")
                        
                        // Update student locations on Udacity, then present UITabBarController.
                        self.returnToRootController()
                    } else {
                        
                        // Alert user about the details of the failure to create the location on Udacity.
                        self.alertMessage = errorString
                        
                        // Use a UIAlertController to inform user of issue.
                        self.alertUser()
                    }
                    
                    // Stop animating activity indicator and return UI elements to full visibility.
                    self.stopIndicatingActivity()
                })
            } else {
                
                // Update the existing user location via the shared OTMClient.
                OTMClient.sharedInstance().updateUserLocation({ (success, errorString) -> Void in
                    
                    // Check completion handler for update success.
                    if success {
                        println("User Location was updated.")
                        
                        // Update student locations on Udacity, then present UITabBarController.
                        self.returnToRootController()
                    } else {
                        
                        // Alert user about the details of the failure to create the location on Udacity.
                        self.alertMessage = errorString
                        
                        // Use a UIAlertController to inform user of issue.
                        self.alertUser()
                    }
                    
                    // Stop animating activity indicator and return UI elements to full visibility.
                    self.stopIndicatingActivity()
                })
            }
        } else {
            self.previousLabel.text = "Please try again."
            
            // Alert the user that the text field was empty, so try again.
            self.alertMessage = "The Text Field was empty. Please enter a URL such as www.google.com"
            
            // Use a UIAlertController to inform user of issue.
            self.alertUser()
        }
        
    }
    
    // Set the center and region of the map view.
    func centerMapOnLocation(location: CLLocation) {
        println("Centering Map.")
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // Set the map view location of the shared OTMClient.
    func setCenterLocation() {
        OTMClient.sharedInstance().myLocation = CLLocation(latitude: self.userLocation!.latitude, longitude: self.userLocation!.longitude)
    }
    
    // Update student locations on Udacity, then present UITabBarController.
    func returnToRootController() {
        println("Preparing to return to Map View Controller.")
        
        // Fetch dictionaries for all student locations on Udacity site.
        OTMClient.sharedInstance().getStudentLocations({ (success, errorString) -> Void in
            
            // Check completion handler for success.
            if success {
                
                println("Done Getting Student Locations")
                
                // Make sure there is no error.
                if (errorString == nil) {
                    
                    // Stop animating activity indicator and return UI elements to full visibility.
                    self.stopIndicatingActivity()
                    
                    println("Retrieved \(OTMClient.sharedInstance().students.count) Student Locations.")
                    
                    // Set the map view location for the return to UITabBarController.
                    self.setCenterLocation()
                    
                    // Create a pin datum to be added to the annotations on UITabBarController.
                    // Store the data on the shared OTMClient.
                    OTMClient.sharedInstance().pinDatum = PinData(title: "\(self.userLocation!.firstName) \(self.userLocation!.lastName)", urlString: "\(self.userLocation!.mediaURL)", coordinate: self.coordinates!)
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        // Create an instance of UITabBarController on storyboard.
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UITabBarController") as! UITabBarController
                        
                        // Present the UITabBarController.
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                } else {
                    
                    // Alert user of the fetch failure details.
                    self.alertMessage = errorString
                    
                    // Use a UIAlertController to inform user of issue.
                    self.alertUser()
                }
            }
        })
    }
    
    // Reveal and hide various UI elements.
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
    
    // Start animating activity indicator and fade some UI elements.
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
    
    // Stop animating activity indicator and return UI elements to full visibility.
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
    
    // Adjust location variables as location manager shows current locations were updated.
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        // Get location details as strings.
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            
            // Check if there was an error.
            if (error != nil) {
                
                // Alert user of the error details.
                var errorString = "Reverse geocoder failed with error: " + error.localizedDescription
                self.alertMessage = errorString
                
                // Use a UIAlertController to inform user of issue.
                self.alertUser()
                
                // Make error visible on page as well for when alert is dismissed.
                self.previousLabel.text = errorString
                return
            }
            
            // Check that there is at least one location in the placemarks array.
            if placemarks.count > 0 {
                
                self.locationManager.stopUpdatingLocation()
                
                // Set self.placemark for convenience.
                self.placemark = placemarks[0] as! CLPlacemark
                
                if let place = self.placemark {
                    
                    // Create a string of the current location details.
                    // Assign the string to the text field.
                    self.textField.text = "\(place.locality), \(place.administrativeArea)  \(place.country)"
                    
                    println(place.locality)
                    println(place.administrativeArea)
                    println(place.postalCode)
                    println(place.country)
                }
            }
        })
    }
    
    // Adjust location variables in map view as location manager shows authorization status changed.
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.mapView.showsUserLocation = (status == .AuthorizedAlways)
    }
    
    // Alert user the location manager shows it did fail.
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        // Alert user to the error details.
        self.alertMessage = "Error while updating location " + error.localizedDescription
        
        // Use a UIAlertController to inform user of issue.
        self.alertUser()
        
        // Allow the user to see the error even after alert is dismissed.
        previousLabel.text = self.alertMessage
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
    
    // Check the authorization status of the location manager.
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    
}
