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
        
        // Check that user ID text field is empty.
        if let userID = emailTextField.text {
            if userID.isEmpty {
                
                // Alert user that field is empty and ask them to complete field.
                self.alertMessage = "Please enter an email address for the User ID."
                self.alertUser()
            } else {
                
                // Check to see if password field is emplty.
                if let password = passwordTextField.text {
                    if password.isEmpty {
                        
                        // Alert user that field is empty and ask them to complete field.
                        self.alertMessage = "Please enter a password."
                        self.alertUser()
                    } else {
                        
                        // Set userID and password variables, then authenticate.
                        OTMClient.sharedInstance().userID = "ransomkb@icloud.com" //userID
                        OTMClient.sharedInstance().password = "Okonomiyuki80" //password
                        OTMClient.sharedInstance().authenticateWithLogIn(self, completionHandler: { (success, errorString) -> Void in
                            
                            if success {
                                self.activityIndicatorView.stopAnimating()
                                OTMClient.sharedInstance().loggedIn = true
                                
                                println("Authentication with Log In was successful!")
                                println("Account Key: \(OTMClient.sharedInstance().accountKey!)")
                                println("Last Name: \(OTMClient.sharedInstance().lastName!)")
                                println("First Name: \(OTMClient.sharedInstance().firstName!)")
                                
                                // Segue to UITabBarController.
                                println(" Prepare to segue.")
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UITabBarController") as! UITabBarController
                                    self.presentViewController(controller, animated: true, completion: nil)
                                }
                            } else {
                                
                                // Alert user that there was some error when authenticating log in data.
                                dispatch_async(dispatch_get_main_queue(), {
                                    println(errorString!)
                                    self.alertMessage = errorString!
                                    self.alertUser()
                                }
                            )}
                        })
                    }
                }
            }
        }
        
        activityIndicatorView.stopAnimating()
    }
    
    // Allow user to create a Udacity account by clicking this button.
    @IBAction func signUp(sender: UIButton) {
        
        // Prepare to open a WebViewController to Udacity sign up page.
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        
        let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup")
        detailController.urlRequest = NSURLRequest(URL: url!)
        detailController.authenticating = false
        
        self.presentViewController(detailController, animated: true, completion: nil)
    }
    
//  seems like it is not needed
//    func completeLogin() {
//        dispatch_async(dispatch_get_main_queue(), {
//            self.debugTextLabel.text = ""
//            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UITabBarController") as! UITabBarController
//            self.presentViewController(controller, animated: true, completion: nil)
//        })
//    }
    
    // Alert user to any messages and issues.
    func alertUser() {
        dispatch_async(dispatch_get_main_queue(), {
            
            // Stop animating log in activity indicator
            self.activityIndicatorView.stopAnimating()
            
            let alertController = UIAlertController(title: "Problem", message: self.alertMessage!, preferredStyle: .Alert)
            
            // Set the message.
            if let message = self.alertMessage {
                alertController.message = message
            }
            
            // Allow an ok button to dismiss alert.
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
                //IMPORTANT: dismissing will dismiss the underlying controller, not the alert action only.
                //self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    // Maybe don't need
//    func displayError(errorString: String?) {
//        dispatch_async(dispatch_get_main_queue(), {
//            if let errorString = errorString {
//                self.debugTextLabel.text = errorString
//            }
//        })
//    }
    
    // Allow the user to dismiss the keyboard.
    func addKeyboardDismissRecognizer() {
        if let tapper = tapRecognizer {
            self.view.addGestureRecognizer(tapper)
        }
    }
    
    // Remove recognizer before the segue.
    func removeKeyboardDismissRecognizer() {
        if let tapper = tapRecognizer {
            self.view.removeGestureRecognizer(tapper)
        }
    }
    
    // Deal with a tap.
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
