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

enum MobAnimationType: String, CaseIterable {
    case Run = "mobRunAnimation"
    case Shoot = "mobShootAnimation"
    case RunShoot = "mobRunShootAnimation"
    case Death = "mobDeathAnimation"
    case RunSlash = "mobRunSlashAnimation"
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
    private var hitPoints: Int = 1
    var monsterDelegate: MonsterDelegate?
    var attackTypeWeaknesses: [AttackType]!
    private var bloodSplatterNode: SKSpriteNode!
    private var bloodSplatterTextures = [SKTexture]()


    func setup(startPoint: CGPoint, type: MonsterType) {
        self.type = type
        size = CGSize(width: 100, height: 80)
        
        hitPoints = getNumberOfHits(monsterType: type)
        attackTypeWeaknesses = getWeaknesses(monsterType: type)
        
        self.startPoint = startPoint
        position = startPoint
        let scaleFactor = getScaleFactor(monsterType: type)
        scale(to: CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor))
        
        bloodSplatterNode = SKSpriteNode(color: .clear, size: CGSize(width: 30, height: 20))
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
        let actionMove = SKAction.move(to: CGPoint(x: -100, y: startPoint.y), duration: getDuration(pointA: position, pointB: destination, speed: getSpeed(monsterType: type) * GameManager.sharedInstance.speedUpFactor()))
        
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
        removeAction(forKey: "bossAction")
        physicsBody?.contactTestBitMask = PhysicsCategory.None
        physicsBody?.categoryBitMask = PhysicsCategory.None
        let rotateAction = SKAction.rotate(byAngle: -CGFloat(Double.pi/2), duration: 0.3)
        let fadeAction = SKAction.fadeOut(withDuration: 0.3)
        let rotateFade = SKAction.group([rotateAction, fadeAction])
        let destroyAction = SKAction.removeFromParent()
        run(SKAction.sequence([rotateFade, destroyAction]))
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
        let meleeogreRunAction = SKAction.repeatForever(SKAction.animate(with: getAnimationTextures(monsterType: type), timePerFrame: 0.03))
        run(meleeogreRunAction, withKey: MobAnimationType.Run.rawValue)
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
    
    func getSpeed(monsterType: MonsterType) -> CGFloat {
        switch monsterType {
        case .basicMob:
            return basicMobSpeed
        case .bigMob:
            return bigMobSpeed
        case .meleeMob:
            return meleeMobSpeed
        case .boss:
            return 0
        }
    }
    
    func getAnimationTextures(monsterType: MonsterType) -> [SKTexture] {
        switch monsterType {
        case .basicMob:
            return createAtlas(name: "Melee_Ogre_Running")
        case .bigMob:
            return createAtlas(name: "Melee_Ogre_Running")
        case .meleeMob:
            return createAtlas(name: "minion_shielded_armored_running")
        case .boss:
            return createAtlas(name: "Melee_Ogre_Running")
        }
    }
}
