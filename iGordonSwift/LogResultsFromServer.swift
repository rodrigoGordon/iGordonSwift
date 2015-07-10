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

class LogResultsFromServer: NSManagedObject {
    @NSManaged var idUser: String
    @NSManaged var endPointSearched: String
    @NSManaged var dateOfSearch: NSDate
    @NSManaged var valueReceived: String
}
