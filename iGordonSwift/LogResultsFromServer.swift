//
//  LogResultsFromServer.swift
//  iGordonSwift
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
