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
    
    var newLocation: Bool? = true
    var alertMessage:String?
    
    var userLocation: StudentLocation?
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
        
        super.viewWillDisappear(animated)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func submitMyLocationData(sender: UIButton) {
        
        if let text = self.textField.text {
            
            self.userLocation!.mediaURL = text
            
            println("FindLocation userLocation dictionary: \(self.userLocation?.studentDictionary)")
            
            
            OTMClient.sharedInstance().updateUserLocation({ (success, errorString) -> Void in
                if success {
                    println("User Location was updated.")
                }
            })

        }
        self.findButton.hidden = false
        self.previousLabel.hidden = false
        self.messageLabel.hidden = false
        self.mapView.hidden = true
        self.submitButton.hidden = true
    }
    
    @IBAction func findMyLocation(sender: UIButton) {
        
        println("Finding My Location")
        let geoCoder = CLGeocoder()
        let addressString = self.textField.text
        
        geoCoder.geocodeAddressString(addressString, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
            if let anError = error {
                println("GeoCode Failed with Error: \(anError.localizedDescription)")
            } else if placemarks.count > 0 {
                let place = placemarks[0] as! CLPlacemark
                let location = place.location
                self.coordinates = location.coordinate
                self.userLocation?.latitude = self.coordinates!.latitude
                self.userLocation?.longitude = self.coordinates!.longitude
                self.userLocation?.mapString = addressString
                println("\(self.userLocation!.mapString) ; \(self.userLocation!.latitude) \(self.userLocation!.longitude)")
                
                
                self.pinDatum = PinData(title: "\(self.userLocation?.firstName) \(self.userLocation?.lastName)", urlString: "\(self.userLocation?.mediaURL)", coordinate: self.coordinates!)
                self.mapView.addAnnotation(self.pinDatum)
                
                self.findButton.hidden = true
                self.previousLabel.hidden = true
                self.messageLabel.hidden = true
                self.mapView.hidden = false
                self.submitButton.hidden = false
            }
        })
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            if (error != nil) {
                var errorString = "Reverse geocoder failed with error: " + error.localizedDescription
                println(errorString)
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
        println(errorString)
        previousLabel.text = errorString
    }
    
//    func showMap() {
//        let place = MKPlacemark(coordinate: self.coordinates!, addressDictionary: nil)
//        let mapItem = MKMapItem(placemark: place)
//        mapItem.o
//    }
    
    func alertUser() {
        let alertController = UIAlertController()
        alertController.title = "Problem"
        if let message = alertMessage {
            alertController.message = message
        }
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    
}
