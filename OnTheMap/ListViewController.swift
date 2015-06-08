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
    
    var students:[StudentLocation] = [StudentLocation]()

    @IBOutlet weak var pinButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println("Table View did load.")
        tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("Table View will appear.")
        self.students = OTMClient.sharedInstance().students
        
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
        
        let url = NSURL(string: students[indexPath.row].mediaURL)
        detailController.urlRequest = NSURLRequest(URL: url!)
        detailController.authenticating = false
        
        self.navigationController!.pushViewController(detailController, animated: true)
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

    
}

