//
//  User.swift
//  iGordonSwift
//
//  Created by Rodrigo on 6/25/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class GordonUser: NSManagedObject {
    @NSManaged var username: String
    @NSManaged var password: String
    @NSManaged var sessionStatus: String
    @NSManaged var tablePreferences: String
}
