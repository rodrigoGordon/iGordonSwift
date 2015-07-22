//
//  iGordonSwiftTests.swift
//  iGordonSwiftTests
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import UIKit
import XCTest
import Foundation
import iGordonSwift
import CoreData


class iGordonSwiftTests: XCTestCase {
    
    var loginObj: LoginViewController!
    var maindDataObj: MainDataViewController!
    var userPreferencesObj: UserPreferencesViewController!
    var userOptionsObj: UserOptionsMenuPopover!
    var endPointObj: EndPoint!
    var tableViewCellCustom: TableViewCellUserDataCustom!

    override func setUp() {
        super.setUp()
        self.loginObj = LoginViewController()
        self.maindDataObj = MainDataViewController()
        self.userPreferencesObj = UserPreferencesViewController()
        self.userOptionsObj = UserOptionsMenuPopover()
        self.endPointObj = EndPoint()
        self.tableViewCellCustom = TableViewCellUserDataCustom()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadViews(){

        XCTAssertNotNil(loginObj.view, "View did not load for LoginViewController")
        XCTAssertNotNil(maindDataObj.view, "View did not load for MainDataViewController")
        XCTAssertNotNil(userPreferencesObj.view, "View did not load for UserPreferencesViewController")
        XCTAssertNotNil(userOptionsObj.view, "View did not load for UserOptionsMenuViewController")
        
        
    }
    
    func testNotNilVariables(){
        //EndPoint variables
        XCTAssertNotNil(endPointObj.responseData, "Response data is nil")
        
        //LoginViewController variables
        XCTAssertNotNil(loginObj.userGordonName, "username is nil")
        XCTAssertNotNil(loginObj.userGordonPassword, "Userpassword is nil")
        XCTAssertNotNil(loginObj.httpResponseFromServer, "httpResponse is nil")
        XCTAssertNil(loginObj.activityLogin, "activity Indicator is nil")
        //test for a cancel of non existent request
        loginObj.returnsErrorMessageBadLogin()
        
        loginObj.performLoginAtServer()
        XCTAssertNotNil(loginObj.urlConnection, "Connection is nil!! Please Review perforLoginAtServer method!!")
        XCTAssertNotNil(loginObj.keyBoardHeight, "keyboardheight is nil")
        
        //MainDataViewController variables
        XCTAssertTrue(maindDataObj.userProfile.isEmpty, "userProfile is not empty!!")
        XCTAssertNotNil(maindDataObj.endPointsDictionary, "endpoints dictionary is nil")
        
        
        
    }
    
    
    func testDBForDates() {
        
        
       
        
        //testing code from andrewcbancroft.com/2015/01/13/unit-testing-model-layer-core-data-swift
        
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
        let persistenStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        persistenStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
        
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistenStoreCoordinator
        /*
        let fetchRequest = NSFetchRequest(entityName: "LogResultsFromServer")
        
        let resultPredicate1 = NSPredicate(format: "idUser==%@", "iGordon")
        let resultPredicate2 = NSPredicate(format: "endPointSearched==%@", "chapelcredits")
        
        var compound = NSCompoundPredicate.andPredicateWithSubpredicates([resultPredicate1, resultPredicate2])
        fetchRequest.predicate = compound
        
        
        if let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [LogResultsFromServer]{
            
            if fetchResults.count >= 1{
                
                var logUpdate = fetchResults[0]
                logUpdate.dateOfSearch = NSDate(timeIntervalSinceNow: -10000000000)
                logUpdate.valueReceived = "32"
                
                var saveError: NSError? = nil
                
                if !managedObjectContext.save(&saveError){
                    println("Problems logging out:  \(saveError)")
                }
                println("Data saved")
                
            }else{
                //creates a new entry in the table, since there's no result from the DB
                */
               // var logs = NSEntityDescription.insertNewObjectForEntityForName("LogResultsFromServer",
                 //   inManagedObjectContext: managedObjectContext) as! LogResultsFromServer
                
        
                var logs: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("LogResultsFromServer",
                    inManagedObjectContext: managedObjectContext)
        println(logs.description)
        
        if let test = logs as? LogResultsFromServer{
            println("CAST WORKS!!!")
        }
        
                /*
                logs.idUser = "iGordon"
                logs.endPointSearched = "chapelcredits"
                logs.dateOfSearch = NSDate(timeIntervalSinceNow: -10000000000)
                logs.valueReceived = "32"
                */
                var error: NSError?
                if !managedObjectContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }else{
                    println("Log created in the DB")
                }
                
            //}
        //}

        //let testPeriod = 2
        let dbManagement: DatabaseManagement = DatabaseManagement()
        let (testPeriod, endPointValue) = dbManagement.testMethodForTestTarget("chapelcredits", userName: "iGordon", managedContext: managedObjectContext)
        println("**********************")
        println(testPeriod)
        println(endPointValue)
        println("**********************")
        XCTAssertEqual(testPeriod, 2, "Variable testPeriod is old enough according to the test")
 
    }
    
    
    
    
    func testExample() {
        
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            
        }
    }
    */
    
}
