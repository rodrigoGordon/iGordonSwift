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
    var dbManagement: DatabaseManagement!
    
    
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        
        self.loginObj = LoginViewController()
        self.maindDataObj = MainDataViewController()
        self.userPreferencesObj = UserPreferencesViewController()
        self.userOptionsObj = UserOptionsMenuPopover()
        
        //default config for an EndPoint
        self.endPointObj = EndPoint(nameInit: "chapelcredits", cellDescriptionInit: "CL&W CREDITS" , imageInit: "chapel.png", colorRGBInit: [11/255.0 , 54/255.0 , 112/255.0])
        
        self.tableViewCellCustom = TableViewCellUserDataCustom()
        self.dbManagement = DatabaseManagement()
        
        
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
    
    // test firstly validates the operation with dates. Then check if a local DB operation is processed
    // correctly. Such as: saveEdPointSearch() and LoadLastEndPointSearch()
    func testDBForDates() {
        
        //testing code from andrewcbancroft.com/2015/01/13/unit-testing-model-layer-core-data-swift
        
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
        let persistenStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        persistenStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
        
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistenStoreCoordinator
        
        
        var logs: LogResultsFromServer = (NSEntityDescription.insertNewObjectForEntityForName("LogResultsFromServer",
            inManagedObjectContext: managedObjectContext) as? LogResultsFromServer)!
        
        logs.idUser = "iGordon"
        logs.endPointSearched = "chapelcredits"
        logs.dateOfSearch = NSDate(timeIntervalSinceNow: -10000000000)
        logs.valueReceived = "62"
        
        var error: NSError?
        if !managedObjectContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }else{
            println("Log created in the DB")
        }

        let (testPeriod,endPoint) = dbManagement.testMethodForTestTarget("chapelcredits", userName: "iGordon", managedContext: managedObjectContext)
        XCTAssertEqual(testPeriod, 2, "Variable testPeriod is not old enough according to the test")
        
        
        
        
        //Official method used by the app classes
        dbManagement.saveEndPointSearch("chapelcredits", valueReceivedFromServer: "63", userName: "iGordon")
        let (dbPeriod, endPointDbValue) = dbManagement.loadLastEndPointSearch("chapelcredits", userName: "iGordon")
        
        XCTAssertEqual(dbPeriod, 0, "Data is not being saved correctly")
 
    }
    
    
    
    
    // This test mimics the behavior of EndPoint model and LoginViewController with respect
    // to communication with the server, since they operate with the delegate operation of
    // NSURLConnection, the method here can be used as a way to test a Server for different
    // requests, bad credentials, time out, etc.
    func testLoadDataFromServerModel(){
        
        //debug server
        let urlDebug = NSURL(string: "https://igordonserver.herokuapp.com/igordon/api/v1.0/gordoninfo/chapelcredits?username=iGordon&password=swift");
        
        let request = NSMutableURLRequest(URL: urlDebug!);

        let expectation = self.expectationWithDescription("Test with connection at debug server")
        
        var responseData: NSData?
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response: NSURLResponse!, data: NSData!, error: NSError!) in
            responseData = data
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(8) { err in
            XCTAssertNotNil(responseData, "Data is nil and the Server got bad credentials or is not answering")
        }
        
        
        
        //Testing code based on https://github.com/AliSoftware/OHHTTPStubs/wiki/OHHTTPStubs-and-asynchronous-tests
        
    }
    
    
    
    
    
    

    
}
