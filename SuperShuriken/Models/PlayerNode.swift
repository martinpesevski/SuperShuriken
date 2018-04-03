//
//  playerNode.swift
//  SuperShuriken
//
//  Created by Martin.Pesevski on 1/15/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit

class PlayerNode: SKSpriteNode {
    private var bokiWalkingFrames: [SKTexture] = []
    
    func setup() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Player
        physicsBody?.contactTestBitMask = PhysicsCategory.EnemyProjectile
        physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let bokiWalkingAtlas = SKTextureAtlas(named: "bokiBatine")
        var walkingFrames: [SKTexture] = []
        
        let numImages = bokiWalkingAtlas.textureNames.count
        for i in 0..<numImages {
            let bokiTextureName = "bokiBatine_\(i)"
            walkingFrames.append(bokiWalkingAtlas.textureNamed(bokiTextureName))
        }
        bokiWalkingFrames = walkingFrames
    }
    
    func playWalkingAnimation() {
        run(SKAction.repeatForever(
            SKAction.animate(with: bokiWalkingFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)),
            withKey:"walkingInPlaceBoki")
    }
}
