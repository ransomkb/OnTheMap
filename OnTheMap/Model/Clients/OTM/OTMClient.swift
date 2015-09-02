//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/16/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import MapKit


class OTMClient: NSObject {
    
    var loggedIn = false
    
    var session: NSURLSession
    
    var userID: String? = nil
    var password: String? = nil
    
    var accountKey: String? = nil
    var sessionID: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    var mapString: String? = "some city"
    var mediaURL: String? = "some url"
    var userLat: Double? = 36.9719
    var userLong: Double? = -122.0264
    
    var myLocation: CLLocation? = CLLocation(latitude: 39.50, longitude: -98.35)
    var userLocation: StudentLocation? = nil
    
    // Array of structs holding student location data.
    var students:[StudentLocation] = [StudentLocation]()
    
    // For updating and centering map after user location is set
    var pinDatum:PinData?
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // Create a task using the GET method; handle JSON response.
    func taskForGETMethod(udacity: Bool, baseURL: String, method: String, parameters: String, requestValues: [[String:String]], completionHandler: (result: AnyObject!, error: NSError?) -> Void ) -> NSURLSessionDataTask {
        
        // Create request from URL.
        let urlString = baseURL + method + parameters
        
        println("GET URL: \(urlString)")
        
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        // Add request values to dictionary if they are used in this request.
        if !requestValues.isEmpty {
            for dict in requestValues {
                request.addValue(dict["value"], forHTTPHeaderField: dict["field"]!)
            }
        }
        
        // Create a data task with a request for shared session; pass response data to JSON parser.
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, downloadError) -> Void in
            
            println("Starting GET task.")
            
            // Handle download error.
            if let error = downloadError {
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                println("No Error, Time to Parse newData.")
                
                var newData = data
                
                // Get a subset of the data to conform to Udacity requirements, if udacity Bool is true.
                if udacity {
                    println("udacity was true, so getting subset of data.")
                    /* subset response data! */
                    newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                }
                
                
                //println("JSONResult data: \(NSString(data: newData, encoding: NSUTF8StringEncoding)!)")
                
                // Send data to shared JSON parser.
                OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        })
        
        task.resume()
        
        return task
    }
    
    // Create a task using the POST method; handle JSON response.
    func taskForPOSTMethod(udacity: Bool, baseURL: String, method: String, parameters: String, requestValues: [[String:String]], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var jsonifyError: NSError? = nil
        
        // Create request from URL.
        let urlString = baseURL + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        
        // Add request values to dictionary if they are used in this request.
        for dict in requestValues {
            request.addValue(dict["value"], forHTTPHeaderField: dict["field"]!)
        }
        
        // Set HTTPBody of request
        request.HTTPBody = parameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Create a data task with a request for shared session; pass response data to JSON parser.
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, downloadError) -> Void in
            println("Starting POST Task")
            // Handle download error.
            if let error = downloadError {
                println("Task Download Error.")
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                println("No Error, Time to Parse newData.")
                
                var newData = data
                
                // Get a subset of the data to conform to Udacity requirements, if udacity Bool is true.
                if udacity {
                    println("udacity was true, so getting subset of data.")
                    /* subset response data! */
                    newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                }
                
                //println("JSONResult data: \(NSString(data: newData, encoding: NSUTF8StringEncoding)!)")
                
                // Send data to shared JSON parser.
                OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        })
        
        task.resume()
    
        return task
    }
    
    // Create a task using the PUT method; handle JSON response.
    func taskForPUTMethod(udacity: Bool, baseURL: String, method: String, fileName: String, parameters: String, requestValues: [[String:String]], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var jsonifyError: NSError? = nil
        
        // Create request from URL.
        let urlString = baseURL + method + fileName
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "PUT"
        
        // Add request values to dictionary if they are used in this request.
        for dict in requestValues {
            request.addValue(dict["value"], forHTTPHeaderField: dict["field"]!)
        }
        
        // Set HTTPBody of request
        request.HTTPBody = parameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Create a data task with a request for shared session; pass response data to JSON parser.
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, downloadError) -> Void in
            println("Starting PUT Task")
            
            // Handle download error.
            if let error = downloadError {
                println("Task Download Error.")
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                println("No Error, Time to Parse newData.")
                
                var newData = data
                
                // Get a subset of the data to conform to Udacity requirements, if udacity Bool is true.
                if udacity {
                    println("udacity was true, so getting subset of data.")
                    /* subset response data! */
                    newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                }
                
                println("JSONResult data: \(NSString(data: newData, encoding: NSUTF8StringEncoding)!)")
                // Send data to shared JSON parser.
                OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        })
        
        task.resume()
        
        return task
    }
    
    // Class method to parse JSON in NSData format from a response
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        println("Parsing")
        
        var parsingError: NSError? = nil
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        // Handle parsing error.
        if let error = parsingError {
            println("Parsing Error")
            NSLog("Error is: \(parsingError)");
            completionHandler(result: nil, error: error)
        } else {
            
            // Use completion handler to return the result from parsing the JSON
            println("No Parsing Error")
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    // Class method for replacing a variable with a string value in a task method
    class func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("\(key)") != nil {
            return method.stringByReplacingOccurrencesOfString("\(key)", withString: value)
        } else {
            return nil
        }
    }

    // Class method providing more usable error messages.
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        // Ensure JSON data error.
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String:AnyObject] {
            
            // Convert the error message into a more readable format.
            if let errorMessage = parsedResult[JSONResponseKeys.Message] as? String {
                let errorCode = parsedResult[JSONResponseKeys.Code] as? Int
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Flickr Error", code: errorCode!, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    // Class method for escaping values in parameters for a RESTFul request
    class func escapedParameters(parameters: [String:AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            let stringValue = "\(value)"
            
            // Escape the values by using percent encoding.
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    // Create a shared instance of a singleton.
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // Class function for creating a dictionary of values of the user's location suitable for the StudentLocation class
    class func createUserLocation() -> NSDictionary {
        var userLocationDictionary: [String:AnyObject]
        userLocationDictionary = [
            "uniqueKey" : OTMClient.sharedInstance().accountKey!,
            "firstName" : OTMClient.sharedInstance().firstName!,
            "lastName" : OTMClient.sharedInstance().lastName!,
            "mapString" : OTMClient.sharedInstance().mapString!,
            "mediaURL" : OTMClient.sharedInstance().mediaURL!,
            "latitude" : OTMClient.sharedInstance().userLat!,
            "longitude" : OTMClient.sharedInstance().userLong!
        ]
        
        return userLocationDictionary
    }
    
    

}
