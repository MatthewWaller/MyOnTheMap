//
//  StudentInformation.swift
//  MyOnTheMap
//
//  Created by Matthew Waller on 2/16/16.
//  Copyright © 2016 Matthew Waller. All rights reserved.
//

struct StudentInformation {
    //MARK: Properties
    
    var objectID: String? = nil
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var mapString: String? = nil
    var mediaURL: String? = nil
    var latitude:  Double? = nil
    var longitude: Double? = nil
    
    
    init(dictionary: [String:AnyObject]) {
        
        objectID = dictionary[UdacityClient.JSONResponseKeys.ObjectID] as? String
        uniqueKey = dictionary[UdacityClient.JSONResponseKeys.UniqueKey] as? String
        firstName = dictionary[UdacityClient.JSONResponseKeys.FirstName] as? String
        lastName = dictionary[UdacityClient.JSONResponseKeys.LastName] as? String
        mapString = dictionary[UdacityClient.JSONResponseKeys.MapString] as? String
        mediaURL = dictionary[UdacityClient.JSONResponseKeys.MediaURL] as? String
        latitude = dictionary[UdacityClient.JSONResponseKeys.Latitude] as? Double
        longitude = dictionary[UdacityClient.JSONResponseKeys.Longitude] as? Double
        
    }
    
    static func studentInformationObjectsFromResults(results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var studentInformationArray = [StudentInformation]()
        
        
        for result in results {
            
            studentInformationArray.append(StudentInformation(dictionary: result))
            
        }
        
        
        return studentInformationArray
        
    }
    
}
