//
//  FindLocationViewController.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/16/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class FindLocationViewController: UIViewController, UITextFieldDelegate {
    
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
                } else {
                    println("\(errorString!)")
                    let locDictionary = OTMClient.createUserLocation()
                    OTMClient.sharedInstance().myLocation = StudentLocation(dictionary: locDictionary as! [String : AnyObject])
                    println("myLocation dictionary: \(OTMClient.sharedInstance().myLocation?.studentDictionary)")
                }
            }
        })

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        

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
        
    }
    
}
