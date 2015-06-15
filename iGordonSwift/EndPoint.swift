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
    
    
    
    var name: String = "", cellDescription: String = "", value : String = "", image: String = "" ;
    
    var colorRGB: [CGFloat] = [0, 0 ,0];
    var responseData: NSMutableData  = NSMutableData();
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        responseData .appendData(data);
    }
    func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse? {
        return nil;
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
       
        let jsonObjectFromServer: AnyObject? =
        NSJSONSerialization.JSONObjectWithData(
            responseData,
            options: nil,
            error:  nil)
        
       
        
        if let json = jsonObjectFromServer as? Dictionary<String, AnyObject> {
            
            if let id = json["data"] as AnyObject? as? String {
                
                value = id ;
                

                NSNotificationCenter.defaultCenter().postNotificationName("dataRetrievedFromServer",
                                                            object: self, userInfo: [name: value]);
                
            }
        
        }else{
            println("Error while parsing the data") ;
        }
        
    }
    
    func loadDataFromServer(userProfile: Dictionary<String,String?>){
        
        /* This part will be done when the copyServer is ready.
        var requestString = "http://api.adamvig.com/gocostudent/2.2/";
        
        requestString = requestString.stringByAppendingFormat("%@%@%@%@%@", name, "?username=", userProfile["username"]! ,
            "&password=" , userProfile["password"]!);
        
        
        
        var request: NSURLRequest = NSURLRequest(URL: NSURL(string: requestString)!);
        
        var conn: NSURLConnection = NSURLConnection(request: request, delegate: self)!;
        
        */
        
        value = "TEST"+name ;
        NSNotificationCenter.defaultCenter().postNotificationName("dataRetrievedFromServer",
            object: self, userInfo: [name: value]);
        
    }
    
    
    
}
