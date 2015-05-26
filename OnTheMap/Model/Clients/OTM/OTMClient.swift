//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/16/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation


class OTMClient: NSObject {
    
    var session: NSURLSession
    
    // Change these back to nil later
    var userID: String? = "ransomkb@icloud.com"
    var password: String? = "Okonomiyuki80"
    
    var accountKey: String? = nil
    var sessionID: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    var mapString: String? = nil
    var mediaURL: String? = nil
    var userLat: Double? = nil
    var userLong: Double? = nil
    
    var myLocation: StudentLocation? = nil
    var students:[StudentLocation] = [StudentLocation]()
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func taskForGETMethod(udacity: Bool, baseURL: String, method: String, parameters: String, requestValues: [[String:String]], completionHandler: (result: AnyObject!, error: NSError?) -> Void ) -> NSURLSessionDataTask {
        
        let urlString = baseURL + method + parameters
        println("GET URL: \(urlString)")
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        if !requestValues.isEmpty {
            for dict in requestValues {
                request.addValue(dict["value"], forHTTPHeaderField: dict["field"]!)
            }
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, downloadError) -> Void in
            
            println("Starting GET task.")
            
            if let error = downloadError {
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                println("No Error, Time to Parse newData.")
                
                var newData = data
                
                if udacity {
                    println("udacity was true, so getting subset of data.")
                    /* subset response data! */
                    newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                }
                
                println("JSONResult data: \(NSString(data: newData, encoding: NSUTF8StringEncoding)!)")
                OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        })
        
        task.resume()
        
        return task
    }
    
    func taskForPOSTMethod(udacity: Bool, baseURL: String, method: String, parameters: String, requestValues: [[String:String]], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var jsonifyError: NSError? = nil
        
        let urlString = baseURL + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        
        for dict in requestValues {
            request.addValue(dict["value"], forHTTPHeaderField: dict["field"]!)
        }
        
        request.HTTPBody = parameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, downloadError) -> Void in
            println("Starting POST Task")
            if let error = downloadError {
                println("Task Download Error.")
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                println("No Error, Time to Parse newData.")
                
                var newData = data
                
                if udacity {
                    println("udacity was true, so getting subset of data.")
                    /* subset response data! */
                    newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                }
                
                println("JSONResult data: \(NSString(data: newData, encoding: NSUTF8StringEncoding)!)")
                OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        })
        
        task.resume()
    
        return task
    }
    
    func taskForPUTMethod(udacity: Bool, baseURL: String, method: String, fileName: String, parameters: String, requestValues: [[String:String]], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var jsonifyError: NSError? = nil
        
        let urlString = baseURL + method + fileName
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "PUT"
        
        for dict in requestValues {
            request.addValue(dict["value"], forHTTPHeaderField: dict["field"]!)
        }
        
        request.HTTPBody = parameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, downloadError) -> Void in
            println("Starting PUT Task")
            if let error = downloadError {
                println("Task Download Error.")
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                println("No Error, Time to Parse newData.")
                
                var newData = data
                
                if udacity {
                    println("udacity was true, so getting subset of data.")
                    /* subset response data! */
                    newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                }
                
                println("JSONResult data: \(NSString(data: newData, encoding: NSUTF8StringEncoding)!)")
                OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        })
        
        task.resume()
        
        return task
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        println("Parsing")
        var parsingError: NSError? = nil
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            println("Parsing Error")
            NSLog("Error is: \(parsingError)");
            completionHandler(result: nil, error: error)
        } else {
            println("No Parsing Error")
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    class func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("\(key)") != nil {
            return method.stringByReplacingOccurrencesOfString("\(key)", withString: value)
        } else {
            return nil
        }
    }

    
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String:AnyObject] {
            
            // maybe don't need this
            return error
        }
        
        return error
    }
    
    class func escapedParameters(parameters: [String:AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
    
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