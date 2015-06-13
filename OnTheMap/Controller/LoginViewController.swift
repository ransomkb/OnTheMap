//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/16/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var alertMessage: String?
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    /* Based on student comments, this was added to help with smaller resolution devices */
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var debugTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Drop keyboard when Return is tapped.
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginUser(sender: AnyObject) {
        println("Log in button was clicked.")
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.activityIndicatorView.startAnimating()
        }
        
        
        if let userID = emailTextField.text {
            if userID.isEmpty {
                // send message to user to complete field
                self.alertMessage = "Please enter an email address for the User ID."
                self.alertUser()
            } else {
                if let password = passwordTextField.text {
                    if password.isEmpty {
                        // send message to user to complete field
                        self.alertMessage = "Please enter a password."
                        self.alertUser()
                    } else {
                        OTMClient.sharedInstance().userID = "ransomkb@icloud.com" //userID
                        OTMClient.sharedInstance().password = "Okonomiyuki80" //password
                        OTMClient.sharedInstance().authenticateWithLogIn(self, completionHandler: { (success, errorString) -> Void in
                            
                            if success {
                                self.activityIndicatorView.stopAnimating()
                                
                                println("Authentication with Log In was successful!")
                                println("Account Key: \(OTMClient.sharedInstance().accountKey!)")
                                println("Last Name: \(OTMClient.sharedInstance().lastName!)")
                                println("First Name: \(OTMClient.sharedInstance().firstName!)")
                                
                                println(" Prepare to segue.")
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
                                    self.presentViewController(controller, animated: true, completion: nil)
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue(), {
                                    println(errorString!)
                                    self.alertMessage = errorString!
                                    self.alertUser()
                                    //self.displayError(errorString)
                                }
                            )}
                        })
                    }
                }
            }
        }
        
        activityIndicatorView.stopAnimating()
    }
    
    @IBAction func signUp(sender: UIButton) {
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        
        let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup")
        detailController.urlRequest = NSURLRequest(URL: url!)
        detailController.authenticating = false
        
        self.presentViewController(detailController, animated: true, completion: nil)
    }
        
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugTextLabel.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func alertUser() {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicatorView.stopAnimating()
            
            let alertController = UIAlertController(title: "Problem", message: self.alertMessage!, preferredStyle: .Alert)
            
            if let message = self.alertMessage {
                alertController.message = message
            }
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    // Maybe don't need
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.debugTextLabel.text = errorString
            }
        })
    }
    
    func addKeyboardDismissRecognizer() {
        if let tapper = tapRecognizer {
            self.view.addGestureRecognizer(tapper)
        }
    }
    
    func removeKeyboardDismissRecognizer() {
        if let tapper = tapRecognizer {
            self.view.removeGestureRecognizer(tapper)
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
}


/* This code has been added in response to student comments */
extension LoginViewController {
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y = -lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y = 0.0
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}
