//
//  ListViewController.swift
//  MyOnTheMap
//
//  Created by Matthew Waller on 2/16/16.
//  Copyright © 2016 Matthew Waller. All rights reserved.
//

import Foundation
import UIKit



class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var appDelegate: AppDelegate!
    var students: [StudentInformation] = [StudentInformation]()
    

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getInfo(self)
        
    }
    
    func presentAlert(alertText: String){
        
        let loginFailureAlert = UIAlertController(title: "Login Failure", message: alertText, preferredStyle: .Alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        
        loginFailureAlert.addAction(dismissAction)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(loginFailureAlert, animated: true, completion: nil)
        }
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
 
    let student = students[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier("BasicTableViewCell") as UITableViewCell!
    cell.textLabel?.text = "\(student.firstName!) \(student.lastName!)"
    
    return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let url = students[indexPath.row].mediaURL
        
    UIApplication.sharedApplication().openURL(NSURL(string:url!)!)
    
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    //MARK: Navigation bar
    
    @IBAction func getInfo(sender: AnyObject) {
        
        UdacityClient.sharedInstance().refresh { (success, errorString) -> Void in
            if success {
                
                self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                if let students = self.appDelegate.allStudentInfo {
                    self.students = students
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
                
            } else {
                
                self.presentAlert(errorString!)
            }
        }
    }
    
    @IBAction func logout(sender: UIBarButtonItem) {
        
        UdacityClient.sharedInstance().logout(self)
        
    }
}