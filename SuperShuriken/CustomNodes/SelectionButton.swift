//
//  SelectionButton.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 4/7/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit
import SpriteKit

class SelectionButton: ButtonNode {
    var backgroundHighlightNode : SKSpriteNode!
    var lockNode : SKSpriteNode!
    
    override init(normalTexture defaultTexture: SKTexture!, selectedTexture: SKTexture!, disabledTexture: SKTexture?) {
        super.init(normalTexture: defaultTexture, selectedTexture: selectedTexture, disabledTexture: disabledTexture)
        
        backgroundHighlightNode = SKSpriteNode.init(texture: SKTexture(imageNamed: "ic_highlight"), size: CGSize(width: 100, height: 100))
        backgroundHighlightNode.position = position
        backgroundHighlightNode.zPosition = -1

        lockNode = SKSpriteNode.init(color: .blue, size: CGSize(width: 40, height: 40))
        lockNode.position = CGPoint(x: 25, y: -25)
        lockNode.zPosition = 10
        
        addChild(backgroundHighlightNode)
        addChild(lockNode)
    }
    
    func setHighligted(highlighted: Bool) {
        backgroundHighlightNode.isHidden = !highlighted
    }
    
    func setLocked(locked: Bool) {
        lockNode.isHidden = !locked
    }
    
    func playRadiateAnimation(){
        run(SKAction.repeatForever(SKAction.sequence(
            [SKAction.scale(to: CGSize(width: size.width + 10, height: size.height + 10), duration: 1),
             SKAction.scale(to: CGSize(width: size.width - 10, height: size.height - 10), duration: 1)])))
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
