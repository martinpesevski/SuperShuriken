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

enum MobAnimationType: CaseIterable {
    case Run
    case Shoot
    case RunShoot
    case Death
    case RunSlash
    
    var name: String {
        switch self {
        case .Run:
            return "mobRunAnimation"
        case .Shoot:
            return "mobShootAnimation"
        case .RunShoot:
            return "mobRunShootAnimation"
        case .Death:
            return "mobDeathAnimation"
        case .RunSlash:
            return "mobRunSlashAnimation"
        }
    }
}

enum MonsterType: UInt32 {
    case basicMob
    case bigMob
    case meleeMob
    case boss
    
    var scorePoints: Int {
        switch self {
        case .basicMob:
            return 1
        case .bigMob:
            return 2
        case .meleeMob:
            return 3
        case .boss:
            return 10
        }
    }
    
    var size: CGSize {
        switch self {
        case .basicMob:
            return CGSize(width: 267, height: 267)
        case .bigMob:
            return CGSize(width: 400, height: 320)
        case .meleeMob:
            return CGSize(width: 267, height: 267)
        case .boss:
            return CGSize(width: 667, height: 667)
        }
    }

    static func random() -> MonsterType {
        let rand = arc4random_uniform(self.count)
        return MonsterType(rawValue: rand) ?? .basicMob
    }
    
    static var count: UInt32 { return 3 }
}

class MonsterNode: SKSpriteNode {
    var startPoint = CGPoint()
    var type: MonsterType!
    private var hitPoints: Int = 1
    var monsterDelegate: MonsterDelegate?
    var attackTypeWeaknesses: [AttackType]!
    private var bloodSplatterNode: SKSpriteNode!
    private var bloodSplatterTextures = [SKTexture]()


    func setup(startPoint: CGPoint, type: MonsterType) {
        self.type = type
        size = self.type.size
        
        hitPoints = MonsterManager.getNumberOfHits(monsterType: type)
        attackTypeWeaknesses = MonsterManager.getWeaknesses(monsterType: type)
        
        self.startPoint = startPoint
        position = startPoint
        
        bloodSplatterNode = SKSpriteNode(color: .clear, size: CGSize(width: 90, height: 60))
        bloodSplatterNode.anchorPoint = CGPoint(x: 0, y: 0)
        bloodSplatterNode.zPosition = 1
        bloodSplatterNode.position = CGPoint(x: 0, y: 0)
        addChild(bloodSplatterNode)
        
        bloodSplatterTextures = createAtlas(name: "bloodSplatter")

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Monster
        physicsBody?.contactTestBitMask = PhysicsCategory.Projectile | PhysicsCategory.Goal
        physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    func playRunAnimation() {
        let destination = CGPoint(x: -100, y: position.y)
        let actionMove = SKAction.move(to: CGPoint(x: -100, y: startPoint.y), duration: getDuration(pointA: position, pointB: destination, speed: MonsterManager.getSpeed(monsterType: type) * GameManager.sharedInstance.speedUpFactor()))
        
        run(actionMove, withKey: "moveAction")
        playTextureRunAnimation ()
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
        physicsBody?.contactTestBitMask = PhysicsCategory.None
        physicsBody?.categoryBitMask = PhysicsCategory.None
        let destroyAction = SKAction.removeFromParent()
        let deathAnimation = SKAction.animate(with: MonsterManager.getDeathAnimationTextures(monsterType: type), timePerFrame: 0.04)
        
        removeAllActions()
        run(SKAction.sequence([deathAnimation, destroyAction]))
        playBloodSplatterAnimation()
    }
    
    func playHitAnimation(){
        removeAction(forKey: "moveAction")
        let knockbackAction = SKAction.move(by: CGVector(dx: 50, dy: 0), duration: 0.2)
        
        playBloodSplatterAnimation()
        
        run(knockbackAction) { [unowned self] in
            self.playRunAnimation()
        }
    }
    
    func playBloodSplatterAnimation(){
        let bloodSplatterAction = SKAction.animate(with: bloodSplatterTextures, timePerFrame: 0.05, resize: false, restore: true)
        removeAction(forKey: "bloodSplatterAction")
        bloodSplatterNode.run(bloodSplatterAction, withKey: "bloodSplatterAction")
    }
    
    func playTextureRunAnimation(){
        let meleeOgreRunAction = SKAction.repeatForever(SKAction.animate(with: MonsterManager.getRunAnimationTextures(monsterType: type), timePerFrame: 0.04))
        run(meleeOgreRunAction, withKey: MobAnimationType.Run.name)
    }
}
