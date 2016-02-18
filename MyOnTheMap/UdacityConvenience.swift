//
//  UdacityConvenience.swift
//  MyOnTheMap
//
//  Created by Matthew Waller on 2/15/16.
//  Copyright © 2016 Matthew Waller. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    
    func loginWithCredentials(credentials:[String : AnyObject], type: String?, completionHandler: (success: Bool, errorString: String?) -> Void) {
    
        postForSessionID(credentials, type: type) { (success, sessionID, userID, errorString) -> Void in
        
            
            if success {
                
                self.sessionID = sessionID
                self.userID = userID
                print("got user and session ID!!")
                
                self.getPublicUserData({ (success, firstName, lastName, errorString) -> Void in
                    if success {
                        
                        self.userFirstName = firstName
                        self.userLastName = lastName
                        
                    }
                })
                
                completionHandler(success: success, errorString: errorString)
                
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
                print(error)
                completionHandler(success: false, sessionID: nil, userID: nil, errorString: error.localizedDescription)
            } else {
                
                print(JSONResult)
                
                if let errorMessage = JSONResult["error"] as? String {
                    print(errorMessage)
                    completionHandler(success: false, sessionID: nil, userID: nil, errorString: errorMessage)
                } else {
                
                    if let sessionCategory1 = JSONResult["account"] {
                    
                        print("this is sessionCateogry1 \(sessionCategory1)")
                    
                        if let userID = sessionCategory1!["key"] as? String {
                        
                            if let sessionCategory2 = JSONResult["session"] as? [String:String] {
                            
                                if let sessionID = sessionCategory2["id"] {
                            
                                    completionHandler(success: true, sessionID: sessionID, userID: userID, errorString: nil)
                            
                                } else {
                                completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (key not found).")
                                }
                            
                            } else {
                            completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (session not found).")
                            }
                        
                        } else {
                        completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (id not found).")
                        }
                    
                    } else {
                    completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (account not found).")
                    }
                }
            }
        }
        
    }
    
    func getPublicUserData (completionHandler: (success: Bool, firstName: String?, lastName: String?, errorString: String?) -> Void) {
         let parameters = [String: AnyObject]()
        var mutableMethod : String = Methods.User
        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance().userID!))!
        
        print("this is the userID: \(UdacityClient.sharedInstance().userID!)")
        
        taskForGETMethod(mutableMethod, parameters: parameters, baseURLString: Constants.BaseURLSecure, requestValues: nil) { (result, error) -> Void in
            if let error = error {
                print(error)
                completionHandler(success: false, firstName: nil, lastName: nil, errorString: "Login Failed (UserInfo).")
            } else {
                
                if let user = result["user"] as? [String:String] {
                    
                    if let firstName = user["first_name"] {
                        
                        if let lastName = user["last_name"] {
                            
                            completionHandler(success: false, firstName: firstName, lastName: lastName, errorString: nil)
                            
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
                    print(results)
                    let studentInfo = StudentInformation.studentInformationObjectsFromResults(results)
                    completionHandler(result: studentInfo, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getStudentLocation Parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse studentInfo results"]))
                }
            }
        }
        
    }
    
    func logOutOfUdacity(completionHandler:(success: Bool, errorString: String?) -> Void) {
        
        taskForDELETEMethod(UdacityClient.Methods.Session, baseURLString: Constants.BaseURLSecure) { (result, error) -> Void in
            if let error = error {
                completionHandler(success: false, errorString: error.localizedDescription)
            } else {
                print(result)
                completionHandler(success: true, errorString: nil)
            }
        }
    }
    
}