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

class MonsterNode: SKSpriteNode {
    var startPoint = CGPoint()
    var type: MonsterType!
    private var hitPoints: Int = 1
    var monsterDelegate: MonsterDelegate?
    internal let monsterManager = MonsterManager.sharedInstance
    internal let animationManager = AnimationManager.sharedInstance
    private var bloodSplatterNode: SKSpriteNode!
    private var runAction = SKAction()
    private var runTextureAction = SKAction()
    private var hitAction = SKAction()
    private var bloodSplatterAction = SKAction()
    private var deathAction = SKAction()

    func setup(startPoint: CGPoint, type: MonsterType) {
        self.type = type
        size = self.type.size
        
        hitPoints = type.numberOfHits
        
        self.startPoint = startPoint
        position = startPoint
        
        bloodSplatterNode = SKSpriteNode(color: .clear, size: CGSize(width: 90, height: 60))
        bloodSplatterNode.anchorPoint = CGPoint(x: 0, y: 0)
        bloodSplatterNode.zPosition = 1
        bloodSplatterNode.position = CGPoint(x: 0, y: 0)
        addChild(bloodSplatterNode)
        
        physicsBody = SKPhysicsBody(rectangleOf: type.hitBoxSize.size, center: type.hitBoxSize.center)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Monster
        physicsBody?.contactTestBitMask = PhysicsCategory.Projectile | PhysicsCategory.Goal
        physicsBody?.collisionBitMask = PhysicsCategory.None

        setupActions()
    }
    
    func setupActions() {
        let destroyAction = SKAction.removeFromParent()
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
        let deathAnimation = SKAction.animate(with: monsterManager.getDeathAnimationTextures(monsterType: type), timePerFrame: 0.04)
        
        deathAction = SKAction.sequence([deathAnimation, fadeOutAction, destroyAction])
        
        bloodSplatterAction = SKAction.animate(with: animationManager.bloodSplatterTextures, timePerFrame: 0.05, resize: false, restore: true)
        
        hitAction = SKAction.move(by: CGVector(dx: 50, dy: 0), duration: 0.2)
        
        runTextureAction = SKAction.repeatForever(SKAction.animate(with: monsterManager.getRunAnimationTextures(monsterType: type), timePerFrame: 0.04))
    }
    
    func playRunAnimation() {
        let destination = CGPoint(x: -100, y: position.y)
        runAction = SKAction.move(to: CGPoint(x: -100, y: startPoint.y), duration: getDuration(pointA: position, pointB: destination, speed: type.speed * GameManager.sharedInstance.speedUpFactor()))
        
        run(runAction, withKey: "moveAction")
        playTextureRunAnimation ()
    }
    
    // reduces the hitpoints of the monster and returns boolean indicating if it is dead or not
    func hitAndCheckDead(attackType: AttackType) -> Bool{
        if !type.weaknesses.contains(attackType) {
            return false
        }
        
        hitPoints -= 1
        
        return hitPoints == 0
    }
    
    func playDeathAnimation() {
        removeAction(forKey: "moveAction")
        physicsBody?.contactTestBitMask = PhysicsCategory.None
        physicsBody?.categoryBitMask = PhysicsCategory.None

        removeAllActions()
        run(deathAction)
        playBloodSplatterAnimation()
    }
    
    func playHitAnimation(){
        removeAction(forKey: "moveAction")
        playBloodSplatterAnimation()
        
        run(hitAction) { [unowned self] in
            self.playRunAnimation()
        }
    }
    
    func playBloodSplatterAnimation(){
        removeAction(forKey: "bloodSplatterAction")
        bloodSplatterNode.run(bloodSplatterAction, withKey: "bloodSplatterAction")
    }
    
    func playTextureRunAnimation(){
        run(runTextureAction, withKey: MobAnimationType.Run.name)
    }
}
