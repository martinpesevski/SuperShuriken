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
    case curveShot = 2
    
    static var count: Int { return 2 }
}

class BossNode: MonsterNode {
    
    private let bossMoveDistance:CGFloat = 150
    var attackType = BossAttackType.straightShot
    
    func setupRandom(){
        attackType = BossAttackType(rawValue:Int(arc4random_uniform(UInt32(BossAttackType.count)))) ??
            .straightShot
    }
    
    func playBossAnimation() {
        let actionWalkOnScreen = SKAction.move(to: CGPoint(x: startPoint.x - bossMoveDistance, y: startPoint.y), duration: TimeInterval(1))
        guard let scene = scene else {
            return
        }
        
        let walkAndShootAction = getWalkAndShootAction(scene: scene)
        let bossMoveAnimation = SKAction.sequence([actionWalkOnScreen, walkAndShootAction])
        run(bossMoveAnimation, withKey: "bossAction")
        runSpecialAttackTimer(scene: scene)
    }
    
    override func playHitAnimation() {
        let flashWhite = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
        let removeFlash = SKAction.fadeAlpha(to: 1, duration: 0.1)
        
        run(SKAction.sequence([flashWhite, removeFlash]))
    }
    
    func getWalkAndShootAction(scene: SKScene) -> SKAction{
        let actionWalkUpDown = getBossWalkUpDownAction(scene: scene)
        let bossShootingAction = getBossRepeatedShootAction(scene: scene)
        return SKAction.group([actionWalkUpDown, bossShootingAction])
    }
    
    func runSpecialAttackTimer(scene: SKScene){
        run(action: SKAction.wait(forDuration: 5), withKey: "waitForSpecial") { [unowned self] in
            self.shootSpecialAttackAction(scene: scene)
        }
    }
    
    func shootSpecialAttackAction(scene: SKScene) {
        self.removeAction(forKey: "bossAction")
        let flashWhite = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
        let removeFlash = SKAction.fadeAlpha(to: 1, duration: 0.1)
        let flashAction = SKAction.repeat(SKAction.sequence([flashWhite, removeFlash]), count: 3)
        var shotsArray = [SKAction]()
        for _ in 0...15 {
            let offset = random(min: -50.0, max: 50.0)
            let shootAction = getShootAction(scene: scene, offset: offset)
            shotsArray.append(shootAction)
            shotsArray.append(SKAction.wait(forDuration: 0.02))
        }
        run(SKAction.sequence([flashAction, SKAction.sequence(shotsArray)])) { [unowned self] in
            self.run(self.getWalkAndShootAction(scene: scene), withKey: "bossAction")
            self.runSpecialAttackTimer(scene: scene)
        }
    }
    
    func getBossWalkUpDownAction(scene: SKScene) -> SKAction {
        let actionWalkTop = SKAction.move(to: CGPoint(x:startPoint.x - bossMoveDistance, y:scene.size.height/2), duration: 1)
        let actionWalkBottom = SKAction.move(to: CGPoint(x:startPoint.x - bossMoveDistance, y:0), duration: 1)
        return SKAction.repeatForever(SKAction.sequence([actionWalkTop, actionWalkBottom]))
    }
    
    func getShootAction(scene:SKScene, offset: CGFloat) -> SKAction {
        let shootAction = SKAction.run { [unowned self] in
            let projectile = BossProjectileNode()
            projectile.setupWithBossAttackType(attackType: self.attackType)
            projectile.position = CGPoint(x: self.position.x, y: self.position.y + offset)
            projectile.setup(type: .enemy, assetName: "ic_shuriken3")
            
            let offset = CGPoint(x: -100, y: 0)
            
            guard let scene = self.scene else {
                return
            }
            scene.addChild(projectile)
            self.monsterDelegate?.monsterDidShoot(projectile: projectile)
            let direction = offset.normalized()
            projectile.shootWithDirection(direction: direction)
        }
        
        return shootAction
    }
    
    func getBossRepeatedShootAction(scene:SKScene) -> SKAction{
        let shootAction = getShootAction(scene: scene, offset: 0)
        let shotFrequency = random(min: 0.2, max: 1)
        
        let normalShootAction = SKAction.sequence([shootAction, SKAction.wait(forDuration: TimeInterval(shotFrequency))])
        return SKAction.repeatForever(normalShootAction)
    }
}
