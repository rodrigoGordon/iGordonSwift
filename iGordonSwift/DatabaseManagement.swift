//
//  DatabaseManagement.swift
//  iGordonSwift
//
//  The class will be used for management of any class and its respective data in the App that
//  needs to use CoreData, such as: MainDataViewController, LoginViewController.
//  
//  The operations are based on CREATE, READ, UPDATE, DELETE in sqlLite and Xcode, with two entities:
//  GordonUser and LogResultsFromServer
//
//  Created by Rodrigo on 7/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DatabaseManagement: NSObject {
    
    
    
    
    // LOGIN MANAGEMENT
    
    
    
    //method creates or updates a login in the database, when the login button is pressed on LoginViewController
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
                
                //return the preferences that the user has in the DB
                endPointsFromDB = split(tablePreferences){$0 == ","}
                
                var userGordon = fetchResults[0]
                
                // assigns "in", for the sign in process
                userGordon.sessionStatus = "in"
                var saveError: NSError? = nil
                if !managedContext.save(&saveError){
                    println("Problems logging in:  \(saveError)")
                }
                
                
                
            }
                
            else{
                
                
                //No user found, it creates a new one and returns a complete table preferences
                
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
    
    
    
    
    //Makes a search in the DB in the ViewWillAppear method in LoginViewController, to see if there's still a user logged in,
    //valid for the case that the app is not in the memory anymore
    func checkLoginInDB() -> (Bool, [String],String, String){
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        
        var endPointsFromDB: [String] = []
        var userGordonName: String = ""
        var userGordonPassword: String = ""
        
        
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
        return (userExists, endPointsFromDB, userGordonName, userGordonPassword)
        
    }
    
    
    
    // Makes a search in the DB for the user and set its sessionStatus to out
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

    
    
    
    
    //Method called every time the user update its preferences in the Left Popover menu in the MainDataViewController
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
                
                
                //if the user deselect all options in the popover menu, the table receives a complete new list
                //with the endpoints name
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
    
    
    //Method called when the user selects a cell in the tableView in the MainDataViewController
    func saveSearchOnDB(endPointDescription: String, valueReceivedFromServer: String, userName: String){
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        
        let fetchRequest = NSFetchRequest(entityName: "LogResultsFromServer")
        
        
        //uses "where clause" NSPredicate to search for the respective endpoint selected
        let resultPredicate1 = NSPredicate(format: "idUser==%@", userName)
        let resultPredicate2 = NSPredicate(format: "endPointSearched==%@", endPointDescription)
        
        var compound = NSCompoundPredicate.andPredicateWithSubpredicates([resultPredicate1, resultPredicate2])
        fetchRequest.predicate = compound
        
        
        if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [LogResultsFromServer]{
            
            if fetchResults.count >= 1{
                
                var logUpdate = fetchResults[0]
                //save the current date
                logUpdate.dateOfSearch = NSDate()
                logUpdate.valueReceived = valueReceivedFromServer
                
                var saveError: NSError? = nil
                
                if !managedContext.save(&saveError){
                    println("Problems logging out:  \(saveError)")
                }
                
            }else{
                //creates a new entry in the table, since there's no result from the DB
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
    
    
    //Method used mostly to idenfity how old the information about the endpoints is and also return 
    //its respective value
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
        
        // return 0 if new(less than 10 hours) (.) , 1 if avg(..) , 2 if old ( more than a day )(...)
        return (logReturn,endPointValue)
    }
    
    


    
    
    
   
}
