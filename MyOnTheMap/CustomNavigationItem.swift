//
//  CustomNavigationItem.swift
//  MyOnTheMap
//
//  Created by Matthew Waller on 2/17/16.
//  Copyright © 2016 Matthew Waller. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

class CustomNavigationItem: UINavigationItem {
    
    
    var appDelegate: AppDelegate! = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func refresh(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        
        UdacityClient.sharedInstance().getStudentLocations { (result, error) -> Void in
            if let results = result {
                print("got results")
                self.appDelegate.allStudentInfo = results
                completionHandler(success: true, errorString: nil)
            } else {
                completionHandler(success: false, errorString: "Could not get student info")
            }
            
        }
        
        
        
    }
    
    func logout(viewController: UIViewController){
        
        viewController.dismissViewControllerAnimated(true) { () -> Void in
            
            if (FBSDKAccessToken.currentAccessToken() != nil) {
            
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                
                print("done with facebook")

            } else {
                UdacityClient.sharedInstance().logOutOfUdacity({ (success, errorString) -> Void in
                    if let errorMessage = errorString {
                        print(errorMessage)
                    } else {
                        
                        print("done with Udacity")
                    
                    }
                })
            }
        }
    }
}
    

