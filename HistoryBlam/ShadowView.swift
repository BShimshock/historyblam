//
//  ShadowView.swift
//  HistoryBlam
//
//  Created by Brittany Shimshock on 4/27/16.
//  Copyright © 2016 Brittany Shimshock. All rights reserved.
//

import Foundation
import UIKit

class ShadowView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize () {
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.65
        self.layer.shadowRadius = 8.0
    }
    
}
