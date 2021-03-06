//
//  LoginViewController.swift
//  iGordonSwift
//
//  The class will firstly manage the process of Login by commmunicating with the api server and the CoreData
//  database. The process involves checking a user with an active sessionStatus in the DB, then login at
//  server if necessary. Furthermore, through the segue it also pass data to the MainDataViewController class, such
//  as: TablePreferences and userProfile(login, password).
//
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//
import Foundation
import UIKit
import CoreData


public class LoginViewController: UIViewController, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITextFieldDelegate, UITextViewDelegate {
    
  
    
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
    var dbManagement: DatabaseManagement = DatabaseManagement();
    
    var keyBoardHeight: CGFloat! = 0;
    var viewAdjusted: Bool = false ;
    var loginAttempted: Bool = false;
    
    
    var urlConnection: NSURLConnection = NSURLConnection();


    override public func viewDidLoad() {
        
        txtUserName?.delegate = self
        txtPassword?.delegate = self
  
    }

    override public func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        viewAdjusted = false
        
    }
    
    
    override public func viewWillAppear(animated: Bool) {
        
        let (userExists, endPointsDBCheckLogin, username, password) = dbManagement.checkUserLoginStatus()
        
        if userExists {
            endPointsFromDB = endPointsDBCheckLogin
            userGordonName = username
            userGordonPassword = password
            
            self.view.hidden = true
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
    

    
    //function used to move the screen when the keyboard appears
    //Parameter: up - Defines if the view should go "up" or be readjusted 
    // to its previous position.
    func animateTextField(up: Bool){
        var movement = (up ? -keyBoardHeight : keyBoardHeight)
        if !viewAdjusted {
            UIView.animateWithDuration(0.3, animations: {
                self.view.frame = CGRectOffset(self.view.frame, 0, movement/2) //move screen up or down by half of the height of the keyboard
                self.viewAdjusted = up
            })
        }
    }
    
    //Function used with the Notification object, to then ask the view to adjust. Obs: Called by the Notification Center
    // not need to call it manually.
    //Paratemer: Notification - Sent by the UIKeyboardWillShowNotification, contains the keyboard height
    // used to adjust the view.
    func keyboardWillShow(notification: NSNotification){
        if let userInfo = notification.userInfo{
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(){
                keyBoardHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    //Called by the Notification Center in order the readjust the view
    func keyboardWillHide(notification: NSNotification){
        self.animateTextField(false)
    }
    
    //used for tab between the txtFields and Done button
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
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
        
       
        
        if( txtUserName.text.length >= 3 && txtPassword.text.length >= 3){
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

        
            
        }else {
            loginAttempted = true
            returnsErrorMessageForLogin()
        }
        
    }
    

    @IBAction func logoutFromPopover(segue: UIStoryboardSegue) {
        
        self.view.hidden = false
        txtUserName.text.removeAll(keepCapacity: true);
        txtPassword.text.removeAll(keepCapacity: true);
        lblEnterCredentials.text = "Enter your credentials for GoGordon";
        lblEnterCredentials.textColor = UIColor.whiteColor();
        
        dbManagement.logoutUserDeletePassword()
    
        if !segue.sourceViewController.isBeingDismissed() {
       
        segue.sourceViewController.dismissViewControllerAnimated(true, completion: nil) ;
            
        }
    
    }
    
    // Since most of the methods in the class belong to native classes, the performLoginAtServer simply initiates
    // the process starting a connection with a determined URL.
    // urlGoco is the official URL for connection with the Gordon College server through Adam Vig api.
    // urlTestHeroku is a simple Python running server hosted ar Heroku, for testing purposes. More at
    //  https://github.com/rodrigoGordon/serverPython
    
    public func performLoginAtServer(){

       
        
        //url used to connect to Goco Server
        let urlString = "http://api.adamvig.com/gocostudent/2.2/checklogin?username=\(userGordonName!)&password=\(userGordonPassword!)"
        
        
        let urlGoco: NSURL = NSURL(string: urlString)!;
        
        
        //url used to connect to the debug server
        let urlTestHeroku: NSURL = NSURL(string: "https://igordonserver.herokuapp.com/igordon/api/v1.0/gordoninfo/chapelcredits?username=iGordon&password=swift")!;
        
        let request = NSMutableURLRequest(URL: urlTestHeroku);
        
        
        request.HTTPMethod = "GET" ;
        urlConnection = NSURLConnection(request: request, delegate: self)!;
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: Selector("returnsErrorMessageForLogin"),
            userInfo: nil, repeats: false)

    }
    
    
    
    // The method manages a badlogin attempt or a server that is not 
    // responding.
    // Variables: loginAttempted - Check if there's was already one attempt of connection
    
    public func returnsErrorMessageForLogin(){
    
        if !loginAttempted {
            loginAttempted = true
            dispatch_async(dispatch_get_main_queue(), {
                //compiler requires to use self here
                
                self.lblEnterCredentials.textColor = UIColor.orangeColor();
                self.lblEnterCredentials.text = "No answer...Trying again"
                self.urlConnection.cancel()
                self.performLoginAtServer()
            });
        }else{
            
        urlConnection.cancel()
        activityLogin.hidden = true
        activityLogin.stopAnimating()
        
        dispatch_async(dispatch_get_main_queue(), {
            //compiler requires to use self.label here
            self.lblEnterCredentials.textColor = UIColor.redColor();
            self.lblEnterCredentials.text = "Please check your credentials"
        });
        }
        
        
    }
    

    public func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        responseData.appendData(data);
    }
    
    public func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        let httpResponse = response as? NSHTTPURLResponse
        httpResponseFromServer = httpResponse!.statusCode
        
    }

    public func connectionDidFinishLoading(connection: NSURLConnection) {
        
        if(httpResponseFromServer == 200 ){
            
            endPointsFromDB = dbManagement.saveLoginGetPreferences(userGordonName, userGordonPassword: userGordonPassword)
            self.performSegueWithIdentifier("goMainDataTableView", sender: mainDataViewController);
            
            //handles the timer if a connection was slow or no responding, meaning to not ask for a new one
            // performed at the method returnErrodBadLogin
            loginAttempted = true
        }
        
    }

    

    

  
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        mainDataViewController = segue.destinationViewController as! MainDataViewController;

        mainDataViewController.userProfile = ["username":userGordonName, "password":userGordonPassword]
                                             as Dictionary<String,String?>  ;
        
        mainDataViewController.userTablePreferences = endPointsFromDB;
        
        
        
    }

  
    

}
