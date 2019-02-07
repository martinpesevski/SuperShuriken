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
    case basicMob = 1
    case bigMob = 2
    case meleeMob = 3
    case boss = 10

    static var count: Int { return 3 }
}

class MonsterNode: SKSpriteNode {
    var startPoint = CGPoint()
    var type: MonsterType!
    var actualDuration: CGFloat!
    var hitPoints: Int = 1
    var monsterDelegate: MonsterDelegate?
    var attackTypeWeaknesses: [AttackType]!
    
    func setup(startPoint: CGPoint, type: MonsterType) {
        self.type = type

        hitPoints = getNumberOfHits(monsterType: type)
        attackTypeWeaknesses = getWeaknesses(monsterType: type)
        
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
    func hitAndCheckDead(attackType: AttackType) -> Bool{
        if !attackTypeWeaknesses.contains(attackType) {
            return false
        }
        
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
        removeAction(forKey: "moveAction")
        let knockbackAction = SKAction.move(by: CGVector(dx: 50, dy: 0), duration: 0.2)
        let flashWhite = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
        let removeFlash = SKAction.fadeAlpha(to: 1, duration: 0.1)

        run(SKAction.group([knockbackAction, SKAction.sequence([flashWhite, removeFlash]) ]), completion:{
            self.playRunAnimation()
        })
    }
    
    func getScaleFactor(monsterType: MonsterType) -> CGFloat {
        let scaleFactor : CGFloat
        switch monsterType {
        case .basicMob:
            scaleFactor = 2
        case .bigMob:
            scaleFactor = 3
        case.meleeMob:
            scaleFactor = 2
        case .boss:
            scaleFactor = 5
        }
        
        return scaleFactor
    }
    
    func getNumberOfHits(monsterType: MonsterType) -> Int {
        let numberOfHits : Int
        switch monsterType {
        case .basicMob:
            numberOfHits = 1
        case .bigMob:
            numberOfHits = 2
        case .meleeMob:
            numberOfHits = 1
        case .boss:
            numberOfHits = 5
        }
        
        return numberOfHits
    }
    
    func getWeaknesses(monsterType: MonsterType) -> [AttackType] {
        var weaknessesArray : [AttackType] = [];
        switch monsterType {
        case .basicMob:
            weaknessesArray = [.Melee, .Projectile]
        case .bigMob:
            weaknessesArray = [.Projectile]
        case .meleeMob:
            weaknessesArray = [.Melee]
        case .boss:
            weaknessesArray = [.Projectile]
        }
        
        return weaknessesArray
    }
}
