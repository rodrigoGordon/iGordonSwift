//
//  LoginViewController.swift
//  iGordonSwift
//
//  The class will manage the process of talking with tthe server and the CoreData
//   SqlLite database. A main constraint is sessionStatus which represents simply "in" or "out",
//   using as a way to define if the app is not in the memory anymore but the user still logged "in"
//
//
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//
import Foundation
import UIKit
import CoreData


class LoginViewController: UIViewController, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITextFieldDelegate, UITextViewDelegate {
    
  
    
    @IBOutlet weak var imgLogoiGordon: UIImageView!
    
    @IBOutlet weak var txtUserName: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var lblEnterCredentials: UILabel!
    
    @IBOutlet weak var activityLogin: UIActivityIndicatorView!
    
    
    var responseData: NSMutableData  = NSMutableData();
    
    var userGordonName: String?  = "",
    userGordonPassword: String? = "";
    
    var endPointsFromDB: [String] = [];
    
    var httpResponseFromServer: Int = 0;
    var mainDataViewController: MainDataViewController = MainDataViewController();
    var keyBoardHeight: CGFloat! = 0;
    var viewAdjusted: Bool = false ;
    var urlConnection: NSURLConnection = NSURLConnection();


    override func viewDidLoad() {
        
        txtUserName?.delegate = self
        txtPassword?.delegate = self
  
    }

    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        viewAdjusted = false
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        if checkLoginInDB() {
            self.performSegueWithIdentifier("goMainDataTableView", sender: mainDataViewController);
        }
        
        super.viewWillAppear(animated)
        

        activityLogin.hidden = true
        self.navigationController?.navigationBar.hidden = true;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"),
            name:UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"),
            name:UIKeyboardWillHideNotification, object: nil)
        
 
    }
    
    
    
    //function used to move the txtFields when the keyboard appears
    func animateTextField(up: Bool){
        var movement = (up ? -keyBoardHeight : keyBoardHeight)
        if !viewAdjusted{
            UIView.animateWithDuration(0.3, animations: {
                self.view.frame = CGRectOffset(self.view.frame, 0, movement/2) //move screen up or down by half of the height of the keyboard
                self.viewAdjusted = up
            })
        }
    }
    
    
    func keyboardWillShow(notification: NSNotification){
        if let userInfo = notification.userInfo{
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(){
                keyBoardHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        self.animateTextField(false)
    }
    
    //used for tab between the txtFields and Done button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == txtUserName{
            txtPassword.becomeFirstResponder()
        }else if textField == txtPassword{
            txtPassword.resignFirstResponder()
            viewAdjusted = false
            animateTextField(false)
        }
        return true
    }
    
    
    

    @IBAction func btnLogin(sender: UIButton) {
        
       
        userGordonName = txtUserName.text
        
        userGordonPassword = txtPassword.text.dataUsingEncoding(NSUTF8StringEncoding)?
            .base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        performLoginAtServer()
        
        activityLogin.hidden = false
        activityLogin.startAnimating()
        
        
        
        
        //needed to adjust the screen if the user press "All done!" instead of "Done" button in the keyboard
        if viewAdjusted {
            txtPassword.resignFirstResponder()
            viewAdjusted = false
            animateTextField(false)
        }
        
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("returnsErrorMessageBadLogin"),
            userInfo: nil, repeats: false)
        
    }
    

    @IBAction func logoutFromPopover(segue: UIStoryboardSegue) {
        
        txtUserName.text.removeAll(keepCapacity: true);
        txtPassword.text.removeAll(keepCapacity: true);
        lblEnterCredentials.text = "Enter your credentials for GoGordon";
        lblEnterCredentials.textColor = UIColor.whiteColor();
        
        logoutInDB()
    
        if !segue.sourceViewController.isBeingDismissed() {
       
        segue.sourceViewController.dismissViewControllerAnimated(true, completion: nil) ;
            
        }
    
    
    }
    

    
    
    
    func performLoginAtServer(){

       
        
        //url used to connect to Goco Server
        let urlString = "http://api.adamvig.com/gocostudent/2.2/checklogin?username=\(userGordonName!)&password=\(userGordonPassword!)"
        
        
        let urlGoco: NSURL = NSURL(string: urlString)!;
        
        
        //url used to connect to the debug server
        let url: NSURL = NSURL(string: "https://igordonserver.herokuapp.com/igordon/api/v1.0/gordoninfo/chapelcredits?username=iGordon&password=swift")!;
        
        let request = NSMutableURLRequest(URL: url);
        
        
        request.HTTPMethod = "GET" ;
        urlConnection = NSURLConnection(request: request, delegate: self)!;
        


    }
    
    
    func returnsErrorMessageBadLogin(){
        
        urlConnection.cancel()
        activityLogin.hidden = true
        activityLogin.stopAnimating()
        
        dispatch_async(dispatch_get_main_queue(), {
            //compiler requires to use self.label here
            
            self.lblEnterCredentials.textColor = UIColor.redColor();
            self.lblEnterCredentials.text = "Incorrect credentials"
        });
        
        
        
    }
    
    
    
    

    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        responseData.appendData(data);
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        
        let httpResponse = response as? NSHTTPURLResponse
        httpResponseFromServer = httpResponse!.statusCode
        
    }
    
    func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse? {
        return nil;
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
        if(httpResponseFromServer == 200 ){
            
            saveLoginInDB()
            self.performSegueWithIdentifier("goMainDataTableView", sender: mainDataViewController);
            
        }
        
    }

    

    

  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        mainDataViewController = segue.destinationViewController as! MainDataViewController;

        mainDataViewController.userProfile = ["username":userGordonName, "password":userGordonPassword]
                                             as Dictionary<String,String?>  ;
        
        mainDataViewController.userTablePreferences = endPointsFromDB;
        
        
        
    }
    
    
    
    func saveLoginInDB(){
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        

        let fetchRequest = NSFetchRequest(entityName: "GordonUser")
        let predicate = NSPredicate(format: "username==%@", userGordonName!)
        fetchRequest.predicate = predicate
        
        if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [GordonUser]{
            
            
            if (fetchResults.count >= 1) {
                
                var tablePreferences: String = fetchResults[0].tablePreferences;
                endPointsFromDB = split(tablePreferences){$0 == ","}
                var userGordon = fetchResults[0]
                userGordon.sessionStatus = "in"
                var saveError: NSError? = nil
                if !managedContext.save(&saveError){
                    println("Problems logging in:  \(saveError)")
                }
                
                
                
            }
            
           else{
        
            
            let userDB = NSEntityDescription.insertNewObjectForEntityForName("GordonUser",
                inManagedObjectContext: managedContext) as! GordonUser
            userDB.username = userGordonName!;
            userDB.password = userGordonPassword!;
            userDB.sessionStatus = "in";
            userDB.tablePreferences = "chapelcredits,mealpoints,mealpointsperday,daysleftinsemester,studentid,temperature"
            endPointsFromDB = split(userDB.tablePreferences){$0 == ","}
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }else{
                println("User created in the DB")
            }
        }
    }
    
    }
    
    
    func checkLoginInDB() -> Bool{
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "GordonUser")
        let predicate = NSPredicate(format: "sessionStatus==%@", "in")
        fetchRequest.predicate = predicate
        var userExists: Bool = false
        if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [GordonUser]{
            
            
            if (fetchResults.count >= 1) {
                
  
                var tablePreferences: String = fetchResults[0].tablePreferences;
                endPointsFromDB = split(tablePreferences){$0 == ","}
                userGordonName = fetchResults[0].username
                userGordonPassword = fetchResults[0].password
                userExists = true
                
            
            }
            
            
        }
        return userExists
        
    }
    
    
    func logoutInDB(){
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "GordonUser")
        let predicate = NSPredicate(format: "sessionStatus==%@", "in")
        fetchRequest.predicate = predicate
        
        if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [GordonUser]{
            
            
            if (fetchResults.count >= 1) {
                
                var userGordon = fetchResults[0]
                userGordon.sessionStatus = "out"
                userGordon.password = ""
                var saveError: NSError? = nil
                if !managedContext.save(&saveError){
                  println("Problems logging out:  \(saveError)")
                }
                
            }
            
            
        }else{
            println("Error loading the data")
        }
        
        
        
        
    }
    
    
  
    

}
