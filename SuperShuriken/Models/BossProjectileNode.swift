//
//  BossProjectileNode.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 10/20/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit
import SpriteKit

class BossProjectileNode: ProjectileNode {
    var attackType = BossAttackType.straightShot
    
    func setupWithBossAttackType(attackType: BossAttackType){
        self.attackType = attackType
    }
    
    override func getProjectileMovement() -> SKAction {
        switch attackType {
        case .straightShot:
            return createStraightMovement()
        case .curveShot:
            return createCurveMovement()
        }
    }
    
    func createStraightMovement() -> SKAction {
        let actionMove = SKAction.move(to: destination, duration: getDuration(pointA: position, pointB: destination, speed: projectileSpeed))
        let actionMoveDone = SKAction.removeFromParent()
        return SKAction.sequence([actionMove, actionMoveDone])
    }
    
    func createCurveMovement() -> SKAction {
        let path = CGMutablePath()
        path.move(to: position)
        var offset = 0
        for _ in 1...7 {
            path.addLine(to: CGPoint(x: -100 + offset, y: 50))
            path.addLine(to: CGPoint(x: -200 + offset, y: -100))
            path.addLine(to: CGPoint(x: -300 + offset, y: 50))
            offset -= 300
        }
        
        let actionMoveZigZag = SKAction.follow(path, asOffset: true, orientToPath: false, duration:  getDuration(pointA: position, pointB: destination, speed: projectileSpeed))
        let actionMoveDone = SKAction.removeFromParent()
        return SKAction.sequence([actionMoveZigZag, actionMoveDone])
    }
}
