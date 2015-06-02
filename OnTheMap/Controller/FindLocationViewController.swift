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
    
    var alertMessage:String?
    
    var userLocation: StudentLocation?
    var locationManager = CLLocationManager()
    var placemark: CLPlacemark!
    
    @IBOutlet weak var textField: UITextField!
        
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var previousLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        OTMClient.sharedInstance().searchForAStudentLocation({ (success, errorString) -> Void in
            if success {
                println("Succeeded in Searching.")
                if (errorString == nil) {
                    println("Retrieved Existing User's Location.")
                    self.userLocation = OTMClient.sharedInstance().userLocation
                } else {
                    println("\(errorString!)")
                    let locDictionary = OTMClient.createUserLocation()
                    OTMClient.sharedInstance().userLocation = StudentLocation(dictionary: locDictionary as! [String : AnyObject])
                    println("myLocation dictionary: \(OTMClient.sharedInstance().userLocation?.studentDictionary)")
                    self.userLocation = OTMClient.sharedInstance().userLocation
                }
            }
        })

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func submitMyLocationData(sender: UIButton) {
        
        OTMClient.sharedInstance().updateUserLocation({ (success, errorString) -> Void in
            if success {
                println("User Location was updated.")
            }
        })

    }
    
    @IBAction func findMyLocation(sender: UIButton) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
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
