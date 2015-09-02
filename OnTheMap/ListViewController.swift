//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/16/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var alertMessage: String?
    var navBarButtonItems = [UIBarButtonItem]()
    var students:[StudentLocation] = [StudentLocation]()
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // One right nav button for updating array of student locations
    var refreshButtonItem: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshStudentLocations")
    }
    
    // Another right nav button for setting user's location
    var userLocationButtonItem: UIBarButtonItem {
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
        
        println("Table View did load.")
        
        // Set self as the table view delegate.
        tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("Table View will appear.")
        
        // Set array of students to shared students.
        self.students = OTMClient.sharedInstance().students
        
        // Update the data for table view.
        self.tableView.reloadData()
    }
    
    @IBAction func logOut(sender: AnyObject) {
        OTMClient.sharedInstance().loggedIn = false
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // Return the section row count.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.students.count
    }
    
    // Return the formatted cell.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get a reusable cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell") as! UITableViewCell
        
        // Use the appropriate student location.
        let studentLocation = students[indexPath.row]
        
        // Set the cell features.
        cell.textLabel!.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.detailTextLabel!.text = studentLocation.mediaURL
        
        return cell
    }
    
    // Handle a row selection.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Create an instance of WebViewController for storyboard.
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        
        // Create an NSURL from the mediaURL string of the selected location, if one exists.
        if let url = NSURL(string: students[indexPath.row].mediaURL) {
            
            // Open url in default browser.
            UIApplication.sharedApplication().openURL(url)
            
            // Set request details.
//            detailController.urlRequest = NSURLRequest(URL: url)
//            detailController.authenticating = false
//            
//            // Present the WebViewController.
//            self.presentViewController(detailController, animated: true, completion: nil)
        } else {
            
            // Alert the user that the mediaURL string of the selected location had an issue.
            self.alertMessage = "URL was not well formed."
            
            // Use a UIAlertController to inform user of issue.
            self.alertUser()
        }
    }
    
    // Update the student location data source.
    func refreshStudentLocations() {
        
        // Retrieve all the student locations from Udacity.
        OTMClient.sharedInstance().getStudentLocations { (success, errorString) -> Void in
            
            // Check completion handler for success.
            if success {
                println("Refreshed")
                
                // Set array of students to shared students.
                self.students = OTMClient.sharedInstance().students
                
                println("Retrieved \(self.students.count) Student Locations.")
                println("Reloading Data.")
                
                // Update the data source.
                self.tableView.reloadData()
            } else {
                
                // Alert the user that the retrieval failed.
                println("Couldn't refresh Student Locations.")
                
                // Explain the reason for the failure.
                self.alertMessage = errorString
                
                // Use a UIAlertController to inform user of issue.
                self.alertUser()
            }
        }
    }
    
    // Segue to allow the user to set / update their location for Udacity.
    func segueToFindLocation() {
        println("Preparing to segue to FindLocation.")
        
        // Create an instance of FindLocationViewController on storyboard.
        let locationController = self.storyboard!.instantiateViewControllerWithIdentifier("FindLocationViewController") as! FindLocationViewController
        
        // Present the FindLocationViewController.
        self.presentViewController(locationController, animated: true, completion: nil)
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

