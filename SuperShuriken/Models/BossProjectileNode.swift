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
        let actionMove = SKAction.move(to: destination, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        return SKAction.sequence([actionMove, actionMoveDone])
    }
    
    func createCurveMovement() -> SKAction {
        let actionMoveStraight = SKAction.move(to: destination, duration: 2.0)
        let actionMoveUp = SKAction.move(by: CGVector(dx: 0, dy: 200), duration: 0.5);
        let actionMoveDown = SKAction.move(by: CGVector(dx: 0, dy: -400), duration: 0.5);
        let actionZigZag = SKAction.repeatForever(SKAction.sequence([actionMoveUp, actionMoveDown]))
        let actionMove = SKAction.group([actionMoveStraight, actionZigZag])
        let actionMoveDone = SKAction.removeFromParent()
        return SKAction.sequence([actionMove, actionMoveDone])
    }
}
