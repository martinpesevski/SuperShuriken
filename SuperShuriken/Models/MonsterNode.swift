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
    var isInvulnerable = false
    
    private lazy var bloodSplatterNode: SKSpriteNode = {
        let node = SKSpriteNode(color: .clear, size: CGSize(width: 90, height: 60))
        node.anchorPoint = CGPoint(x: 0, y: 0)
        node.zPosition = zPosition
        node.position = CGPoint(x: 0, y: 0)
        return node
    }()
    
    private var runAction = SKAction()
    private lazy var runTextureAction = SKAction.repeatForever(SKAction.animate(with: app.monsterManager.getRunAnimationTextures(monsterType: type), timePerFrame: type.runFrameTime))
    private lazy var hitAction = SKAction.move(by: CGVector(dx: 50, dy: 0), duration: 0.2)
    private lazy var bloodSplatterAction = SKAction.animate(with: app.animationManager.bloodSplatterTextures, timePerFrame: 0.05, resize: false, restore: true)
    
    private lazy var destroyAction = SKAction.removeFromParent()
    private lazy var fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
    private lazy var deathAnimation = SKAction.animate(with: app.monsterManager.getDeathAnimationTextures(monsterType: type), timePerFrame: 0.04)
    private lazy var flyBack = SKAction.moveBy(x: 200, y: 0, duration: 0.3)
    private lazy var deathAction = SKAction.sequence([deathAnimation, fadeOutAction, destroyAction])
    private lazy var flyBackDeath = SKAction.group([flyBack, deathAction])

    func setup(startPoint: CGPoint, type: MonsterType) {
        self.type = type
        size = self.type.size
        
        hitPoints = type.numberOfHits
        
        self.startPoint = startPoint
        position = startPoint
        
        
        addChild(bloodSplatterNode)
        
        physicsBody = SKPhysicsBody(rectangleOf: type.hitBoxSize.size, center: type.hitBoxSize.center)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Monster
        physicsBody?.contactTestBitMask = PhysicsCategory.Projectile | PhysicsCategory.Goal
        physicsBody?.collisionBitMask = PhysicsCategory.None

    }
    
    func playRunAnimation() {
        let destination = CGPoint(x: -100, y: position.y)
        runAction = SKAction.move(to: CGPoint(x: -100, y: startPoint.y), duration: getDuration(pointA: position, pointB: destination, speed: type.speed))
        
        run(runAction, withKey: "moveAction")
        playTextureRunAnimation()
    }
    
    // reduces the hitpoints of the monster and returns boolean indicating if it is dead or not
    func hitAndCheckDead(attackType: AttackType) -> Bool {
        guard type.weaknesses.contains(attackType), !isInvulnerable else { return false }
        
        switch attackType {
        case .Melee:
            hitPoints -= 1
        case .Projectile(let shuriken):
            hitPoints -= shuriken.damage
        }
        
        if hitPoints <= 0 {
            type == .boss ? app.achievementManager.didKillBoss() : app.achievementManager.didKillMonster(type: type)
            playDeathAnimation(attackType: attackType)
            return true
        }
        
        return false
    }
    
    func playDeathAnimation(attackType: AttackType) {
        physicsBody?.contactTestBitMask = PhysicsCategory.None
        physicsBody?.categoryBitMask = PhysicsCategory.None

        removeAllActions()
        run(attackType == .Melee ? deathAction : flyBackDeath)
        playBloodSplatterAnimation()
    }
    
    func playHitAnimation(attackType: AttackType) {
        removeAction(forKey: "moveAction")
        if type.weaknesses.contains(attackType) { playBloodSplatterAnimation() }
        
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
