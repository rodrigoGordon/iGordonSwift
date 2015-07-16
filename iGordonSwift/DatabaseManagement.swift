//
//  DatabaseManagement.swift
//  iGordonSwift
//
//  DatabaseManagement provides stable on-device storage and some associated "business logic" for the
//  following entities:
//      GordonUser - Stores username and preferences for each user who has logged in from this device.
//          Stores password at login, and deletes password on logout.
//          Retrieves credentials for currently logged-in user.
//      LogResultsFromServer - for each user, stores and retrieves the value and last-update-time
//          for each item listed in their preferences.
//
//  (This class is used primarily by MainDataViewController, LoginViewController to manage their respective data.
//  Any other classes with similar data to manage should extend this class to do so.)
//
//  Created by Rodrigo on 7/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DatabaseManagement: NSObject {
    
    
    
    
    // LOGIN MANAGEMENT
    
    // Stores username and password (over-writing any old password for this user), and
    // returns the user's preferences.  If the user doesn't have stored preferences,
    // default preferences are generated, stored, and returned.  Existing preferences
    // are not modified.  Usernames should be validated (by logging into the server)
    // before being used as arguments.
    //
    // Arguments:
    //   userGordonName - username (typically first.last), without "@gordon.edu"
    //   userGordonPassword - base64 encoded password for this user
    // Returns:
    //   The user's preferences, as an array of strings identifying values to display.
    //   If userGordonName is invalid (nil or empty string), then an empty array will be
    //   returned.

    func saveLoginGetPreferences(userGordonName: String?, userGordonPassword: String?) -> [String]{
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
                userGordon.password = userGordonPassword!
                var saveError: NSError? = nil
                if !managedContext.save(&saveError){
                    println("Problems logging in:  \(saveError)")
                }
                
                // TODO: save password (in case they just logged back in or changed password)
                
            }
                
            else{
                
                
                //No user found, it creates a new one and returns a complete table preferences
                
                let userDB = NSEntityDescription.insertNewObjectForEntityForName("GordonUser",
                    inManagedObjectContext: managedContext) as! GordonUser
                userDB.username = userGordonName!;
                userDB.password = userGordonPassword!;
                userDB.sessionStatus = "in";
                userDB.tablePreferences =
                "chapelcredits,mealpoints,mealpointsperday,daysleftinsemester,studentid,temperature"
                endPointsFromDB = split(userDB.tablePreferences){$0 == ","}
                var error: NSError?
                if !managedContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
            }
        }
        
        return endPointsFromDB
    }
    
    
    
    
    // Performs a search in the database - specifically in the entity GordonUser, for a user with sessionStatus = "in", if
    // found returns the following:
    //
    // Returns:
    //   UserExists - Bool, simply a true/false that tells if the search found any user logged in, which is defined by the field
    //      sessionStatus("in" or "out") in the GordonUser entity.
    //   endPointsFromDB - Array of Strings, which corresponds to the user preferences in the DB.
    //   username - The String representation of username for use in the authentication process with Gordon server.
    //   password - The String base64 encoded representation of password also used for authentication with Gordon server.
    
    // In the case of no user found logged in, the userExists will be FALSE and SHOULD be used as a validation parameter, for
    // FIX ENGLISH!// no attempts to use the other return values such as endPointsFromDB and userGordonName, which will be empty.
    
    func checkUserLoginStatus() -> (Bool, [String],String, String){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
    
    
    //
    // Finds the user that is logged in then set its sessionStatus to "out", Then
    // for security deletes its password, in case the app is not in the user's phone,
    // but in a friend's one for example.
    //
    // The method is supposed to be called when the user is logged in,
    // so it will always find a user to logout. Such as: from a popover inside
    // a main view.
    func logoutUserDeletePassword(){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
    
    
    // SEARCH ON SERVER - MANAGEMENT
    
    
    // The method performs an update in the field userTablePreferences in the table GordonUser
    // for the logged in user
    
    // Parameter:
    //   Array of Strings: userTablePreferences - Contains each of the endpoints names, in order, as edited by
    //   the user. (It's saved as a String in GordonUser, separated by commas.)
    
    // In case of a null parameter or a user that passes an empty array, there's no exception but the default
    // preferences are saved instead.
    
    func updateUserTablePreferences(userTablePreferences: [String]){
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
    
    //REDO FIRST SENTENCE
    //For the control of the "age" of the information, the following mothod is defined as:
    //Arguments:
    //    endPointDescription  - Receives the name of the endpoint; i.e: "chapelcredits"
    //    valueReceivedFromServer - String that represents the current value for that endpoint that comes from the server,
    //      i.e: "32" (for chapelcredits).
    //    userName - Username for the specific association with its respective endpoint, since the app can
    //        have multiple users
    // Basic operation: A new log is created if there's no result from the search, if yes, the valueReceivedFromServer
    //        is updated and so it is the dataSearched, used to validate how old is the information, mostly used in the 
    //        method loadLastEndPointSearch
    
    func saveEndPointSearch(endPointDescription: String, valueReceivedFromServer: String, userName: String){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
    
    
    // Main Function: Makes a individual search for an endpointname and its owner(username), if found,
    //  compares the current date with the endpoint date of save in the database, then decides how old
    //  the information is.
    // Arguments:
    //   endPointDescription  - Receives the name of the endpoint; i.g: "chapelcredits"
    //    userName - Username for the specific association with its respective endpoint, since the app can
    //        have multiple users
    // Returns:
    // logPeriod: Int - Returns a value between 0 .. 2 , for 0(less than 10 hours since last search), 1(between
    //  10 and 24 hours), 2 for more than 24 hours.
    // logValue: String? - Returns the most recent stored value for that respective endpoint.

    
    func loadLastEndPointSearch(endPointDescription: String, userName: String) -> (Int, String?){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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