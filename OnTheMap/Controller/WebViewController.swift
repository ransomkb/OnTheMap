//
//  WebViewController.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/28/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import UIKit

// Use this to view web content via urls.
class WebViewController: UIViewController, UIWebViewDelegate {
    
    var authenticating: Bool = true
    var urlRequest: NSURLRequest? = nil
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set self as the web view delegate.
        webView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the page title.
        self.navigationItem.title = "Viewing Web Page"
        
        // Check if page is being used to authenticate with Udacity.
        if authenticating {
            
            // Create a standard Cancel and make it a right nav button
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAuth")
        } else {
            
            // Set the right nav button to nil as not authenticating.
            self.navigationItem.rightBarButtonItem = nil
        }
        
        // Load the requested URL if it is not nil.
        if urlRequest != nil {
            self.webView.loadRequest(urlRequest!)
        }
    }
    
    // Close this page and return to either UITabBarController or the log in view controller.
    @IBAction func closeWebView(sender: UIBarButtonItem) {
        
        // Check shared OTMClient if logged in.
        if OTMClient.sharedInstance().loggedIn {
            
            // Create instance of UITabBarController on storyboard.
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UITabBarController") as! UITabBarController
            
            // Present the UITabBarController.
            self.presentViewController(controller, animated: true, completion: nil)
        } else {
            
            // Create instance of LoginViewController on storyboard.
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            
            // Present the LoginViewController.
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // Dismiss this view controller if the Cancel button is pushed.
    func cancelAuth() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
