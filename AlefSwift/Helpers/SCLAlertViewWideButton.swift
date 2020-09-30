//
//  SCAlertViewShort.swift
//  AlefSwift
//
//  Created by Dennis Fogel on 09/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import Foundation
import SCLAlertView

class SCLAlertViewWideButton: SCLAlertView {
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
 
        let allSubviews = self.view.allSubviews
        for subview in allSubviews {
            if let button = subview as? SCLButton {
                var frameButton = button.frame
                frameButton.origin.x += 30
                frameButton.size.width -= 60                
                frameButton.size.height += 10
                button.frame = frameButton
            }
        }
    }
}

extension UIView {
    var allSubviews: [UIView] {
        return self.subviews.flatMap { [$0] + $0.allSubviews }
    }
}
