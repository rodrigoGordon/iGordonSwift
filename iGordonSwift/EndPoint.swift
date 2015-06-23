//
//  EndPoint.swift
//  iGordonSwift
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import Foundation
import UIKit

class EndPoint: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate{
    
    
    
    var name: String = "",
        cellDescription: String = "",
        value : String = "",
        image: String = "" ;
    
    
    var colorRGB: [CGFloat] = [0, 0 ,0];
    
    var responseData: NSMutableData  = NSMutableData();
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        responseData .appendData(data);
        
    }
    func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse? {
        return nil;
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
        
        let jsonObjectFromServer: AnyObject! =
        NSJSONSerialization.JSONObjectWithData(
            responseData,
            options: NSJSONReadingOptions(0),
            error:  nil)
        
        if let json = jsonObjectFromServer as? Dictionary<String, AnyObject>{
            
            if let id: AnyObject = json["data"] as AnyObject?  {

                // using description to handle any object that comes from the server
                value = id.description
                
                NSNotificationCenter.defaultCenter().postNotificationName("dataRetrievedFromServer",
                                                                          object: self, userInfo: [name: value]);
            }
  
        }
        else{
          println("Error while parsing the data") ;
        }

        
        
    }
    
    func loadDataFromServer(userProfile: Dictionary<String,String?>){
        
      
        var username: String = userProfile["username"]!! ,
            password: String = userProfile["password"]!!  ;
        
        //Goco Server
        let urlString = "http://api.adamvig.com/gocostudent/2.2/\(name)?username=\(username)&password=\(password)"
        
        let urlGoco: NSURL = NSURL(string: urlString)!
        
        //debug server
        let urlDebug = NSURL(string: "https://igordonserver.herokuapp.com/igordon/api/v1.0/gordoninfo/"+name+"?username=iGordon&password=swift");
        
        let request = NSMutableURLRequest(URL: urlGoco);
        request.HTTPMethod = "GET" ;
        let urlConnection = NSURLConnection(request: request, delegate: self);
        
        
    }
    
    
    
}
