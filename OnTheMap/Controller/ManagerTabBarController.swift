//
//  ManagerTabBarController.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/16/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import UIKit

class ManagerTabBarController: UITabBarController {
    
    
    //var navBarButtonItems = [UIBarButtonItem]()

    // probably don't need this outlet
    //@IBOutlet weak var logOutButton: UIBarButtonItem!
    //@IBOutlet weak var refreshButton: UIBarButtonItem!
    //@IBOutlet weak var userLocationButton: UIBarButtonItem!
    
//    var refreshButtonItem: UIBarButtonItem {
//        return UIBarButtonItem(barButtonSystemItem: .Refresh, target: selectedViewController, action: "refreshStudentLocations")
//    }
//    
//    var userLocationButtonItem: UIBarButtonItem {
//        let pinImage = UIImage(named: "pin")
//        //pinImage?.size = CGSize(width: 20, height: 20)
//        return UIBarButtonItem(image: pinImage, style: .Plain, target: selectedViewController, action: "segueToFindLocation")
//    }
//    
//    func refreshStudentLocations() {
//        OTMClient.sharedInstance().getStudentLocations { (success, errorString) -> Void in
//            if success {
//                println("Refreshed")
//                self.viewWillAppear(true)
//            } else {
//                println("Couldn't refresh Student Locations.")
//            }
//        }
//    }
//    
//    func segueToFindLocation() {
//        println("Preparing to segue to FindLocation.")
//        
//        let locationController = self.storyboard!.instantiateViewControllerWithIdentifier("FindLocationViewController") as! FindLocationViewController
//        
//        self.presentViewController(locationController, animated: true, completion: nil)
//    }
//
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        println("ManagerTabBarController view will appear.")
//        // fix this so can refresh
//        //let view = selectedViewController
//        
//        
//        //refreshButtonItem = refreshBarButtonItem()
//        //navBarButtonItems = [self.refreshButtonItem, self.userLocationButtonItem]
//        //self.navigationItem.rightBarButtonItems = navBarButtonItems
//        //self.navigationItem.leftBarButtonItem = self.logOutButton
//        // probably don't need this button placed in code
//        
//        //view?.viewWillAppear(true)
//    }
//    
//    
//    @IBAction func logOut(sender: AnyObject) {
//        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
//        self.presentViewController(controller, animated: true, completion: nil)
//    }
    
}
