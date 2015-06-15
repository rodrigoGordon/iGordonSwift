//
//  TableViewCellUserDataCustom.swift
//  iGordonSwift
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import Foundation
import UIKit

class TableViewCellUserDataCustom: UITableViewCell {
    
    @IBOutlet weak var imgIconForEndPoint: UIImageView!
    @IBOutlet weak var lblDescriptionOfEndPoint: UILabel!
    
    @IBOutlet weak var lblResultFromServer: UILabel!

    @IBOutlet weak var activityIndicatorWorkServer: UIActivityIndicatorView!
}
