//
//  ProjectileNode.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 1/31/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit
import SpriteKit

enum ProjectileType {
    case friendly
    case enemy
}

class ProjectileNode: SKSpriteNode {
    var destination : CGPoint = CGPoint.zero
    let distance : CGFloat = 2000
    
    func setup(type: ProjectileType) {
        size = CGSize.init(width: 50, height: 50)
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = type == .friendly ? PhysicsCategory.Projectile : PhysicsCategory.EnemyProjectile
        physicsBody?.contactTestBitMask = type == .friendly ? PhysicsCategory.Monster | PhysicsCategory.Wall : PhysicsCategory.Player
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
