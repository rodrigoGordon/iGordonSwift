//
//  UserOptionsMenuPopover.swift
//  iGordonSwift
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import UIKit

class UserOptionsMenuPopover: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var itemMenuOptions: [String] = ["Gordon.edu" , "cs.gordon.edu" , "Logout"];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "mycell");
        
        cell.textLabel!.text = itemMenuOptions[indexPath.row];
        

        
        return cell;

        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        var url: String?;
        
        switch (indexPath.row) {
        case 0:
            url = "http://www.gordon.edu";
            break;
        case 1:
            url = "http://www.cs.gordon.edu";
            break;
        case 2:
            self.performSegueWithIdentifier("logoutFromPopover", sender: self);
            break;
        default:
            println("NO VALID OPTION");
            break;
        }
        
        if(url != nil){
            UIApplication.sharedApplication().openURL(NSURL(string:url!)!);
        }
      
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemMenuOptions.count;
    }


}
