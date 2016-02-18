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
    
    @IBOutlet weak var customNavBar: CustomNavigationItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LoadedListView")
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let students = appDelegate.allStudentInfo {
            self.students = students
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
    
    @IBAction func getInfo(sender: UIBarButtonItem) {
        
        customNavBar.refresh { (success, errorString) -> Void in
            if success {
                
                self.tableView.reloadData()
                
            } else {
                
                print("refreshFailed")
            }
        }
    }
    
    @IBAction func logout(sender: UIBarButtonItem) {
        
        customNavBar.logout(self)
        
    }
}