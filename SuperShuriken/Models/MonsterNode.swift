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

enum MonsterType:Int {
    case ghost = 0
    case bigGhost

    static var count: Int { return MonsterType.bigGhost.rawValue + 1}
}

class MonsterNode: SKSpriteNode {
    var startPoint = CGPoint()
    var type: MonsterType!
    
    func setup(startPoint: CGPoint, type: MonsterType) {
        self.type = type

        self.startPoint = startPoint
        position = startPoint
        let scaleFactor : CGFloat = type == MonsterType.ghost ? 2 : 3
        scale(to: CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor))
        
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
