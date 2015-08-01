//
//  LogResultsFromServer.swift
//  iGordonSwift
//
//  The class represents the Entity LogResultsFromServer in Swift CoreData, its Entity Relationship
//  with GordonUser has as foreign key the fkGordonUser( not implemented, DB management class uses a predicate
//    to find the user - IN PROCESS TO BE FIXED) .
//
//
//  Created by Rodrigo on 7/6/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import UIKit
import Foundation
import CoreData


 public class LogResultsFromServer: NSManagedObject {
    @NSManaged public var idUser: String
    @NSManaged public var endPointSearched: String
    @NSManaged public var dateOfSearch: NSDate
    @NSManaged public var valueReceived: String
    //define the fk for this class
    @NSManaged public var fkGordonUser: String
}
