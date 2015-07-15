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

    override func setUp() {
        super.setUp()
        self.loginObj = LoginViewController()
        self.maindDataObj = MainDataViewController()
        self.userPreferencesObj = UserPreferencesViewController()
        self.userOptionsObj = UserOptionsMenuPopover()
        self.endPointObj = EndPoint()
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
        XCTAssertNotNil(maindDataObj.btnReorder, "btnReorder is nil")
        XCTAssertNotNil(maindDataObj.btnShowAddOption, "btnShowAddOption is nil")
        
        
    }
    
    
    func testDBForDates() {
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        
        let fetchRequest = NSFetchRequest(entityName: "LogResultsFromServer")
        
        let resultPredicate1 = NSPredicate(format: "idUser==%@", "iGordon")
        let resultPredicate2 = NSPredicate(format: "endPointSearched==%@", "chapelcredits")
        
        var compound = NSCompoundPredicate.andPredicateWithSubpredicates([resultPredicate1, resultPredicate2])
        fetchRequest.predicate = compound
        
        
        if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [LogResultsFromServer]{
            
            if fetchResults.count >= 1{
                
                var logUpdate = fetchResults[0]
                logUpdate.dateOfSearch = NSDate(timeIntervalSinceNow: -10000000000)
                logUpdate.valueReceived = "32"
                
                var saveError: NSError? = nil
                
                if !managedContext.save(&saveError){
                    println("Problems logging out:  \(saveError)")
                }
                println("Data saved")
                
            }
        }

        var mainDataObj: MainDataViewController = MainDataViewController()
        
        let (testPeriod, endPointVlaue) = mainDataObj.dbManagement.loadLastEndPointSearch("chapelcredits", userName: "iGordon")
        
        XCTAssertEqual(testPeriod, 2, "Variable testPeriod is old enough according to the test")
        
        
        
    }
    
    
    
    
    func testExample() {
        
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            
        }
    }
    
}
