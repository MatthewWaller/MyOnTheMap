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
                
                self.appDelegate.allStudentInfo = results
                
            } else {
                print(error)
            }
            
        }
        
        completionHandler(success: true, errorString: "Failed to get student Locations")
        
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
    

