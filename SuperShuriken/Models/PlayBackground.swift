//
//  PlayBackground.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 3/30/19.
//  Copyright © 2019 MP. All rights reserved.
//

import SpriteKit

class PlayBackground: SKSpriteNode {

    init(scene: SKScene) {
        super.init(texture: nil, color: .red, size: scene.size)
        
        scene.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
