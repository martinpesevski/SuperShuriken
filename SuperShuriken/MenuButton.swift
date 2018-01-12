//
//  MenuButton.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 12/17/17.
//  Copyright © 2017 MP. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MenuButton: SKSpriteNode {
    var label : CustomLabel!
    
    init(color: UIColor, size: CGSize, text: String) {
        let texture = SKTexture.init(image: UIImage())
        super.init(texture: texture, color: color, size: size)
        
        label = CustomLabel.init(fontName: "Chalkduster", text: text)
        label.fontColor = SKColor.white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
