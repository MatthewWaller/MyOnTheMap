//
//  ViewController.swift
//  MyOnTheMap
//
//  Created by Matthew Waller on 2/15/16.
//  Copyright © 2016 Matthew Waller. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    var appDelegate: AppDelegate! = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
       subscribeToKeyboardNotifications()
        addKeyboardDismissRecognizer()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        unsubscribeToKeyboardNotifications()
        removeKeyboardDismissRecognizer()

    }
    
   

    

    @IBAction func loginButtonPressed(sender: UIButton) {
        
        
        let usernamePasswordDictionary = ["username": usernameTextField.text!, "password": passwordTextField.text!]
        
        UdacityClient.sharedInstance().loginWithCredentials(usernamePasswordDictionary, type: UdacityClient.JSONBodyKeys.UdacityLogin) { (success, errorString) in
            if success {
                
                self.loginSuccess()
                
            } else {
                
                self.presentAlert(errorString!)
            
            }
        }
    
    }
    
    func presentAlert(alertText: String){
        
        let loginFailureAlert = UIAlertController(title: "Login Failure", message: alertText, preferredStyle: .Alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        
        loginFailureAlert.addAction(dismissAction)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(loginFailureAlert, animated: true, completion: nil)
        }
        
    }

    
    @IBAction func noAccountPressed(sender: UIButton) {
        
        UIApplication.sharedApplication().openURL(NSURL(string:"https://www.udacity.com/account/auth#!/signin")!) // guidance from this forum https://discussions.apple.com/thread/6500680?start=0&tstart=0
        
    }
    
    
    @IBAction func signInWithFacebookPressed(sender: UIButton) {
        
        
       let FBLoginManager = FBSDKLoginManager()
        FBLoginManager.logInWithReadPermissions(["public_profile"], fromViewController: self) { (result, error) -> Void in
            if let error = error {
                
               self.presentAlert(error.localizedDescription)
                
            } else if result.isCancelled {
                
                self.presentAlert("Cancelled")
                
            } else {
                let facebookCredentials = ["access_token": result.token.tokenString]
                UdacityClient.sharedInstance().loginWithCredentials(facebookCredentials,  type: UdacityClient.JSONBodyKeys.FacebookLogin, completionHandler: { (success, errorString) -> Void in
                    if success {
                       
                        self.loginSuccess()
                        
                    } else {
                        self.presentAlert(errorString!)
                    }
                })
                
            }
        }
        
    }
    
    func loginSuccess(){
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.performSegueWithIdentifier("showTabBarController", sender: self)
        })
        
    }
    
    // MARK: Keyboard
    
}

extension LoginViewController {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            view.superview?.frame.origin.y -= lastKeyboardOffset
            
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            view.superview?.frame.origin.y += lastKeyboardOffset
            
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}
