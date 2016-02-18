//
//  MapViewController.swift
//  MyOnTheMap
//
//  Created by Matthew Waller on 2/16/16.
//  Copyright © 2016 Matthew Waller. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    var students: [StudentInformation] = [StudentInformation]()
    
    @IBOutlet weak var customNavBar: CustomNavigationItem!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        getStudents()
        
    }
    
 
    func getStudents() {
        
                
                self.students = self.appDelegate.allStudentInfo!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.addPins()
                })
           

        
    }
    
    func addPins(){
        
        var annotations = [MKPointAnnotation]()
        
        for student in students {
            
            let lat = CLLocationDegrees(student.latitude!)
            let long = CLLocationDegrees(student.longitude!)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(student.firstName!) \(student.lastName!)"
            annotation.subtitle = student.mediaURL!
            
            annotations.append(annotation)
            
        }
        
        mapView.addAnnotations(annotations)
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.blueColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
    //MARK: Navigation bar
    
    @IBAction func getInfo(sender: UIBarButtonItem) {
        
        customNavBar.refresh { (success, errorString) -> Void in
            if success {
                
                 self.getStudents()
                
            } else {
                
                print("refreshFailed")
            }
        }
        
        
    }
    
    
    @IBAction func logout(sender: UIBarButtonItem) {
        
        customNavBar.logout(self)
        
    }
    

}