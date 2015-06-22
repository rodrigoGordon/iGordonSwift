//
//  LoginViewController.swift
//  iGordonSwift
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//
import Foundation
import UIKit



class LoginViewController: UIViewController, NSURLConnectionDelegate, NSURLConnectionDataDelegate {

    
    var responseData: NSMutableData  = NSMutableData();
    
    var userGordoName: String? ,
        userGordonPassword: String?;
    
    var httpResponseFromServer: Int?;
    var mainDataViewController: MainDataViewController = MainDataViewController();
    
    
    @IBOutlet weak var imgLogoiGordon: UIImageView!
    
    @IBOutlet weak var txtUserName: UITextField!
    
    
    @IBOutlet weak var txtPassword: UITextField!
    
    
    @IBOutlet weak var lblEnterCredentials: UILabel!
    
    
    @IBAction func btnLogin(sender: UIButton) {
        
        userGordoName = txtUserName.text ;
        
        
       // userGordonPassword = txtPassword.text.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        userGordonPassword = txtPassword.text ;
     
        //self.performSegueWithIdentifier("goMainDataTableView", sender: mainDataViewController);
        
        performLoginAtServer();
        
    }
    
    
    @IBAction func logoutFromPopover(segue: UIStoryboardSegue) {

    
    if !segue.sourceViewController.isBeingDismissed() {
       segue.sourceViewController.dismissViewControllerAnimated(true, completion: nil) ;
    }
    
    
    }
    

    
    
    func performLoginAtServer(){

        let username = "iGordon", password = "swift" ;
        let url = NSURL(string: "https://igordonserver.herokuapp.com/igordon/api/v1.0/gordoninfo/chapelcredits?username=iGordon&password=swift");
        let request = NSMutableURLRequest(URL: url!);
        request.HTTPMethod = "GET" ;
        let urlConnection = NSURLConnection(request: request, delegate: self);
        

    }
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        mainDataViewController.userProfile = ["username":userGordoName, "password":userGordonPassword]
                                             as Dictionary<String,String?>  ;
        
        
        
        
    }
    

}
