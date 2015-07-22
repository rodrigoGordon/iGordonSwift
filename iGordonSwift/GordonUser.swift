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


public class GordonUser: NSManagedObject {
    @NSManaged public var username: String
    @NSManaged public var password: String
    @NSManaged public var sessionStatus: String
    @NSManaged public var tablePreferences: String
}
