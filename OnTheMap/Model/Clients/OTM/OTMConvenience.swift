//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/16/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import UIKit

// Provides convenience methods for the OTMClient that handles the RESTful request preparation and the response data after JSON parsing
extension OTMClient {
    
    // Authenticate Log In Data, then Get User Data.
    func authenticateWithLogIn(hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        println("Started Authentication with Log In.")
        // Get an account key from Udacity.
        self.getAccountKey() { (success, errorString) -> Void in
            if success {
                println("Got Account Key. Time to get User Data.")
                // Account key was gotten, so get user data.
                self.getUserData() { (success, errorString) -> Void in
                    if success {
                        println("Got User Data.")
                        // Inform Controller of success.
                        completionHandler(success: success, errorString: errorString)
                    } else {
                        // Inform controller that failed to get user data
                        completionHandler(success: success, errorString: errorString)
                    }
                }
            } else {
                // Inform controller that log in data failed to get an account key
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    // Get an account key from Udacity using log in data.
    func getAccountKey(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        println("Getting Account Key.")
        // Create a string of parameters for RESTful request.
        var parameters = OTMClient.substituteKeyInMethod(OTMClient.URLKeys.AuthenticationDictionary, key: OTMClient.URLKeys.UID, value: self.userID)
        // Replace variables in parameter with actual data.
        parameters = OTMClient.substituteKeyInMethod(parameters!, key: OTMClient.URLKeys.PWD, value: self.password)
        println("Before Task parameters: \(parameters!)")
        
        // Create a dictionary to hold values for request.
        var requestValues = [[String:String]]()
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ApplicationJSON, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.Accept])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ApplicationJSON, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ContentType])
        
        // Use the POST method for RESTful request.
        taskForPOSTMethod(true, baseURL:BaseURLs.UdacityBaseURLSecure, method: OTMClient.Methods.Session, parameters: parameters!, requestValues: requestValues) { (JSONResult, error) -> Void in
            
            if let error = error {
                
                // Report JSONResult error details in completion handler.
                completionHandler(success: false, errorString: "Error: Log In Failed. (Account Key / Session ID). \(error.localizedDescription)")
            } else {
                
                // Get parsed JSON info.
                if let status = JSONResult[JSONResponseKeys.Status] as? NSNumber {
                    if let JSONError: AnyObject? = JSONResult[JSONResponseKeys.Error] {
                        
                        // Use completion handler to return error info as string.
                        completionHandler(success: false, errorString: "Status: \(status), Error: \(JSONError!)")
                    }
                } else {
                    println("Task, no Error")
                    
                    // Check if account exists.
                    if let account = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Account) as? NSDictionary  {
                        println("Account Dictionary: \(account)")
                        
                        // Check if received an account key.
                        if let accountK = account[OTMClient.JSONResponseKeys.AccountKey] as? String {
                            
                            println("Account Key: \(accountK)")
                            self.accountKey = accountK
                            if let session = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Session) as? NSDictionary {
                                println("Session Dictionary: \(session)")
                                
                                // Check if there is a session id.
                                if let id = session[OTMClient.JSONResponseKeys.SessionID] as? String {
                                    println("Session ID: \(id)")
                                    self.sessionID = id
                                    
                                    // Use completion handler to report setting of sessionID.
                                    completionHandler(success: true, errorString: nil)

                                } else {
                                    
                                    // Use completion handler to report error: no key called id in JSON.
                                    let eString = "Sorry, JSONResult did not have key: id."
                                    println(eString)
                                    completionHandler(success: false, errorString: eString)
                                }
                            } else {
                                
                                // Use completion handler to report error: no key called session in JSON.
                                let eString = "Sorry, JSONResult did not have key: session."
                                println(eString)
                                completionHandler(success: false, errorString: eString)
                            }

                        } else {
                            
                            // Use completion handler to report error: no key called key in JSON.
                            let eString = "Sorry, JSONResult did not have key: key."
                            println(eString)
                            completionHandler(success: false, errorString: eString)
                        }
                    } else {
                        
                        // Use completion handler to report error: no key called account in JSON.
                        let eString = "Sorry, JSONResult did not have key: account."
                        println(eString)
                        completionHandler(success: false, errorString: eString)
                    }
                    
                    
                }
            }
        }
    }
    
    // Get user data using the sessionID variable.
    func getUserData(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        println("Getting User Data")
        
        // Use the GET method for a RESTful request.
        taskForGETMethod(true, baseURL: BaseURLs.UdacityBaseURLSecure, method: Methods.UsersUserID, parameters: "/"+self.accountKey!, requestValues: []) { (JSONResult, error) -> Void in
            
            if let error = error {
                
                // Report JSONResult error details in completion handler.
                completionHandler(success: false, errorString: "Error: Search failed. (Get User Data). \(error.localizedDescription)")
            } else {
                
                println("No Error in Search")
                
                // Set last and first name variables using the parsed JSON data.
                if let user = JSONResult.valueForKey(OTMClient.JSONResponseKeys.User) as? [String:AnyObject] {
                    OTMClient.sharedInstance().lastName = user[OTMClient.JSONResponseKeys.LastName] as? String
                    OTMClient.sharedInstance().firstName = user[OTMClient.JSONResponseKeys.FirstName] as? String
                    
                    completionHandler(success: true, errorString: nil)
                } else {
                    
                    // Use completion handler to report error: no key called user in JSON.
                    completionHandler(success: false, errorString: "Got JSON data, but no key called user.")
                }
            }
        }
    }
    
    // Search for a dictionary with student location details on Udacity site.
    func searchForAStudentLocation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // Create a string of parameters for RESTful request.
        var parameters = OTMClient.substituteKeyInMethod(OTMClient.URLKeys.QueryStudentLocation, key: OTMClient.URLKeys.Key, value: self.accountKey!)
        println("SearchLocation parameters: \(parameters!)")
        
        // Create a dictionary to hold values for request.
        var requestValues = [[String:String]]()
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ParseApplicationID, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ParseAppIDField])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.RESTAPIKey, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.RESTAPIField])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ApplicationJSON, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ContentType])
        
        // Use the GET method for a RESTful request.
        taskForGETMethod(false, baseURL:BaseURLs.ParseBaseURLSecure, method: OTMClient.Methods.StudentLocation, parameters: parameters!, requestValues: requestValues) { (JSONResult, error) -> Void in
            
            
            if let error = error {
                
                // Report JSONResult error details in completion handler.
                completionHandler(success: false, errorString: "Error: Search failed. (Existing Location). \(error.localizedDescription)")
            } else {
                println("No Error in Search")
                
                // Check if dictionary of results exists in parsed JSON data.
                if let results = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Results) as? [[String:AnyObject]] {
                    println("Got User's Existing StudentLocation.")
                    
                    // Check if dictionary of results is empty.
                    if results.count < 0 {
                        
                        // Create a StudentLocation object for the user's location from results dictionary.
                        self.userLocation = StudentLocation(dictionary: results[0])
                        
                        // Use completion handler to report successful creation.
                        completionHandler(success: true, errorString: nil)
                    } else {
                        var eString = "results count is 0 or less."
                        
                        // Use completion handler to report unlikely situation: there is a dictionary of results, but it is empty.
                        completionHandler(success: true, errorString: eString)
                    }
                } else {
                    
                    // Use completion handler to report no error, but no student locations returned for user, so probably first time.
                    var eString = "User's Existing StudentLocation not found."
                    completionHandler(success: true, errorString: eString)
                }
            }
        }
    }
    
    // Fetch dictionaries for all student locations on Udacity site.
    func getStudentLocations(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        println("Getting Student Locations")
        
        // Get maximum number of student locations.
        var parameters = "?limit=500"
        
        // Create a dictionary to hold values for request.
        var requestValues = [[String:String]]()
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ParseApplicationID, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ParseAppIDField])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.RESTAPIKey, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.RESTAPIField])
        
        // Use the GET method for a RESTful request.
        taskForGETMethod(false, baseURL: BaseURLs.ParseBaseURLSecure, method: OTMClient.Methods.StudentLocation, parameters: parameters, requestValues: requestValues) { (JSONResult, error) -> Void in
            
            if let error = error {
                
                // Report JSONResult error details in completion handler.
                completionHandler(success: false, errorString: "Error: Search failed. (Student Locations). \(error.localizedDescription)")
            } else {
                println("No Error in Search")
                
                // Check if dictionary of results exists in parsed JSON data.
                if let results = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Results) as? [[String:AnyObject]] {
                    println("Got Student Locations.")
                    
                    // Create an array of StudentLocation objects for the locations from results dictionary.
                    self.students = StudentLocation.studentLocationsFromResults(results)
                    
                    // Use completion handler to report successful creation.
                    completionHandler(success: true, errorString: nil)
                } else {
                    
                    // Use completion handler to report JSON error.
                    var eString = "JSON Error (Student Locations)."
                    completionHandler(success: true, errorString: eString)
                }
            }

        }
    }
    
    // Create a user location on the Udacity site.
    func createUserLocation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        println("Creating User Location")
        
        // Create a string for updating dictionary of location data for user on Udacity site.
        let updateString = OTMClient.sharedInstance().userLocation?.buildUpdateString()
        println("POST parameters: \(updateString)")
        
        // Create a dictionary to hold values for request.
        var requestValues = [[String:String]]()
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ParseApplicationID, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ParseAppIDField])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.RESTAPIKey, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.RESTAPIField])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ApplicationJSON, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ContentType])
        
        // Use the POST method for RESTful request.
        taskForPOSTMethod(false, baseURL: BaseURLs.ParseBaseURLSecure, method: Methods.StudentLocation, parameters: updateString!, requestValues: requestValues) { (JSONResult, error) -> Void in
            
            println("After POSTing")
            if let error = error {
                
                // Report JSONResult error details in completion handler.
                completionHandler(success: false, errorString: "Error: POST failed. (Create Locations). \(error.localizedDescription)")
            } else {
                println("No Error in Creation POST. Checking JSON")
                println("Object ID: \(JSONResult[StudentLocationKeys.ObjectID]) was created at: \(StudentLocationKeys.CreatedAt)")
                
                // Use completion handler to report successful creation.
                completionHandler(success: true, errorString: nil)
            }
        }
    }
    
    // Update the user's location on the Udacity site.
    func updateUserLocation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        println("Updating User Location.")
        
        // Create a string for updating dictionary of location data for user on Udacity site.
        let objectId = OTMClient.sharedInstance().userLocation?.objectID
        let updateString = OTMClient.sharedInstance().userLocation!.buildUpdateString()
        println("PUT parameters: \(updateString)")
        
        // Create a dictionary to hold values for request.
        var requestValues = [[String:String]]()
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ParseApplicationID, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ParseAppIDField])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.RESTAPIKey, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.RESTAPIField])
        requestValues.append([OTMClient.RequestKeys.Value : OTMClient.RequestKeys.ApplicationJSON, OTMClient.RequestKeys.Field : OTMClient.RequestKeys.ContentType])

        // Use the PUT method for RESTful request.
        taskForPUTMethod(false, baseURL: BaseURLs.ParseBaseURLSecure, method: Methods.StudentLocation, fileName: "/"+objectId!, parameters: updateString, requestValues: requestValues) { (JSONResult, error) -> Void in
            
            println("After PUTting")
            if let error = error {
                
                // Report JSONResult error details in completion handler.
                completionHandler(success: false, errorString: "Error: PUT failed. (Update Locations). \(error.localizedDescription)")
            } else {
                println("No Error in Update PUT. Checking JSON")
                println("User Location was updated at: \(JSONResult[StudentLocationKeys.UpdatedAt])")
                
                // Use completion handler to report successful update.
                completionHandler(success: true, errorString: nil)
            }
        }
    }
    
}

