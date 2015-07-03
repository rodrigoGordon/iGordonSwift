//
//  UserPreferencesViewController.swift
//  iGordonSwift
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import Foundation
import UIKit


class UserPreferencesViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var allUserOptions:  [String] = [], userSelectedOptions: [String] = [];
    
    
    
    override func viewWillAppear(animated: Bool) {
        allUserOptions = ["chapelcredits",
        "mealpoints",
        "mealpointsperday",
        "daysleftinsemester",
        "studentid",
        "temperature"]
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if(userSelectedOptions.count >= 1){
        NSNotificationCenter.defaultCenter().postNotificationName("userPreferencesUpdated", object: self, userInfo: ["userPreferences": userSelectedOptions]);
        }
 
    }
    
    
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        var presentationLabelForEndPoints: Array<String> = ["CL & W Credit",
        "Mealpoints" ,
        "Mealpoints left/day" ,
        "Days left in the semester",
        "Student ID",
        "Temperature"];
        
        
        
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "mycell");
        
        cell.textLabel!.text = presentationLabelForEndPoints[indexPath.row];
      
        
        
        
        if contains(userSelectedOptions, allUserOptions[indexPath.row]){
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark ;
            
            
        }
        
        return cell;
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
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
        
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUserOptions.count;
    }
    

    
    

    
    
}
