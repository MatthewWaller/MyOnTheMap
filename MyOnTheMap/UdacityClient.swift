//
//  UdacityClient.swift
//  MyOnTheMap
//
//  Created by Matthew Waller on 2/15/16.
//  Copyright © 2016 Matthew Waller. All rights reserved.
//

import Foundation

// MARK: - UdacityClient: NSObject

class UdacityClient : NSObject {
    
    var session: NSURLSession
    
    var sessionID : String? = nil
    var userID: String? = nil
    var userFirstName: String? = nil
    var userLastName: String? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: GET
    
    func taskForGETMethod(method: String, parameters: [String : AnyObject], baseURLString: String, requestValues: [[String: String]]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        let mutableParameters = parameters
        
        /* 2/3. Build the URL and configure the request */
        let urlString = baseURLString + method + UdacityClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        print("this is the url path \(url.path)")
        let request = NSMutableURLRequest(URL: url)
        
        if let valuesToBeAdded = requestValues {
            
            for value in valuesToBeAdded {
                
                request.addValue(value["value"]!, forHTTPHeaderField: value["forHTTPHeaderField"]!)
                
            }
            
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            var newData = NSData()

            if baseURLString == Constants.BaseURLSecure {
            
            newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            } else {
                newData = data
            }
            
            
            UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], baseURLString: String, requestValues: [[String: String]]?, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        let mutableParameters = parameters
        
        
        /* 2/3. Build the URL and configure the request */
        let urlString = baseURLString + method + UdacityClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        if let valuesToBeAdded = requestValues {
            
            for value in valuesToBeAdded {
                
                request.addValue(value["value"]!, forHTTPHeaderField: value["forHTTPHeaderField"]!)
                
            }
            
        }
        
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your request: \(error!.localizedDescription)")
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            var newData = NSData()
            
            if baseURLString == Constants.BaseURLSecure {
                
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
            } else {
                newData = data
            }

            UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        

        task.resume()
        
        return task
    }
    
    
    func taskForDELETEMethod(method: String, baseURLString: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
    
        let urlString = baseURLString + method
        let request = NSMutableURLRequest(URL:NSURL(string: urlString)!)
        request.HTTPMethod = "DELETE"

        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        
         let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            var newData = NSData()
            
            if baseURLString == Constants.BaseURLSecure {
                
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
            } else {
                newData = data
            }
            
            UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            
        }
    
        task.resume()
        return task
    }

    
    // MARK: Helpers
    
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }

    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
}