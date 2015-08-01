//
//  TableViewCellUserDataCustom.swift
//  iGordonSwift
//
//  Class used to define the properties of a Custom Cell TableView for the App. It
//  connects the outlets and provides initialization.
//
//
//  Created by Rodrigo Amaral on 6/10/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import Foundation
import UIKit

public class TableViewCellUserDataCustom: UITableViewCell {
    
    
    @IBOutlet weak var imgIconForEndPoint: SpringImageView!
    
    @IBOutlet weak var lblDescriptionOfEndPoint: UILabel!
    
    @IBOutlet weak var lblResultFromServer: SpringLabel!

    @IBOutlet weak var lblLogPeriod: SpringLabel!
    
    
    
    
    var selectedEasing: Int = 0
    
    var selectedForce: CGFloat = 1
    var selectedDuration: CGFloat = 1
    var selectedDelay: CGFloat = 0
    
    var selectedDamping: CGFloat = 0.7
    var selectedVelocity: CGFloat = 0.7
    var selectedScale: CGFloat = 1
    var selectedX: CGFloat = 0
    var selectedY: CGFloat = 0
    var selectedRotate: CGFloat = 0
    var repeatCount: Float = 100

    
    
    // init for the animation variables
    // Should be called before the method startAnimation() for the object
    
    public func setOptionsForAnimationInIcon() {
        
        
        imgIconForEndPoint.force = selectedForce
        imgIconForEndPoint.duration = 0.9
        imgIconForEndPoint.delay = selectedDelay
        
        imgIconForEndPoint.damping = selectedDamping
        imgIconForEndPoint.velocity = 4
        imgIconForEndPoint.scaleX = selectedScale
        imgIconForEndPoint.scaleY = selectedScale
        imgIconForEndPoint.x = selectedX
        imgIconForEndPoint.y = selectedY
        imgIconForEndPoint.rotate = selectedRotate
        imgIconForEndPoint.repeatCount = repeatCount
        imgIconForEndPoint.animation = "morph"
        imgIconForEndPoint.curve = "spring"
        
        
        
    }
    
    // init for the animation variables
    // Should be called before the method startAnimation() for the object
    public func setOptionsForAnimationInResultLabel() {
        
        
        lblResultFromServer.force = selectedForce
        lblResultFromServer.duration = selectedDuration
        lblResultFromServer.delay = selectedDelay
        
        lblResultFromServer.damping = selectedDamping
        lblResultFromServer.velocity = selectedVelocity
        lblResultFromServer.scaleX = selectedScale
        lblResultFromServer.scaleY = selectedScale
        lblResultFromServer.x = selectedX
        lblResultFromServer.y = selectedY
        lblResultFromServer.rotate = selectedRotate
        
        lblResultFromServer.animation = "fadeInRight"
        lblResultFromServer.curve = "spring"
        
        
    }
    

    
}
