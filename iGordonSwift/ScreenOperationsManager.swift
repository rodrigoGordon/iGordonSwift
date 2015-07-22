//
//  ScreenOperationsManager.swift
//  iGordonSwift
//   
//  Class used to manipulate and perform some of the view operations in the app.
//  Such as: adjust the labels inside a cell; control DRAG and REORDER operation.
//
//
//  Created by Rodrigo on 7/21/15.
//  Copyright (c) 2015 Gordon College. All rights reserved.
//

import UIKit

class ScreenOperationsManager: NSObject {
    
        var snapshot: UIView? = nil
        var sourceIndexPathOp: NSIndexPath? = nil
    
    func manageTableReorderWithLongPressGesture(tableViewData: UITableView, sourceIndexPath: NSIndexPath, gesture: UILongPressGestureRecognizer, userPreferences: [String]) -> [String]{
        var userTablePreferences: [String] = userPreferences
        sourceIndexPathOp = sourceIndexPath
        let state: UIGestureRecognizerState = gesture.state;
        let location: CGPoint = gesture.locationInView(tableViewData)
        let indexPath: NSIndexPath? = tableViewData.indexPathForRowAtPoint(location)
        if indexPath == nil {
            return userPreferences
        }
        
        switch (state) {
            
        case UIGestureRecognizerState.Began:
            sourceIndexPathOp = indexPath!;
            
            let cell = tableViewData.cellForRowAtIndexPath(indexPath!)!
            snapshot = customSnapshotFromView(cell)
            
            var center = cell.center
            snapshot?.center = center
            snapshot?.alpha = 0.0
            tableViewData.addSubview(snapshot!)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                center.y = location.y
                self.snapshot?.center = center
                self.snapshot?.transform = CGAffineTransformMakeScale(1.05, 1.05)
                self.snapshot?.alpha = 0.98
                cell.alpha = 0.0
            })
            
        case UIGestureRecognizerState.Changed:
            var center: CGPoint = snapshot!.center
            center.y = location.y
            snapshot?.center = center
            
            // Is destination valid and is it different from source?
            if indexPath != sourceIndexPath {
                // ... update data source.
                //userTablePreferences.exchangeObjectAtIndex(indexPath!.row, withObjectAtIndex: sourceIndexPath!.row)
                
                let objectToBeMoved = userTablePreferences[sourceIndexPathOp!.row] ;
                userTablePreferences.removeAtIndex(sourceIndexPathOp!.row);
                userTablePreferences.insert(objectToBeMoved, atIndex: indexPath!.row);
                let dbManagement: DatabaseManagement = DatabaseManagement()
                dbManagement.updateUserTablePreferences(userTablePreferences)
                
                // ... move the rows.
                tableViewData.moveRowAtIndexPath(sourceIndexPathOp!, toIndexPath: indexPath!)
                // ... and update source so it is in sync with UI changes.
                sourceIndexPathOp = indexPath;
            }
            
        default:
            // Clean up.
            let cell = tableViewData.cellForRowAtIndexPath(indexPath!)!
            cell.alpha = 0.0
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.snapshot?.center = cell.center
                self.snapshot?.transform = CGAffineTransformIdentity
                self.snapshot?.alpha = 0.0
                // Undo fade out.
                cell.alpha = 1.0
                
                }, completion: { (finished) in
                    
                    self.sourceIndexPathOp = nil
                    self.snapshot?.removeFromSuperview()
                    self.snapshot = nil;
            })
            break
        }
        return userTablePreferences
    }
    
    // MARK: Helper
    
    func customSnapshotFromView(inputView: UIView) -> UIView {
        
        // Make an image from the input view.
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        // Create an image view.
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        
        return snapshot
    }
    
    
    
    
    
    
   
}
