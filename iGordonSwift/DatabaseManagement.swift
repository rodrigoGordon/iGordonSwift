//
//  DatabaseManagement.swift
//  iGordonSwift
//
//  Created by Rodrigo on 7/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DatabaseManagement: NSObject {
    
    
    
    
    // LOGIN MANAGEMENT
    
    func saveLoginInDB(userGordonName: String?, userGordonPassword: String?) -> [String]{
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        var endPointsFromDB: [String] = []
        
        
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
                }
            }
        }
        
        return endPointsFromDB
    }
    
    
    func checkLoginInDB() -> (Bool, [String],String, String){
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        
        var endPointsFromDB: [String] = []
        var userGordonName: String?
        var userGordonPassword: String?
        
        
        let fetchRequest = NSFetchRequest(entityName: "GordonUser")
        let predicate = NSPredicate(format: "sessionStatus==%@", "in")
        fetchRequest.predicate = predicate
        var userExists: Bool = false
        
        if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [GordonUser]{
            
            
            if (fetchResults.count >= 1) {
                
                
                var tablePreferences: String = fetchResults[0].tablePreferences
                
                endPointsFromDB = split(tablePreferences){$0 == ","}
                
                userGordonName = fetchResults[0].username
                userGordonPassword = fetchResults[0].password
                
                userExists = true
                
                
            }
            
            
        }
        return (userExists, endPointsFromDB, userGordonName!, userGordonPassword!)
        
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
    
    
    // SEARCH ON SERVER MANAGEMENT

    func updateUserPreferencesInDB(userTablePreferences: [String]){
        
        
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
            println("Error loading the data at update from user preferences")
        }
        
    }
    
    func saveSearchOnDB(endPointDescription: String, valueReceivedFromServer: String, userName: String){
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        
        let fetchRequest = NSFetchRequest(entityName: "LogResultsFromServer")
        
        let resultPredicate1 = NSPredicate(format: "idUser==%@", userName)
        let resultPredicate2 = NSPredicate(format: "endPointSearched==%@", endPointDescription)
        
        var compound = NSCompoundPredicate.andPredicateWithSubpredicates([resultPredicate1, resultPredicate2])
        fetchRequest.predicate = compound
        
        
        if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [LogResultsFromServer]{
            
            if fetchResults.count >= 1{
                
                var logUpdate = fetchResults[0]
                logUpdate.dateOfSearch = NSDate()
                logUpdate.valueReceived = valueReceivedFromServer
                
                var saveError: NSError? = nil
                
                if !managedContext.save(&saveError){
                    println("Problems logging out:  \(saveError)")
                }
                
            }else{
                
                var logs = NSEntityDescription.insertNewObjectForEntityForName("LogResultsFromServer",
                    inManagedObjectContext: managedContext) as! LogResultsFromServer
                
                logs.idUser = userName
                logs.endPointSearched = endPointDescription
                logs.dateOfSearch = NSDate()
                logs.valueReceived = valueReceivedFromServer
                var error: NSError?
                if !managedContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }else{
                    println("Log created in the DB")
                }
                
            }
            
            
        }else{
            println("Error while trying to save or update a log")
        }
        
    }
    
    func loadLastSearchFromDB(endPointDescription: String, userName: String) -> (Int, String?){
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "LogResultsFromServer")
        let resultPredicate1 = NSPredicate(format: "idUser==%@", userName)
        let resultPredicate2 = NSPredicate(format: "endPointSearched==%@", endPointDescription)
        
        var compound = NSCompoundPredicate.andPredicateWithSubpredicates([resultPredicate1, resultPredicate2])
        fetchRequest.predicate = compound
        
        var logReturn: Int = 0
        var endPointValue: String?
        
        if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [LogResultsFromServer]{
            
            
            if (fetchResults.count >= 1) {
                
                //total in hours that the last logs was recorded
                let logPeriod = (fetchResults[0].dateOfSearch.timeIntervalSinceNow)/3600
                
                let value = fetchResults[0].valueReceived
                endPointValue = value
                
                if logPeriod < -10 && logPeriod > -24{
                    logReturn = 1
                }else if logPeriod < -24{
                    logReturn = 2
                }
                
                
                
            }else {
                logReturn = 2
            }
            
            
        }else{
            println("Error trying to retrieve the logs")
        }
        
        // return 0 if new (.) , 1 if avg(..) , 2 if old ( more than a day )(...)
        return (logReturn,endPointValue)
    }
    
    


    
    
    
   
}
