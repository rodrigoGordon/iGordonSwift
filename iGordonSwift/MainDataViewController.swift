//
//  MainDataViewController.swift
//  iGordonSwift
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class MainDataViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate {


    
    
    
    
    @IBOutlet var tableViewData: UITableView!;
    
    var userProfile: Dictionary<String,String?> = Dictionary(), endPointsDictionary: Dictionary<String,EndPoint> = Dictionary();
    
    /*
    var userTablePreferences: [String] = ["chapelcredits",
                                          "mealpoints",
                                          "mealpointsperday",
                                          "daysleftinsemester",
                                          "studentid",
                                          "temperature"];
    */
    var userTablePreferences: [String] = Array()
    
    var btnShowAddOption: UIBarButtonItem = UIBarButtonItem(), btnReorder: UIBarButtonItem = UIBarButtonItem();
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnShowAddOption = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "btnShowPopoverAddRemove:");
        btnReorder = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize , target: self, action: "activateReorder");
    
        self.navigationItem.setLeftBarButtonItems([btnShowAddOption, btnReorder], animated: true);
        
        var chapelCreditEndPoint = EndPoint();
        
        
        chapelCreditEndPoint.name = "chapelcredits";
        chapelCreditEndPoint.cellDescription = "CL&W credits" ;
        chapelCreditEndPoint.colorRGB = [11/255.0 , 54/255.0 , 112/255.0];
        chapelCreditEndPoint.image = "chapel.png" ;
        
        var mealPointsEndPoint = EndPoint();
        
        mealPointsEndPoint.name = "mealpoints";
        mealPointsEndPoint.cellDescription = "MEALPOINTS" ;
        mealPointsEndPoint.colorRGB = [236/255.0, 147/255.0, 34/255.0];
        mealPointsEndPoint.image = "silverware.png" ;
        
        var mealPointsPerDayEndPoint = EndPoint();
        
        mealPointsPerDayEndPoint.name = "mealpointsperday";
        mealPointsPerDayEndPoint.cellDescription = "MEALPOINTS LEFT/DAY" ;
        mealPointsPerDayEndPoint.colorRGB = [130/255.0 , 54/255.0 , 178/255.0];
        mealPointsPerDayEndPoint.image =  "calculator.png" ;
        
        var daysleftInSemesterEndPoint = EndPoint();
        
        daysleftInSemesterEndPoint.name = "daysleftinsemester";
        daysleftInSemesterEndPoint.cellDescription = "DAYS LEFT IN SEMESTER" ;
        daysleftInSemesterEndPoint.colorRGB = [88/255.0 , 248/255.0 , 151/255.0];
        daysleftInSemesterEndPoint.image = "calendar.png" ;
        
        var studentIdEndPoint = EndPoint();
        
        studentIdEndPoint.name = "studentid";
        studentIdEndPoint.cellDescription = "STUDENT ID" ;
        studentIdEndPoint.colorRGB = [236/255.0, 90/255.0, 91/255.0];
        studentIdEndPoint.image =  "person.png" ;
        
        var temperatureEndPoint =  EndPoint();
        
        temperatureEndPoint.name = "temperature";
        temperatureEndPoint.cellDescription = "TEMPERATURE" ;
        temperatureEndPoint.colorRGB = [71/255.0 , 212/255.0, 201/255.0];
        temperatureEndPoint.image = "thermometer.png" ;
        
        
        
        endPointsDictionary = [
                chapelCreditEndPoint.name : chapelCreditEndPoint,
                mealPointsEndPoint.name : mealPointsEndPoint,
                mealPointsPerDayEndPoint.name : mealPointsPerDayEndPoint,
                daysleftInSemesterEndPoint.name : daysleftInSemesterEndPoint,
                studentIdEndPoint.name : studentIdEndPoint,
                temperatureEndPoint.name : temperatureEndPoint
                ];
        
        
     
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSpecificRowWithNotification:",
            name: "dataRetrievedFromServer", object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableAfterChangesAtUserPreferences:",
            name: "userPreferencesUpdated", object: nil);
    
        
        self.navigationController?.navigationBar.hidden = false;
        
        //used to make the table get closer to the navigation bar
        self.automaticallyAdjustsScrollViewInsets = false;

        
        
    }
    
    override func viewWillAppear(animated: Bool) {
    
    self.navigationItem.hidesBackButton = true;
    
    }
    
    func updateSpecificRowWithNotification(notification: NSNotification)
    {
        
       
        let keyOfEndPointToBeUpdated = notification.userInfo!.keys.first;
        
        var indexPath = NSIndexPath(forRow: find(userTablePreferences,
                                            (keyOfEndPointToBeUpdated as? String)!)!, inSection: 0);
    

        tableViewData?.beginUpdates();
    
        tableViewData?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade);

        tableViewData?.endUpdates();
    
    }
    
    func activateReorder(){
        

    if(tableViewData?.editing == false){
     
    tableViewData?.setEditing(true, animated: true);
    
    }else{
     
        tableViewData?.setEditing(false, animated: false);
        updateUserPreferencesInDB()
    
    }
        
    }
    
    
    func updateTableAfterChangesAtUserPreferences(notification: NSNotification){
    
        
        let tempParseFromNotification: Dictionary<String,[String]> =
            (notification.userInfo as? Dictionary<String,[String]>)!;
        

        let tempUserPreferencesChanges: [String] = tempParseFromNotification["userPreferences"]! ;
        
        var copyOfUserTablePreferences = userTablePreferences;
        
        
        for obj in tempUserPreferencesChanges {
            
            if ( find(copyOfUserTablePreferences, obj) == nil){
                
                var i: Int = find(tempUserPreferencesChanges, obj)! ;
                var indexPath = NSIndexPath(forRow: i, inSection: 0);
                userTablePreferences.append(obj);
                tableViewData?.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                
            }

            
        }
        
        for obj in copyOfUserTablePreferences{
            
            if ( find(tempUserPreferencesChanges, obj) == nil){
                
                var i: Int = find(userTablePreferences, obj)! ;
                var indexPath = NSIndexPath(forRow: i, inSection: 0);
                userTablePreferences.removeAtIndex(i) ;
                tableViewData?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade) ;
                
            }
            
            
        }
                
        updateUserPreferencesInDB()

    }
    
    
    func updateUserPreferencesInDB(){
        
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "GordonUser")
        let predicate = NSPredicate(format: "sessionStatus==%@", "in")
        fetchRequest.predicate = predicate
        
        if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [GordonUser]{
            
            
            if (fetchResults.count >= 1) {
                
                var userGordon = fetchResults[0]
                
                var userPrefencesString: String = userTablePreferences.count >= 1 ? ",".join(userTablePreferences) :
                                "chapelcredits,mealpoints,mealpointsperday,daysleftinsemester,studentid,temperature"
                
                
                
                userGordon.tablePreferences = userPrefencesString
                var saveError: NSError? = nil
                if !managedContext.save(&saveError){
                    println("Problems altering user preferences:  \(saveError)")
                }
                
            }
            
            
        }else{
            println("Error loading the data")
        }
  
    }
    
    
    
    
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true ;
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None ;
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false;
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userTablePreferences.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let identifier = "tableCellDesignUserDataOptions";
        // IT"S mandatory to register a NIB
        tableView.registerNib(UINib(nibName: "tableCellDesignForUserDataOptions", bundle: nil), forCellReuseIdentifier: identifier);
        
        var cell: TableViewCellUserDataCustom = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! TableViewCellUserDataCustom;
        
        
        var tempEndPoint =  endPointsDictionary[userTablePreferences[indexPath.row]];
        
        
        
        cell.activityIndicatorWorkServer.hidden = true ;
        cell.lblDescriptionOfEndPoint.text = tempEndPoint!.cellDescription;
        cell.imgIconForEndPoint.image = UIImage(named: tempEndPoint!.image)!;
        
        var backGroundCellImg = UIColor(red: tempEndPoint!.colorRGB[0],green: tempEndPoint!.colorRGB[1] ,
            blue: tempEndPoint!.colorRGB[2] , alpha: 1);
        
        
        
        cell.imgIconForEndPoint.backgroundColor = backGroundCellImg;
        
        cell.backgroundColor = backGroundCellImg;
        
        cell.lblDescriptionOfEndPoint.textColor = UIColor.whiteColor();
        cell.lblResultFromServer.textColor = UIColor.whiteColor();
        cell.lblResultFromServer.text = tempEndPoint!.value as String ;
        
        
        
        return cell;
    }
    

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        endPointsDictionary[userTablePreferences[indexPath.row]]?.loadDataFromServer(userProfile);
        
        let identifier = "tableCellDesignUserDataOptions";
        
        var cell: TableViewCellUserDataCustom = tableView.dequeueReusableCellWithIdentifier(identifier)
                                                as! TableViewCellUserDataCustom

        
        cell.activityIndicatorWorkServer.hidden = false ;
        cell.activityIndicatorWorkServer.startAnimating();
        
        
        
    }
    
   
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let objectToBeMoved = userTablePreferences[sourceIndexPath.row] ;
        userTablePreferences.removeAtIndex(sourceIndexPath.row);
        self.userTablePreferences.insert(objectToBeMoved, atIndex: destinationIndexPath.row);
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath
        indexPath: NSIndexPath) -> CGFloat {
            return (tableView.frame.size.height / CGFloat(userTablePreferences.count))-10;
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
       
            if(segue.identifier == "showViewOptions")
            {
                
                var destNav: UIViewController = segue.destinationViewController as! UserOptionsMenuPopover;
                destNav.preferredContentSize = CGSizeMake(200, 170);
                
                
                var popPC: UIPopoverPresentationController = destNav.popoverPresentationController!;
                
                
                popPC.sourceRect = CGRectMake(270, 15, 5, 10);
                
                popPC.delegate = self;
                
                
                
            }else if(segue.identifier == "showAddOptions")
            {
                
                var destNav: UserPreferencesViewController = segue.destinationViewController as! UserPreferencesViewController;
                destNav.preferredContentSize = CGSizeMake(270, 300);
                
                destNav.userSelectedOptions = userTablePreferences;
                
                
                var popPC: UIPopoverPresentationController = destNav.popoverPresentationController!;
                
                popPC.barButtonItem = self.btnShowAddOption;
                popPC.sourceRect = CGRectMake(270, 15, 5, 10);
                
                popPC.delegate = self;
  
            
           }
        
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None ;
    }
    
    
    @IBAction func btnShowPopoverOptions (sender: UIBarButtonItem ) {

        self.performSegueWithIdentifier("showViewOptions", sender: self);
    
    }
    
    @IBAction func btnShowPopoverAddRemove (sender: UIBarButtonItem){
        
        
        
        self.performSegueWithIdentifier("showAddOptions", sender: self);
    
    
    }
    
    //dismiss the popover before updating the table
    @IBAction func dismissFromAddPopover (segue: UIStoryboardSegue) {
    
    if (!segue.sourceViewController.isBeingDismissed()) {
        
        segue.sourceViewController.dismissViewControllerAnimated(true, completion: nil);
        
    }
    
    
    
    }
    
    
    
    
    

}
