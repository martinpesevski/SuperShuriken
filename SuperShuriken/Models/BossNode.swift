//
//  BossNode.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 10/14/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit
import SpriteKit

enum BossAttackType : Int {
    case straightShot = 1
    case curveShot
    case splitShot

    static var count: Int { return 3 }
}

enum BossType : Int {
    case vampire = 1
    
    static var count: Int { return 1}
}

class BossNode: MonsterNode {
    
    private let bossMoveDistance:CGFloat = 150
    var attackType = BossAttackType.splitShot
    var bossType = BossType.vampire

    func setupRandom(){
        attackType = BossAttackType(rawValue:Int(arc4random_uniform(UInt32(BossAttackType.count)))) ??
            .straightShot
        bossType = BossType(rawValue:Int(arc4random_uniform(UInt32(BossType.count)))) ??
            .vampire
    }
    
    func playBossAnimation() {
        let actionWalkOnScreen = SKAction.group([getWalkAnimationForType(bossType: bossType),
                                                 SKAction.move(to: CGPoint(x: startPoint.x - bossMoveDistance, y: startPoint.y), duration: TimeInterval(1))])
        guard let scene = scene else {
            return
        }
        
        let walkAndShootAction = getWalkAndShootAction(scene: scene)

        let bossMoveAnimation = SKAction.sequence([actionWalkOnScreen, walkAndShootAction])
        run(bossMoveAnimation, withKey: "bossAction")
        runSpecialAttackTimer(scene: scene)
    }
    
    override func playHitAnimation() {
        playBloodSplatterAnimation()
    }
    
    override func playDeathAnimation() {
        removeAction(forKey: "bossAction")
        physicsBody?.contactTestBitMask = PhysicsCategory.None
        physicsBody?.categoryBitMask = PhysicsCategory.None
        let destroyAction = SKAction.removeFromParent()
        let deathAnimation = getDeathAnimationForType(bossType: bossType)
        run(SKAction.sequence([deathAnimation, destroyAction]))
        playBloodSplatterAnimation()
    }
    
    func getWalkAnimationForType(bossType: BossType) -> SKAction {
        let walkOnScreenFrames = app.monsterManager.getBossWalkAnimationTextures(monsterType: bossType)
        let actionAnimateWalk = SKAction.animate(with: walkOnScreenFrames, timePerFrame: 0.03)
        return actionAnimateWalk
    }
    
    func getRunAnimationForType(bossType: BossType) -> SKAction {
        let bossRunningFrames = app.monsterManager.getBossRunAnimationTextures(monsterType: bossType)
        let actionAnimateRun = SKAction.repeatForever(SKAction.animate(with: bossRunningFrames, timePerFrame: 0.05))
        return actionAnimateRun
    }
    
    func getRunShootAnimationForType(bossType: BossType) -> SKAction {
        let bossRunningFrames = app.monsterManager.getBossRunShootAnimationTextures(monsterType: bossType)
        let actionAnimateRun = SKAction.animate(with: bossRunningFrames, timePerFrame: 0.02)
        return actionAnimateRun
    }
    
    func getDeathAnimationForType(bossType: BossType) -> SKAction {
        let bossDeathFrames = app.monsterManager.getBossDeathAnimationTextures(bossType: bossType)
        let actionAnimateDeath = SKAction.animate(with: bossDeathFrames, timePerFrame: 0.04)
        return actionAnimateDeath
    }
    
    func getWalkAndShootAction(scene: SKScene) -> SKAction{
        let actionWalkUpDown = getBossWalkUpDownAction(scene: scene)
        let bossShootingAction = getBossRepeatedShootAction(scene: scene)
        return SKAction.group([actionWalkUpDown, bossShootingAction, getRunAnimationForType(bossType: bossType)])
    }
    
    func runSpecialAttackTimer(scene: SKScene){
        run(action: SKAction.wait(forDuration: TimeInterval(random(min: 3, max: 5))), withKey: "waitForSpecial") { [unowned self] in
            self.shootSpecialAttack(scene: scene)
        }
    }
    
    func shootSpecialAttack(scene: SKScene) {
        self.removeAction(forKey: "bossAction")
        let flashWhite = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
        let removeFlash = SKAction.fadeAlpha(to: 1, duration: 0.1)
        let flashAction = SKAction.repeat(SKAction.sequence([flashWhite, removeFlash]), count: 3)
        var shotsArray = [SKAction]()
        for _ in 0...15 {
            let offset = random(min: -50.0, max: 50.0)
            let shootAction = getShootAction(scene: scene, attackType: .straightShot, offset: offset)
            shotsArray.append(shootAction)
            shotsArray.append(SKAction.wait(forDuration: 0.02))
        }
        run(SKAction.sequence([flashAction, SKAction.sequence(shotsArray)])) { [unowned self] in
            self.run(self.getWalkAndShootAction(scene: scene), withKey: "bossAction")
            self.runSpecialAttackTimer(scene: scene)
        }
    }
    
    func getBossWalkUpDownAction(scene: SKScene) -> SKAction {
        let actionWalkTop = SKAction.move(to: CGPoint(x: startPoint.x - bossMoveDistance, y: horizonVerticalLocation), duration: 1)
        let actionWalkBottom = SKAction.move(to: CGPoint(x: startPoint.x - bossMoveDistance, y: 170), duration: 1)
        return SKAction.repeatForever(SKAction.sequence([actionWalkTop, actionWalkBottom]))
    }
    
    func getShootAction(scene:SKScene, attackType:BossAttackType, offset: CGFloat) -> SKAction {
        let shootAction = SKAction.run { [unowned self] in
            if self.attackType == .splitShot {
                self.createAndShootSplitShot()
            } else {
                self.createAndShootSingleShot(attackType: attackType, offset: offset, angle: 0)
            }
        }
        
        return shootAction
    }
    
    func createAndShootSingleShot(attackType: BossAttackType, offset: CGFloat, angle: Int) {
        let projectile = BossProjectileNode()
        projectile.setupWithBossAttackType(attackType: attackType, angle: angle)
        projectile.position = CGPoint(x: self.position.x, y: self.position.y + offset)
        projectile.setup(type: .enemy, shuriken: .red)
        
        let offset = CGPoint(x: -100, y: 0)
        
        guard let scene = self.scene else {
            return
        }
        scene.addChild(projectile)
        self.monsterDelegate?.monsterDidShoot(projectile: projectile)
        let direction = offset.normalized()
        projectile.shootWithDirection(direction: direction)
    }
    
    func createAndShootSplitShot(){
        createAndShootSingleShot(attackType: .straightShot, offset: 0, angle: 200)
        createAndShootSingleShot(attackType: .straightShot, offset: 0, angle: 0)
        createAndShootSingleShot(attackType: .straightShot, offset: 0, angle: -200)
    }
    
    func getBossRepeatedShootAction(scene:SKScene) -> SKAction{
        let shootAction = getShootAction(scene: scene, attackType: attackType,offset: 0)
        let shotFrequency = random(min: 0.2, max: 0.7)
        
        let normalShootAction = SKAction.sequence([shootAction, SKAction.wait(forDuration: TimeInterval(shotFrequency))])
        return SKAction.repeatForever(normalShootAction)
    }
}
