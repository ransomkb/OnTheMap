//
//  WebViewController.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/28/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var authenticating: Bool = true
    var urlRequest: NSURLRequest? = nil
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Viewing Web Page"
        
        if authenticating {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAuth")
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        if urlRequest != nil {
            self.webView.loadRequest(urlRequest!)
        }
    }
    
    // To be completed for Facebook Authentication
    
    // Appropriate UIWebViewDelegate for this login
//    func webViewDidFinishLoad(webView: UIWebView) {
//        
//        // Check for URL that indicates user consent has been given
//        if (webView.request!.URL!.absoluteString! == "\(TMDBClient.Constants.AuthorizationURL)\(requestToken!)/allow") {
//            println("Got to webViewDidFinishLoad:\(TMDBClient.Constants.AuthorizationURL)/allow")
//            println("\(requestToken!)")
//            
//            // Found, so dismiss TMDBAuthViewController
//            self.dismissViewControllerAnimated(true, completion: { () -> Void in
//                self.completionHandler!(success: true, errorString: nil)
//            })
//        }
//    }

    
    func cancelAuth() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
