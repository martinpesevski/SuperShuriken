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

enum projectileStyle {
    case straight
    case rotating
}

class ProjectileNode: SKSpriteNode {
    var destination : CGPoint = CGPoint.zero
    let distance : CGFloat = 2000
    var type: ProjectileType!
    var style: projectileStyle!
    var shuriken: Shuriken!
    var projectileSpeed: Int { return 2000 }
    
    func setup(type: ProjectileType, shuriken: Shuriken) {
        self.texture = SKTexture(image: shuriken.image)
        self.type = type
        switch shuriken {
        case .straight:
            style = .straight
        default:
            style = .rotating
        }
        self.shuriken = shuriken

        size = CGSize.init(width: style == .straight ? 110 : 75, height: style == .straight ? 45 : 75)
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
        
        let projectileMovement = getProjectileMovement()
        let projectileRotation = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.2))
        if style == .rotating {
            run(SKAction.group([projectileMovement, projectileRotation]))
        } else {
            run (projectileMovement)
        }
    }
    
    func getProjectileMovement () -> SKAction {
        let actionMove = SKAction.move(to: destination, duration: getDuration(pointA: self.position, pointB: destination, speed: CGFloat(projectileSpeed)))
        let actionMoveDone = SKAction.removeFromParent()
        return SKAction.sequence([actionMove, actionMoveDone])
    }
}
