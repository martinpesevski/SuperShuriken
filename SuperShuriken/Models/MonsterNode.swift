//
//  MonsterNode.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 2/25/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MonsterNode: SKSpriteNode {
    var startPoint = CGPoint()

    func setup(startPoint: CGPoint) {
        self.startPoint = startPoint
        position = startPoint
        
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Monster
        physicsBody?.contactTestBitMask = PhysicsCategory.Projectile | PhysicsCategory.Goal
        physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    func playRunAnimation() {
        let actualDuration = random(min: CGFloat(5.0), max: CGFloat(7.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: -100, y: startPoint.y), duration: TimeInterval(actualDuration))
        
        run(actionMove, withKey: "moveAction")
    }
    
    func playDeathAnimation() {
        removeAction(forKey: "moveAction")
        physicsBody?.contactTestBitMask = PhysicsCategory.None
        physicsBody?.categoryBitMask = PhysicsCategory.None
        let rotateAction = SKAction.rotate(byAngle: -CGFloat(Double.pi/2), duration: 0.3)
        let fadeAction = SKAction.fadeOut(withDuration: 0.3)
        let rotateFade = SKAction.group([rotateAction, fadeAction])
        let destroyAction = SKAction.removeFromParent()
        run(SKAction.sequence([rotateFade, destroyAction]))
    }
    
}
