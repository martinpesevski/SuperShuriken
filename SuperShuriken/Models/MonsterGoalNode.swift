//
//  MonsterGoalNode.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 3/5/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit

class MonsterGoalNode: SKSpriteNode {

    func setup() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = PhysicsCategory.Goal
        physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        physicsBody?.collisionBitMask = PhysicsCategory.None
    }
}
