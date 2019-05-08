//
//  CountdownNode.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/5/19.
//  Copyright © 2019 MP. All rights reserved.
//

import SpriteKit

class CountdownNode: SKSpriteNode {
    var counterNode: SKLabelNode = {
        let counter = SKLabelNode()
        counter.fontSize = 300
        counter.fontName = "Chalkduster"
        counter.fontColor = .white

        return counter
    }()
    
    init() {
        super.init(texture: nil, color: .clear, size: CGSize(width: 200, height: 200))
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(counterNode)
        counterNode.position = CGPoint(x: 0, y: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startCounting(completion: @escaping ()->()) {
        run(pulse(node: counterNode), completion: completion)
    }
    
    func pulse(node: SKLabelNode) -> SKAction {
        node.alpha = 1
        node.text = "3"
        let size = node.frame.size
        let downsizeAction = SKAction.resize(byWidth: -size.width/2, height: -size.height/2, duration: 1)
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.1)
        let upsizeAction = SKAction.resize(toWidth: size.width, height: size.height, duration: 0)
        let fadeInaction = SKAction.fadeIn(withDuration: 0)
        
        var countdownActionArray: [SKAction] = []
        for number in (1...3).reversed() {
            let changeNumberAction = SKAction.run { node.text = "\(number)" }
            let countdownAction = SKAction.sequence([upsizeAction, changeNumberAction, fadeInaction, downsizeAction, fadeOutAction])
            
            countdownActionArray.append(countdownAction)
        }
        
        return SKAction.sequence(countdownActionArray)
    }
}
