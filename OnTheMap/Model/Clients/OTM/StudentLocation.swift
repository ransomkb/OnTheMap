//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/16/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import UIKit

// Handle all the data related to a Student's Location
struct StudentLocation {
    
    var objectID = ""
    var createdAt = ""
    var updatedAt = ""
    
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    
    var mapString = ""
    var mediaURL = ""
    var latitude = 0.0
    var longitude = 0.0
    
    var studentDictionary: [String:AnyObject]
    
    
    init(dictionary: [String:AnyObject]) {
        
        if let object = dictionary["objectId"] as? String { objectID = object }
        if let created = dictionary["createdAt"] as? String { createdAt = created }
        if let updated = dictionary["updatedAt"] as? String { updatedAt = updated }
        
        if let unique = dictionary["uniqueKey"] as? String { uniqueKey = unique }
        if let first = dictionary["firstName"] as? String { firstName = first }
        if let last = dictionary["lastName"] as? String { lastName = last }
        
        if let map = dictionary["mapString"] as? String { mapString = map }
        if let media = dictionary["mediaURL"] as? String { mediaURL = media }
        if let lat = dictionary["latitude"] as? Double { latitude = lat }
        if let long = dictionary["longitude"] as? Double { longitude = long }
        
        studentDictionary = [
            "uniqueKey" : uniqueKey,
            "firstName" : firstName,
            "lastName" : lastName,
            "mapString" : mapString,
            "mediaURL" : mediaURL,
            "latitude" : latitude,
            "longitude" : longitude
        ]
    }
    
    // Create an array of StudentLocation objects from dictionaries received from search results
    static func studentLocationsFromResults(results: [[String:AnyObject]]) -> [StudentLocation] {
        var studentLocations = [StudentLocation]()
        
        for result in results {
            studentLocations.append(StudentLocation(dictionary: result))
        }
        
        return studentLocations
    }
    
    // Create string values for the JSON update dictionary
    func buildUpdateString() -> String {
        var updateString: String
        updateString = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\":\(longitude)}"
        
        return updateString
    }
    
}
