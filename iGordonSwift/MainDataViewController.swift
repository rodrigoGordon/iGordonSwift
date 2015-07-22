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


public class MainDataViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate {


    @IBOutlet var tableViewData: UITableView!;
    
    
    var userProfile: Dictionary<String,String?> = Dictionary(), endPointsDictionary: Dictionary<String,EndPoint> = Dictionary();
    
    var userTablePreferences: [String] = Array()
    
    var dbManagement: DatabaseManagement = DatabaseManagement();
    
    //added for longgesturerecognizer
    var sourceIndexPath: NSIndexPath? = nil
    var snapshot: UIView? = nil
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var chapelCreditEndPoint = EndPoint();
        
        
        chapelCreditEndPoint.name = "chapelcredits";
        chapelCreditEndPoint.cellDescription = "CL&W CREDITS" ;
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
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "adjustTableAfterRotation", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        
        self.navigationController?.navigationBar.hidden = false;
        
        //used to make the table get closer to the navigation bar
        self.automaticallyAdjustsScrollViewInsets = false;
               
        
        
        
        
        var gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        
        gesture.minimumPressDuration = 0.2
        
        self.view.addGestureRecognizer(gesture)
        
        
        
    }
    
    override public func viewWillAppear(animated: Bool) {
    
        self.navigationItem.hidesBackButton = true;
  
    }
    
    
    func adjustTableAfterRotation(){

        tableViewData.reloadData()
  
    }
    
    
    func updateSpecificRowWithNotification(notification: NSNotification)
    {
        
       
        let keyOfEndPointToBeUpdated = notification.userInfo!.keys.first;
        
        var indexPath = NSIndexPath(forRow: find(userTablePreferences,
                                            (keyOfEndPointToBeUpdated as? String)!)!, inSection: 0);
    
        
        
        
        dbManagement.saveEndPointSearch(endPointsDictionary[userTablePreferences[indexPath.row]]!.name, valueReceivedFromServer: endPointsDictionary[userTablePreferences[indexPath.row]]!.value, userName: userProfile["username"]!!)
        

        tableViewData?.beginUpdates();
    
        tableViewData?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade);

        tableViewData?.endUpdates();
        
        
        
        var cell = tableViewData.cellForRowAtIndexPath(indexPath)! as! TableViewCellUserDataCustom
        
        cell.setOptionsForAnimationInResultLabel()
        cell.lblResultFromServer.hidden = false
        cell.imgIconForEndPoint.hidden = true
        cell.setOptionsForAnimationInResultLabel()
        cell.lblResultFromServer.animate()
        
  
    
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
                tableViewData.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                tableViewData.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }

            
        }
      
         tableViewData.reloadData()
        
        
        for obj in copyOfUserTablePreferences{
            
            if ( find(tempUserPreferencesChanges, obj) == nil){
                
                var i: Int = find(userTablePreferences, obj)! ;
                var indexPath = NSIndexPath(forRow: i, inSection: 0);
                
                userTablePreferences.removeAtIndex(i) ;
                
                tableViewData.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                
                
            }
            
            
        }
        
        tableViewData.reloadData()
        
        
        dbManagement.updateUserTablePreferences(userTablePreferences)

    }


    

    

    // Override to support editing the table view.
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete  {
            // Delete the row from the data source
            userTablePreferences.removeAtIndex(indexPath.row) ;
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true ;
    }
    
    
    public func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false;
    }
    
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userTablePreferences.count;
    }
    

    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
    

        let identifier = "tableCellDesignUserDataOptions";
        // IT"S mandatory to register a NIB
        tableView.registerNib(UINib(nibName: "tableCellDesignForUserDataOptions", bundle: nil), forCellReuseIdentifier: identifier);
        
        var cell: TableViewCellUserDataCustom = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! TableViewCellUserDataCustom;
        
        var tempEndPoint =  endPointsDictionary[userTablePreferences[indexPath.row]];
        
        cell.lblDescriptionOfEndPoint.text = tempEndPoint!.cellDescription;
        cell.imgIconForEndPoint.image = UIImage(named: tempEndPoint!.image)!;
        
        var backGroundCellImg = UIColor(red: tempEndPoint!.colorRGB[0],green: tempEndPoint!.colorRGB[1] ,
            blue: tempEndPoint!.colorRGB[2] , alpha: 1);
        
        
        cell.imgIconForEndPoint.backgroundColor = backGroundCellImg;
        
        cell.backgroundColor = backGroundCellImg;
        
        cell.lblDescriptionOfEndPoint.textColor = UIColor.whiteColor();
        
        cell.lblResultFromServer.textColor = UIColor.whiteColor();
        
        cell.lblResultFromServer.text = tempEndPoint!.value as String ;
        
        cell.lblLogPeriod.textColor = UIColor.whiteColor()
        
        
        let (logPeriod, endPointValue) = dbManagement.loadLastEndPointSearch(tempEndPoint!.name, userName: userProfile["username"]!!)
        
        
        if let value = endPointValue{
            cell.lblResultFromServer.text = endPointValue
            cell.lblResultFromServer.hidden  = false
            cell.imgIconForEndPoint.hidden = true
            cell.lblLogPeriod.hidden = false
        
        
        switch logPeriod{
        case 0:
            cell.lblLogPeriod.text = ""
            break
        case 1:
            cell.lblLogPeriod.text = ".."
            break
        default:
            cell.lblLogPeriod.text = "..."
        }
        
        }
        else {
            cell.imgIconForEndPoint.hidden = false
            cell.lblResultFromServer.hidden = true
            cell.lblLogPeriod.hidden = true
        }
        
        
        
        
        if userTablePreferences.count < 4  && (UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)
            || UIDevice.currentDevice().orientation.isFlat){
            
            UIView.animateWithDuration(0.5, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: nil, animations: {
                
                //center elements X
                cell.imgIconForEndPoint.center.x = (cell.frame.size.width / 2)
                cell.lblResultFromServer.center.x = (cell.frame.size.width / 2)
                cell.lblLogPeriod.center.x = (cell.frame.size.width / 2)
                cell.lblDescriptionOfEndPoint.center.x = (cell.frame.size.width / 2)
                
                
                //center elements Y
                cell.imgIconForEndPoint.center.y = (cell.frame.size.height / 2) - 20 //the image is 50x50
                cell.lblResultFromServer.center.y = (cell.frame.size.height / 2) - 20 // the label is 50x50
                cell.lblLogPeriod.center.y = cell.lblResultFromServer.center.y + 20 // differences from the img/lbl
                
                cell.lblDescriptionOfEndPoint.center.y = cell.lblLogPeriod.center.y + cell.lblLogPeriod.frame.size.height + 10
                cell.lblResultFromServer.font = UIFont (name: "HelveticaNeue-CondensedBold", size: 32)
                
                
                }, completion: nil)
        }else{
            
            UIView.animateWithDuration(0.5, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: nil, animations: {
                
                cell.imgIconForEndPoint.center.x = 45
                cell.lblResultFromServer.center.x = 45
                cell.lblLogPeriod.center.x = 45
                cell.lblDescriptionOfEndPoint.center.x = (cell.frame.size.width / 2)+10
               
                cell.imgIconForEndPoint.center.y = (cell.frame.size.height / 2) //- 10 //the image is 50x50
                cell.lblResultFromServer.center.y = (cell.frame.size.height / 2)// - 10 // the label is 50x50
                cell.lblLogPeriod.center.y = (cell.frame.size.height / 2) + 15 // differences from the img/lbl
                
                
                cell.lblDescriptionOfEndPoint.center.y = cell.imgIconForEndPoint.center.y // align with result label or imgIcon
                cell.lblResultFromServer.font = UIFont (name: "HelveticaNeue-CondensedBold", size: 25)
                
                }, completion: nil)
            
        }
        


        
        return cell;
      
    }
    
 

    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        endPointsDictionary[userTablePreferences[indexPath.row]]?.loadDataFromServer(userProfile);
        
        var cell = tableView.cellForRowAtIndexPath(indexPath)! as! TableViewCellUserDataCustom
        
        cell.imgIconForEndPoint.hidden = false
        cell.lblResultFromServer.hidden = true
        cell.selectedX = cell.imgIconForEndPoint.center.x
        cell.selectedY = cell.imgIconForEndPoint.center.y
        
        cell.setOptionsForAnimationInIcon()
        cell.imgIconForEndPoint.animate()
        
        
    }
    
   

    
    //Example found at https://github.com/moayes/Cities
    
    public func longPressGestureRecognized(gesture: UILongPressGestureRecognizer) {

        let state: UIGestureRecognizerState = gesture.state;
        let location: CGPoint = gesture.locationInView(tableViewData)
        let indexPath: NSIndexPath? = tableViewData.indexPathForRowAtPoint(location)
        if indexPath == nil {
            return
        }
        
        switch (state) {
            
        case UIGestureRecognizerState.Began:
            sourceIndexPath = indexPath;
            
            let cell = tableViewData.cellForRowAtIndexPath(indexPath!)!
            snapshot = customSnapshotFromView(cell)
            
            var center = cell.center
            snapshot?.center = center
            snapshot?.alpha = 0.0
            tableViewData.addSubview(snapshot!)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                center.y = location.y
                self.snapshot?.center = center
                self.snapshot?.transform = CGAffineTransformMakeScale(1.05, 1.05)
                self.snapshot?.alpha = 0.98
                cell.alpha = 0.0
            })
            
        case UIGestureRecognizerState.Changed:
            var center: CGPoint = snapshot!.center
            center.y = location.y
            snapshot?.center = center
            
            // Is destination valid and is it different from source?
            if indexPath != sourceIndexPath {
                // ... update data source.
                //userTablePreferences.exchangeObjectAtIndex(indexPath!.row, withObjectAtIndex: sourceIndexPath!.row)
                
                let objectToBeMoved = userTablePreferences[sourceIndexPath!.row] ;
                userTablePreferences.removeAtIndex(sourceIndexPath!.row);
                self.userTablePreferences.insert(objectToBeMoved, atIndex: indexPath!.row);
                dbManagement.updateUserTablePreferences(userTablePreferences)
                
                // ... move the rows.
                tableViewData.moveRowAtIndexPath(sourceIndexPath!, toIndexPath: indexPath!)
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            
        default:
            // Clean up.
            let cell = tableViewData.cellForRowAtIndexPath(indexPath!)!
            cell.alpha = 0.0
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.snapshot?.center = cell.center
                self.snapshot?.transform = CGAffineTransformIdentity
                self.snapshot?.alpha = 0.0
                // Undo fade out.
                cell.alpha = 1.0
                
                }, completion: { (finished) in
                    
                    self.sourceIndexPath = nil
                    self.snapshot?.removeFromSuperview()
                    self.snapshot = nil;
            })
            break
        }
       
    }
    
    // MARK: Helper
    
    public func customSnapshotFromView(inputView: UIView) -> UIView {
        
        // Make an image from the input view.
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        // Create an image view.
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        
        return snapshot
    }
    
    
    
    
    
    
    
    
    
    
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath
        indexPath: NSIndexPath) -> CGFloat {
            
            
            // UIApplication.sharedApplication().statusBarFrame.height in points according to
            //http://stackoverflow.com/questions/20687082/how-do-i-make-my-ios7-uitableviewcontroller-not-appear-under-the-top-status-bar
            
            
            
            if !UIApplication.sharedApplication().statusBarHidden {
            
            return (self.view.frame.size.height - (self.navigationController?.navigationBar.frame.height)! - (UIApplication.sharedApplication().statusBarFrame.height)) / CGFloat(userTablePreferences.count);
            }else{
                return (self.view.frame.size.height - (self.navigationController?.navigationBar.frame.height)!) / CGFloat(userTablePreferences.count);
            }
    }
    

    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
       
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
                
                
                popPC.sourceRect = CGRectMake(270, 15, 5, 10);
                
                popPC.delegate = self;
  
            
           }
        
    }
    
    
    public func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None ;
    }
    
    
    @IBAction func btnShowPopoverOptions (sender: UIBarButtonItem ) {

        self.performSegueWithIdentifier("showViewOptions", sender: self);
    
    }
    
    @IBAction func btnShowPopoverAddRemove(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("showAddOptions", sender: self);
        
    }

    //dismiss the popover before updating the table
    @IBAction func dismissFromAddPopover (segue: UIStoryboardSegue) {
    
    if (!segue.sourceViewController.isBeingDismissed()) {
        
        segue.sourceViewController.dismissViewControllerAnimated(true, completion: nil);
        
    }
    
    
    
    }
    
   
    

}
