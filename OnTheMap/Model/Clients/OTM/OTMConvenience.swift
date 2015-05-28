//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/16/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import UIKit

extension OTMClient {
    
    
    func authenticateWithLogIn(hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        println("Started Authentication with Log In.")
        self.getAccountKey() { (success, errorString) -> Void in
            if success {
                println("Got Account Key. Time to get User Data.")
                self.getUserData() { (success, errorString) -> Void in
                    if success {
                        println("Got User Data.")
                        completionHandler(success: success, errorString: errorString)
                    } else {
                        completionHandler(success: success, errorString: errorString)
                    }
                }
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    func getAccountKey(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        println("Getting Account Key.")
        var parameters = OTMClient.substituteKeyInMethod(OTMClient.URLKeys.AuthenticationDictionary, key: OTMClient.URLKeys.UID, value: self.userID!)
        parameters = OTMClient.substituteKeyInMethod(parameters!, key: OTMClient.URLKeys.PWD, value: self.password!)
        println("Before Task parameters: \(parameters!)")
        
        var requestValues = [[String:String]]()
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ApplicationJSON, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.Accept])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ApplicationJSON, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ContentType])
        
        taskForPOSTMethod(true, baseURL:BaseURLs.UdacityBaseURLSecure, method: OTMClient.Methods.Session, parameters: parameters!, requestValues: requestValues) { (JSONResult, error) -> Void in
            if let error = error {
                completionHandler(success: false, errorString: "Error: Log In Failed. (Account Key / Session ID)")
            } else {
                println("Task, no Error")
                if let account = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Account) as? NSDictionary  {
                    println("Account Dictionary: \(account)")
                    if let accountK = account[OTMClient.JSONResponseKeys.AccountKey] as? String {
                        //accountK = "1612749455"
                        println("Account Key: \(accountK)")
                        self.accountKey = accountK
                    } else {
                        println("Sorry, JSONResult did not have key: key.")
                    }
                } else {
                    println("Sorry, JSONResult did not have key: account.")
                }
                
                if let session = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Session) as? NSDictionary {
                    println("Session Dictionary: \(session)")
                    if let id = session[OTMClient.JSONResponseKeys.SessionID] as? String {
                        println("Session ID: \(id)")
                        self.sessionID = id
                    } else {
                        println("Sorry, JSONResult did not have key: id.")
                    }
                } else {
                    println("Sorry, JSONResult did not have key: session.")
                }
                
                completionHandler(success: true, errorString: nil)
            }
        }
    }
    
    func getUserData(completionHandler: (success: Bool, errorString: String?) -> Void) {
        println("Getting User Data")
        
        taskForGETMethod(true, baseURL: BaseURLs.UdacityBaseURLSecure, method: Methods.UsersUserID, parameters: "/"+self.accountKey!, requestValues: []) { (JSONResult, error) -> Void in
            
            if let error = error {
                completionHandler(success: false, errorString: "Error: Search failed. (Get User Data)")
            } else {
                println("No Error in Search")
                if let user = JSONResult.valueForKey(OTMClient.JSONResponseKeys.User) as? [String:AnyObject] {
                    self.lastName = user[OTMClient.JSONResponseKeys.LastName] as? String
                    self.firstName = user[OTMClient.JSONResponseKeys.FirstName] as? String
                    
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: "User Data Parsing failed.")
                }
            }
        }
    }
    
    func searchForAStudentLocation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        var parameters = OTMClient.substituteKeyInMethod(OTMClient.URLKeys.QueryStudentLocation, key: OTMClient.URLKeys.Key, value: self.accountKey!)
        println("SearchLocation parameters: \(parameters!)")
        
        var requestValues = [[String:String]]()
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ParseApplicationID, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ParseAppIDField])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.RESTAPIKey, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.RESTAPIField])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ApplicationJSON, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ContentType])
        
        taskForGETMethod(false, baseURL:BaseURLs.ParseBaseURLSecure, method: OTMClient.Methods.StudentLocation, parameters: parameters!, requestValues: requestValues) { (JSONResult, error) -> Void in
            if let error = error {
                completionHandler(success: false, errorString: "Error: Search failed. (Existing Location)")
            } else {
                println("No Error in Search")
                if let results = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Results) as? [[String:AnyObject]] {
                    println("Got User's Existing StudentLocation.")
                    self.students = StudentLocation.studentLocationsFromResults(results)
                    if self.students.isEmpty {
                        var eString = "User's Existing StudentLocation not found."
                        //println(eString)
                        completionHandler(success: true, errorString: eString)
                    } else {
                        self.myLocation = self.students[0]
                        completionHandler(success: true, errorString: nil)
                    }
                }
            }
        }
    }
    
    func getStudentLocations(completionHandler: (success: Bool, errorString: String?) -> Void) {
        println("Getting Student Locations")
        var parameters = "?limit=100"
        
        var requestValues = [[String:String]]()
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ParseApplicationID, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ParseAppIDField])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.RESTAPIKey, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.RESTAPIField])
        
        taskForGETMethod(false, baseURL: BaseURLs.ParseBaseURLSecure, method: OTMClient.Methods.StudentLocation, parameters: parameters, requestValues: requestValues) { (JSONResult, error) -> Void in
            if let error = error {
                completionHandler(success: false, errorString: "Error: Search failed. (Student Locations)")
            } else {
                println("No Error in Search")
                if let results = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Results) as? [[String:AnyObject]] {
                    println("Got Student Locations.")
                    self.students = StudentLocation.studentLocationsFromResults(results)
                    completionHandler(success: true, errorString: nil)
                } else {
                    var eString = "JSON Error (Student Locations)."
                    //println(eString)
                    completionHandler(success: true, errorString: eString)
                }
            }

        }
    }
    
    func updateUserLocation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        println("Updating User Location.")
        //var parsingError: NSError? = nil
        
        let objectId = OTMClient.sharedInstance().myLocation?.objectID
        let udateString = OTMClient.sharedInstance().myLocation!.buildUdateString()
        
        var parameters = "{\(udateString)}"
        //NSJSONSerialization.dataWithJSONObject(userLocation, options: NSJSONWritingOptions.PrettyPrinted, error: &parsingError)
        
        println("PUT parameters: \(parameters)")
        
        var requestValues = [[String:String]]()
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ParseApplicationID, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ParseAppIDField])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.RESTAPIKey, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.RESTAPIField])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ApplicationJSON, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ContentType])

//        taskForPUTMethod(false, baseURL: BaseURLs.ParseBaseURLSecure, method: Methods.StudentLocation, fileName: "/"+objectId!, parameters: parameters, requestValues: requestValues) { (result, error) -> Void in
//            <#code#>
//        }
    }
    
}

