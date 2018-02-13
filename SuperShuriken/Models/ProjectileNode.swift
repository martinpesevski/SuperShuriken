//
//  ProjectileNode.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 1/31/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit
import SpriteKit

class ProjectileNode: SKSpriteNode {
    var destination : CGPoint = CGPoint.zero
    let distance : CGFloat = 2000
    
    func setup() {
        size = CGSize.init(width: 30, height: 30)
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        physicsBody?.contactTestBitMask = PhysicsCategory.Monster | PhysicsCategory.Wall
        physicsBody?.collisionBitMask = PhysicsCategory.None
        physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func shootWithDirection(direction: CGPoint) {
        let shootAmount = direction * distance
        self.destination = shootAmount + position
        
        let actionMove = SKAction.move(to: destination, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        let projectileMovement = SKAction.sequence([actionMove, actionMoveDone])
        let projectileRotation = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.2))
        run(SKAction.group([projectileMovement, projectileRotation]))
    }
}
