//
//  InfoPostViewController.swift
//  MyOnTheMap
//
//  Created by Matthew Waller on 2/17/16.
//  Copyright © 2016 Matthew Waller. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class InfoPostViewController: UIViewController, UITextFieldDelegate {
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    var myLocationInfo = [String : AnyObject]()

    
    @IBOutlet weak var instructionLabel: UILabel!
    
    @IBOutlet weak var submissionButton: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        textField.delegate = self
        activityIndicator.stopAnimating()
        
        print(UdacityClient.sharedInstance().userFirstName)
        
        myLocationInfo = ["firstName": UdacityClient.sharedInstance().userFirstName!,
            "lastName": UdacityClient.sharedInstance().userLastName!,
            "uniqueKey": UdacityClient.sharedInstance().userID!]
    }
  
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        addKeyboardDismissRecognizer()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        removeKeyboardDismissRecognizer()
    }
    
    func presentAlert(alertText: String){
        
        let loginFailureAlert = UIAlertController(title: "Error", message: alertText, preferredStyle: .Alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        
        loginFailureAlert.addAction(dismissAction)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(loginFailureAlert, animated: true, completion: nil)
        }
        
    }
   
    
    
    @IBAction func cancel(sender: UIButton) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    @IBAction func submitInfo(sender: UIButton) {
        
        switch submissionButton.titleLabel!.text! {
            
            case "Find Me":
                
                
                activityIndicator.startAnimating()
                mapView.alpha = 0.5 //transparency changed to have additional indications of activity
                
                let geoCoder = CLGeocoder()
                
                let addressString = "\(textField.text!)"
                
                
                geoCoder.geocodeAddressString(addressString) { (placemarks, error) in
                    
                    if error != nil {
                        
                        self.presentAlert((error?.localizedDescription)!)
                        self.activityIndicator.stopAnimating()
                        self.mapView.alpha = 1.0
                        
                    } else {
                    
                        if let locations = placemarks as [CLPlacemark]? {
                    
                            let firstLocation = locations[0]
                            let firstLocationAnnotation = MKPlacemark(placemark: firstLocation)
                            
                            self.myLocationInfo.updateValue(addressString, forKey: "mapString")
                            self.myLocationInfo.updateValue(firstLocationAnnotation.coordinate.latitude, forKey: "latitude")
                            self.myLocationInfo.updateValue(firstLocationAnnotation.coordinate.longitude, forKey: "longitude")
                        
                            
                            if let center = (firstLocation.region as? CLCircularRegion)?.center {
                        
                                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.2, 0.2))
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    
                                    self.activityIndicator.stopAnimating()
                                    self.mapView.alpha = 1.0
                                    self.mapView.setRegion(region, animated: true)
                                    self.mapView.addAnnotation(firstLocationAnnotation)
                                    self.submissionButton.setTitle("Add Link", forState: .Normal)
                                    self.instructionLabel.text = "Now share thy cool link!"
                                    self.textField.text?.removeAll()
                                    self.textField.placeholder = "Include https:// or http://"
                                    
                                })
                            }
                        }
                    }
                }
                
                //Code with help from http://stackoverflow.com/a/35440668/2788526
            
            case "Add Link":
            
            myLocationInfo.updateValue(textField.text!, forKey: "mediaURL")
            
            let myStudentInfo = StudentInformation(dictionary: self.myLocationInfo)
            
            UdacityClient.sharedInstance().postStudentLocation(myStudentInfo, completionHandler: { (success, errorString) -> Void in
                if success {
                    
                    self.dismissViewControllerAnimated(true, completion: nil)

                } else {
                    
                    self.presentAlert(errorString!)
                }
            })
            
            default:
            
            break
            
        }
        
    }
    
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

}

