//
//  CustomLabel.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 12/17/17.
//  Copyright © 2017 MP. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class CustomLabel: SKLabelNode {
    init(fontName: String?, text: String) {
        super.init()
        
        self.fontName = fontName
        self.text = text
        self.fontColor = SKColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
