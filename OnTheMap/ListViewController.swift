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
    
    //let manager: ManagerTabBarController = ManagerTabBarController()
    
    var alertMessage: String?
    var navBarButtonItems = [UIBarButtonItem]()
    var students:[StudentLocation] = [StudentLocation]()

    //@IBOutlet weak var navigationItem: UINavigationItem!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var refreshButtonItem: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshStudentLocations")
    }
    
    var userLocationButtonItem: UIBarButtonItem {
        let pinImage = UIImage(named: "pin")
        //pinImage?.size = CGSize(width: 20, height: 20)
        return UIBarButtonItem(image: pinImage, style: .Plain, target: self, action: "segueToFindLocation")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var itNum = 0
        let navIts = self.navigationBar.items
        for i in navIts {
            println("\(i) is position \(itNum)")
        }
        
        var navItem:UINavigationItem = self.navigationBar.items[0] as! UINavigationItem
        navBarButtonItems = [self.refreshButtonItem, self.userLocationButtonItem]
        navItem.rightBarButtonItems = navBarButtonItems
        
        println("Table View did load.")
        tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("Table View will appear.")
        self.students = OTMClient.sharedInstance().students
        
        //probably do not need this
        var locID = 0
        println("Show students:")
        for loc in self.students {
            ++locID
            println("\(locID) \(loc.objectID) \(loc.firstName) \(loc.lastName) \(loc.mediaURL)")
        }
        
        self.tableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell") as! UITableViewCell
        let studentLocation = students[indexPath.row]
        cell.textLabel!.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.detailTextLabel!.text = studentLocation.mediaURL
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        
        if let url = NSURL(string: students[indexPath.row].mediaURL) {
            detailController.urlRequest = NSURLRequest(URL: url)
            detailController.authenticating = false
            self.presentViewController(detailController, animated: true, completion: nil)
        } else {
            self.alertMessage = "URL was not well formed."
            self.alertUser()
        }
    }
    
    
    func refreshStudentLocations() {
        OTMClient.sharedInstance().getStudentLocations { (success, errorString) -> Void in
            if success {
                println("Refreshed")
                self.students = OTMClient.sharedInstance().students
                println("Retrieved \(self.students.count) Student Locations.")
                println("Reloading Data.")
                self.tableView.reloadData()
                //self.getStudentLocations()
            } else {
                println("Couldn't refresh Student Locations.")
                self.alertMessage = errorString
                self.alertUser()
            }
        }
    }
    
    func segueToFindLocation() {
        println("Preparing to segue to FindLocation.")
        
        let locationController = self.storyboard!.instantiateViewControllerWithIdentifier("FindLocationViewController") as! FindLocationViewController
        
        self.presentViewController(locationController, animated: true, completion: nil)
    }

    
    
//    @IBAction func refreshStudentLocations() {
//        println("Refreshing in List")
//        getStudentLocations()
//    }
    
    func getStudentLocations() {
        // Moved: Did Call this in the completion handler to ensure order of operations
        OTMClient.sharedInstance().getStudentLocations({ (success, errorString) -> Void in
            if success {
                println("Done Getting Student Locations")
                if (errorString == nil) {
                    self.students = OTMClient.sharedInstance().students
                    println("Retrieved \(self.students.count) Student Locations.")
                    println("Reloading Data.")
                    self.tableView.reloadData()
                } else {
                    println("\(errorString!)")
                    self.alertMessage = errorString
                    self.alertUser()
                }
            }
        })
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
    
    @IBAction func logOut(sender: AnyObject) {
        OTMClient.sharedInstance().loggedIn = false
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }

    
}

