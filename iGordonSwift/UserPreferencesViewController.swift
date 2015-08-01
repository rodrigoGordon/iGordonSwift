//
//  UserPreferencesViewController.swift
//  iGordonSwift
//
//  The class creates a basic tableView that will be presented inside a popover in the main screen. It
//  also provides a Notification mechanism that will tell the NotificationCenter that the respective touched
//  row needs to be updated(added or removed)
//  
//
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import Foundation
import UIKit


public class UserPreferencesViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var allUserOptions:  [String] = [], userSelectedOptions: [String] = [];
    
    
    
    override public func viewWillAppear(animated: Bool) {
        allUserOptions = ["chapelcredits",
        "mealpoints",
        "mealpointsperday",
        "daysleftinsemester",
        "studentid",
        "temperature"]
        
        
    }

     public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        var presentationLabelForEndPoints: Array<String> = ["CL & W Credit",
        "Mealpoints" ,
        "Mealpoints left/day" ,
        "Days left in the semester",
        "Student ID",
        "Temperature"];

        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "mycell");
        
        cell.textLabel!.text = presentationLabelForEndPoints[indexPath.row];
        cell.textLabel!.font = UIFont (name: "HelveticaNeue-CondensedBold", size: 20)
        
        
        if contains(userSelectedOptions, allUserOptions[indexPath.row]){
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark ;
            
        }
        
        return cell;
    }
    
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!;
        
        if(cell.accessoryType == UITableViewCellAccessoryType.None) {
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark;
            
            userSelectedOptions.append(allUserOptions[indexPath.row]);
            
        }
        else {
            
            cell.accessoryType = UITableViewCellAccessoryType.None;
            
            userSelectedOptions.removeAtIndex(find(userSelectedOptions, allUserOptions[indexPath.row])!);
  
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true) ;
        
        if(userSelectedOptions.count >= 1){
            NSNotificationCenter.defaultCenter().postNotificationName("userPreferencesUpdated", object: self, userInfo: ["userPreferences": userSelectedOptions]);
        }
        
        
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUserOptions.count;
    }
    

    
    

    
    
}
