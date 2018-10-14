//
//  BossNode.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 10/14/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit
import SpriteKit

class BossNode: MonsterNode {
    
    private let bossMoveDistance:CGFloat = 150

    
    func playBossAnimation() {
        let actionWalkOnScreen = SKAction.move(to: CGPoint(x: startPoint.x - bossMoveDistance, y: startPoint.y), duration: TimeInterval(1))
        guard let scene = scene else {
            return
        }
        let actionWalkTop = SKAction.move(to: CGPoint(x:startPoint.x - bossMoveDistance, y:scene.size.height/2), duration: 1)
        let actionWalkBottom = SKAction.move(to: CGPoint(x:startPoint.x - bossMoveDistance, y:0), duration: 1)
        let actionWalkUpDown = SKAction.repeatForever(SKAction.sequence([actionWalkTop, actionWalkBottom]))
        
        let bossShootingAction = startBossShooting()
        let walkAndShootAction = SKAction.group([actionWalkUpDown, bossShootingAction])
        let bossMoveAnimation = SKAction.sequence([actionWalkOnScreen, walkAndShootAction])
        run(bossMoveAnimation, withKey: "bossAction")
    }
    
    func startBossShooting() -> SKAction{
        let shootAction = SKAction.run {
            let projectile = ProjectileNode()
            projectile.position = self.position
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
        let shotFrequency = random(min: 0.2, max: 1)
        return SKAction.repeatForever(SKAction.sequence([shootAction, SKAction.wait(forDuration: TimeInterval(shotFrequency))]) )
    }
}
