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

protocol MonsterDelegate {
    func monsterDidShoot(projectile: ProjectileNode)
}

enum MonsterType:Int {
    case ghost = 1
    case bigGhost = 2
    case boss = 10
    case air = 3

    static var count: Int { return 3 }
}

class MonsterNode: SKSpriteNode {
    var startPoint = CGPoint()
    var type: MonsterType!
    var actualDuration: CGFloat!
    var hitPoints: Int = 1
    var monsterDelegate: MonsterDelegate?
    
    func setup(startPoint: CGPoint, type: MonsterType) {
        self.type = type

        hitPoints = getNumberOfHits(monsterType: type)
        
        self.startPoint = startPoint
        position = startPoint
        let scaleFactor = getScaleFactor(monsterType: type)
        scale(to: CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor))
        
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Monster
        physicsBody?.contactTestBitMask = PhysicsCategory.Projectile | PhysicsCategory.Goal
        physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    func playRunAnimation() {
        let actionMove = SKAction.move(to: CGPoint(x: -100, y: startPoint.y), duration: TimeInterval(actualDuration))
        
        run(actionMove, withKey: "moveAction")
    }
    
    // reduces the hitpoints of the monster and returns boolean indicating if it is dead or not
    func hitAndCheckDead() -> Bool{
        hitPoints -= 1
        
        return hitPoints == 0
    }
    
    func playDeathAnimation() {
        removeAction(forKey: "moveAction")
        removeAction(forKey: "bossAction")
        physicsBody?.contactTestBitMask = PhysicsCategory.None
        physicsBody?.categoryBitMask = PhysicsCategory.None
        let rotateAction = SKAction.rotate(byAngle: -CGFloat(Double.pi/2), duration: 0.3)
        let fadeAction = SKAction.fadeOut(withDuration: 0.3)
        let rotateFade = SKAction.group([rotateAction, fadeAction])
        let destroyAction = SKAction.removeFromParent()
        run(SKAction.sequence([rotateFade, destroyAction]))
    }
    
    func playHitAnimation(){
        let flashWhite = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
        let removeFlash = SKAction.fadeAlpha(to: 1, duration: 0.1)

        run(SKAction.sequence([flashWhite, removeFlash]))
    }
    
    func getScaleFactor(monsterType: MonsterType) -> CGFloat {
        let scaleFactor : CGFloat
        switch monsterType {
        case .ghost:
            scaleFactor = 2
        case .bigGhost:
            scaleFactor = 3
        case .air:
            scaleFactor = 2
        case .boss:
            scaleFactor = 5
        }
        
        return scaleFactor
    }
    
    func getNumberOfHits(monsterType: MonsterType) -> Int {
        let numberOfHits : Int
        switch monsterType {
        case .ghost:
            numberOfHits = 1
        case .bigGhost:
            numberOfHits = 2
        case .air:
            numberOfHits = 1
        case .boss:
            numberOfHits = 5
        }
        
        return numberOfHits
    }
}
