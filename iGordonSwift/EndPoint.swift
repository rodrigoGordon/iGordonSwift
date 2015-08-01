//
//  EndPoint.swift
//  iGordonSwift
//
//  The main Model in the App. The class mostly perform operations to load data from the Server and return its attributes.
//   The connection with Gordon and Test server is based on NSURLConnectionDelegate.
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import Foundation
import UIKit

public class EndPoint: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate{
    
    
    
    var name: String = "",
        cellDescription: String = "",
        value : String = "",
        image: String = "" ;
    
    
    var colorRGB: [CGFloat] = [0, 0 ,0];
    
    var responseData: NSMutableData  = NSMutableData();
    
    
    
    public init(nameInit: String, cellDescriptionInit: String, imageInit: String, colorRGBInit: [CGFloat]) {
        self.name = nameInit
        self.cellDescription = cellDescriptionInit
        self.image = imageInit
        self.colorRGB = colorRGBInit
    }
    
    public func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        responseData.appendData(data);
        
    }
    public func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse? {
        return nil;
    }
    
    public func connectionDidFinishLoading(connection: NSURLConnection) {
        
        
        let jsonObjectFromServer: AnyObject! =
        NSJSONSerialization.JSONObjectWithData(
            responseData,
            options: NSJSONReadingOptions(0),
            error:  nil)
        
        responseData = NSMutableData() //reset the data object to receive new requests
        
        
        if let json = jsonObjectFromServer as? Dictionary<String, AnyObject>{
            
            if let id: AnyObject = json["data"] as AnyObject?  {

                // using description to handle any object that will be received from the server from the server
                value = id.description
                
                NSNotificationCenter.defaultCenter().postNotificationName("dataRetrievedFromServer",
                                                                          object: self, userInfo: [name: value]);
            }
  
        }
        else{
          println("Error while parsing the data") ;
        }

        
        
    }
    
    
    // Function called whenever a determined class need the Endpoint newest data from the Server. Parameter:
    // userProfile - Simply the username and password( base64 for Gordon Server - Adam Vig api )
    // It creates a connection object and lets the delegate manage it
    public func loadDataFromServer(userProfile: Dictionary<String,String?>){
        
      
        var username: String? = userProfile["username"]!
        var password: String? = userProfile["password"]!  ;
        
        //Goco Server
        let urlString = "http://api.adamvig.com/gocostudent/2.2/\(name)?username=\(username!)&password=\(password!)"
        
        let urlGoco: NSURL = NSURL(string: urlString)!
        
        //debug server
        let urlDebug = NSURL(string: "https://igordonserver.herokuapp.com/igordon/api/v1.0/gordoninfo/"+name+"?username=iGordon&password=swift");
        
        let request = NSMutableURLRequest(URL: urlDebug!);
        request.HTTPMethod = "GET" ;
        let urlConnection = NSURLConnection(request: request, delegate: self);
        
        
    }
    
    
    
}
