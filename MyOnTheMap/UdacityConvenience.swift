//
//  UdacityConvenience.swift
//  MyOnTheMap
//
//  Created by Matthew Waller on 2/15/16.
//  Copyright © 2016 Matthew Waller. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

extension UdacityClient {
    
    func loginWithCredentials(credentials:[String : AnyObject], type: String?, completionHandler: (success: Bool, errorString: String?) -> Void) {
    
        postForSessionID(credentials, type: type) { (success, sessionID, userID, errorString) -> Void in
        
            
            if success {
                
                self.sessionID = sessionID
                self.userID = userID
                
                self.getPublicUserData({ (success, firstName, lastName, errorString) -> Void in
                    if success {
                        
                        self.userFirstName = firstName
                        self.userLastName = lastName
                        completionHandler(success: success, errorString: errorString)
                    }
                })
                
                
                
            } else {
                completionHandler(success: success, errorString: errorString)
            }
            
        }
    
    }
    
    
    func postForSessionID(credentials: [String : AnyObject], type: String?, completionHandler: (success: Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
        
        let mutableMethod : String = Methods.Session
        let parameters = credentials
        let jsonBody : [String:AnyObject] = [
            type!: credentials
        ]
        let requestValues = [
            ["value":"application/json", "forHTTPHeaderField":"Accept"],
            ["value":"application/json", "forHTTPHeaderField":"Content-Type"]
        ]
        
        taskForPOSTMethod(mutableMethod, parameters: parameters, baseURLString: Constants.BaseURLSecure, requestValues: requestValues, jsonBody: jsonBody) { JSONResult, error in
        
            if let error = error {
              
                completionHandler(success: false, sessionID: nil, userID: nil, errorString: error.localizedDescription)
            } else {
                
                if let errorMessage = JSONResult["error"] as? String { //the error is nil, but the database can still return a readable JSON error
                    completionHandler(success: false, sessionID: nil, userID: nil, errorString: errorMessage)
                } else {
                
                    if let sessionCategory1 = JSONResult["account"] {
                    
                    let userID = sessionCategory1!["key"] as? String
                        
                    let sessionCategory2 = JSONResult["session"] as? [String:String]
                            
                    let sessionID = sessionCategory2!["id"]
                            
                    completionHandler(success: true, sessionID: sessionID, userID: userID, errorString: nil)
                            
                    } else {
                        completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Account not found).")
                    }
                            
                }
                
            }
        }
        
    }
    
    func getPublicUserData (completionHandler: (success: Bool, firstName: String?, lastName: String?, errorString: String?) -> Void) {
         let parameters = [String: AnyObject]()
        var mutableMethod : String = Methods.User
        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance().userID!))!
        
        taskForGETMethod(mutableMethod, parameters: parameters, baseURLString: Constants.BaseURLSecure, requestValues: nil) { (result, error) -> Void in
            if let error = error {
                
                completionHandler(success: false, firstName: nil, lastName: nil, errorString: "Login Failed (UserInfo).")
            } else {
                
                if let user = result!["user"] as? [String:AnyObject] {
                    
                    if let firstName = user["first_name"] {
                        
                        if let lastName = user["last_name"] {
                            
                            completionHandler(success: true, firstName: firstName as? String, lastName: lastName as? String, errorString: nil)
                            
                        } else {
                            completionHandler(success: false, firstName: nil, lastName: nil, errorString: "Login Failed (LastName).")
                        }
                        
                    } else {
                        completionHandler(success: false, firstName: nil, lastName: nil, errorString: "Login Failed (UserFirstName).")
                    }
                    
                } else {
                    completionHandler(success: false, firstName: nil, lastName: nil, errorString: "Login Failed (UserInfo).")
                }
                
                
            }
        }
    }
    
    
    func getStudentLocations (completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        let parameters = [UdacityClient.ParameterKeys.Limit : 100]
        
        let requestValues = [
            ["value":UdacityClient.Constants.ParseApplicationID, "forHTTPHeaderField":"X-Parse-Application-Id"],
            ["value":UdacityClient.Constants.ParseRestApiKey, "forHTTPHeaderField":"X-Parse-REST-API-Key"]
        ]
        
        taskForGETMethod(UdacityClient.Methods.StudentLocation, parameters: parameters, baseURLString: Constants.BaseParseURLSecure, requestValues: requestValues) { (result, error) -> Void in
            if let error = error {
                
                completionHandler(result: nil, error: error)
            } else {

                
                if let results = result[UdacityClient.JSONResponseKeys.StudentInfoResults] as? [[String:AnyObject]] {
                   
                    let studentInfo = StudentInformation.studentInformationObjectsFromResults(results)
                    completionHandler(result: studentInfo, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getStudentLocation Parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse studentInfo results"]))
                }
            }
        }
        
    }
    
    func postStudentLocation(studentInfo: StudentInformation, completionHandler: (success: Bool, errorString: String?) -> Void){
        
        let parameters = [String: AnyObject]()
        let requestValues = [
            ["value":UdacityClient.Constants.ParseApplicationID, "forHTTPHeaderField":"X-Parse-Application-Id"],
            ["value":UdacityClient.Constants.ParseRestApiKey, "forHTTPHeaderField":"X-Parse-REST-API-Key"],
            ["value":"application/json", "forHTTPHeaderField":"Content-Type"]
        ]
        let jsonBody : [String:AnyObject] = [
            "uniqueKey": studentInfo.uniqueKey!,
            "firstName": studentInfo.firstName!,
            "lastName": studentInfo.lastName!,
            "mapString": studentInfo.mapString!,
            "mediaURL": studentInfo.mediaURL!,
            "latitude": studentInfo.latitude!,
            "longitude": studentInfo.longitude!
        ]
        
        taskForPOSTMethod(Methods.StudentLocation, parameters: parameters, baseURLString: Constants.BaseParseURLSecure, requestValues: requestValues, jsonBody: jsonBody) { (result, error) -> Void in
            if let error = error {
                completionHandler(success: false, errorString: error.localizedDescription)
            } else {
                completionHandler(success: true, errorString: nil)
            }
        }
        
        
        
    }
    
    
    func refresh(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        
        UdacityClient.sharedInstance().getStudentLocations { (result, error) -> Void in
            if let results = result {
               
                self.appDelegate.allStudentInfo = results
                completionHandler(success: true, errorString: nil)
            } else {
                completionHandler(success: false, errorString: "Could not get student info")
            }
            
        }
        
        
        
    }
    
    func logout(viewController: UIViewController){
        
            
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
               
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    viewController.dismissViewControllerAnimated(true, completion: nil)
                })
                
                
            } else {
                UdacityClient.sharedInstance().logOutOfUdacity({ (success, errorString) -> Void in
                    if let errorMessage = errorString {
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            viewController.dismissViewControllerAnimated(true, completion: nil)
                        })
                    }
                })
            }
        
    }

    
    
    func logOutOfUdacity(completionHandler:(success: Bool, errorString: String?) -> Void) {
        
        taskForDELETEMethod(UdacityClient.Methods.Session, baseURLString: Constants.BaseURLSecure) { (result, error) -> Void in
            if let error = error {
                completionHandler(success: false, errorString: error.localizedDescription)
            } else {
                
                completionHandler(success: true, errorString: nil)
            }
        }
    }
    
}