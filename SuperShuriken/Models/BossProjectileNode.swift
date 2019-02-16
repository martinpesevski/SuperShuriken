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
    var attackType = BossAttackType.splitShot
    var angle = 0
    
    func setupWithBossAttackType(attackType: BossAttackType, angle: Int){
        self.attackType = attackType
        self.angle = angle
    }
    
    override func getProjectileMovement() -> SKAction {
        switch attackType {
        case .straightShot, .splitShot:
            return createStraightMovement(angle: angle)
        case .curveShot:
            return createCurveMovement()
        }
    }
    
    func createStraightMovement(angle: Int) -> SKAction {
        let newDestination = CGPoint(x: destination.x, y: destination.y + CGFloat(angle))
        let actionMove = SKAction.move(to: newDestination, duration: getDuration(pointA: position, pointB: destination, speed: projectileSpeed))
        let actionMoveDone = SKAction.removeFromParent()
        return SKAction.sequence([actionMove, actionMoveDone])
    }
    
    func createCurveMovement() -> SKAction {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
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
