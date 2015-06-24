//
//  LoginViewController.swift
//  iGordonSwift
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//
import Foundation
import UIKit



class LoginViewController: UIViewController, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITextFieldDelegate, UITextViewDelegate {

    
    var responseData: NSMutableData  = NSMutableData();
    
    var userGordonName: String? ,
        userGordonPassword: String?;
    
    var httpResponseFromServer: Int?;
    var mainDataViewController: MainDataViewController = MainDataViewController();
    var keyBoardHeight: CGFloat!;
    var viewAdjusted: Bool = false ;
    
    @IBOutlet weak var imgLogoiGordon: UIImageView!
    
    @IBOutlet weak var txtUserName: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var lblEnterCredentials: UILabel!
    
    @IBAction func btnLogin(sender: UIButton) {
        
        
        userGordonName = txtUserName.text
        
        userGordonPassword = txtPassword.text.dataUsingEncoding(NSUTF8StringEncoding)?
                                        .base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))

        performLoginAtServer()
        
        activityLogin.hidden = false
        activityLogin.startAnimating()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("returnsErrorMessageBadLogin"),
                                                           userInfo: nil, repeats: false)
        
        
        //needed to adjust the screen if the user press "All done!" instead of "Done" button in the keyboard
        if viewAdjusted {
            txtPassword.resignFirstResponder()
            viewAdjusted = false
            animateTextField(false)
        }
    
    }
    
    @IBOutlet weak var activityLogin: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        txtUserName?.delegate = self
        txtPassword?.delegate = self
        
        
  
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
    
  
    
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        viewAdjusted = false
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        activityLogin.hidden = true
        self.navigationController?.navigationBar.hidden = true;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"),
            name:UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"),
            name:UIKeyboardWillHideNotification, object: nil)
 
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
    
    
    @IBAction func logoutFromPopover(segue: UIStoryboardSegue) {
        
        txtUserName.text.removeAll(keepCapacity: true);
        txtPassword.text.removeAll(keepCapacity: true);
        lblEnterCredentials.text = "Enter your credentials for GoGordon";
        lblEnterCredentials.textColor = UIColor.whiteColor();
    
        if !segue.sourceViewController.isBeingDismissed() {
       
        segue.sourceViewController.dismissViewControllerAnimated(true, completion: nil) ;
            
        }
    
    
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
    
    
    
    func performLoginAtServer(){

       
        
        //url used to connect to Goco Server
        let urlString = "http://api.adamvig.com/gocostudent/2.2/checklogin?username=\(userGordonName!)&password=\(userGordonPassword!)"
        
        
        let urlGoco: NSURL = NSURL(string: urlString)!;
        
        
        //url used to connect to the debug server
        let url = NSURL(string: "https://igordonserver.herokuapp.com/igordon/api/v1.0/gordoninfo/chapelcredits?username=iGordon&password=swift");
        
        let request = NSMutableURLRequest(URL: urlGoco);
        
        
        request.HTTPMethod = "GET" ;
        let urlConnection = NSURLConnection(request: request, delegate: self);


    }

    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        responseData .appendData(data);
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
            self.performSegueWithIdentifier("goMainDataTableView", sender: mainDataViewController);
        }else{
            returnsErrorMessageBadLogin();
        }

        
    }

    
    func returnsErrorMessageBadLogin(){
    
        activityLogin.hidden = true
        activityLogin.stopAnimating()
    
        dispatch_async(dispatch_get_main_queue(), {
            //compiler requires to use self.label here
            
            self.lblEnterCredentials.textColor = UIColor.redColor();
            self.lblEnterCredentials.text = "Incorrect credentials"
        });
        
        
    
    }
    

  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        mainDataViewController = segue.destinationViewController as! MainDataViewController;

        mainDataViewController.userProfile = ["username":userGordonName, "password":userGordonPassword]
                                             as Dictionary<String,String?>  ;
        
        
        
        
    }
    

}
