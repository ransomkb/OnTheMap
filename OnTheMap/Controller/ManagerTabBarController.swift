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
    
    @IBAction func logOutOfFacebook(sender: AnyObject) {
        // get a bool for logged in to FB from AppDelegate
        // if true, log out from FB and segue to login page
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
