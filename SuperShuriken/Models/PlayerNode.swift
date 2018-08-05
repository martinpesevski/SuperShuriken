//
//  playerNode.swift
//  SuperShuriken
//
//  Created by Martin.Pesevski on 1/15/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit

enum playerAnimationType: String {
    case Walk = "playerWalkAnimation"
    case Shoot = "playerShootAnimation"
    case Death = "playerDeathAnimation"
}

class PlayerNode: SKSpriteNode {
    private var playerWalkingFrames: [SKTexture] = []
    private var playerShootingFrames: [SKTexture] = []
    private var playerDeathFrames: [SKTexture] = []

    func setup() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Player
        physicsBody?.contactTestBitMask = PhysicsCategory.EnemyProjectile
        physicsBody?.collisionBitMask = PhysicsCategory.None
        texture = SKTexture.init(image: #imageLiteral(resourceName: "ic_player"))
        
        playerWalkingFrames = createAtlas(name: "playerWalk")
        playerDeathFrames = createAtlas(name: "playerDeath")
        playerShootingFrames = createAtlas(name: "playerShoot")
    }
    
    func playAnimation(type: playerAnimationType) {
        switch type {
        case .Walk:
            playWalkingAnimation()
        case .Shoot:
            playShootAnimation()
        case .Death:
            playDeathAnimation()
        }
    }
    func stopAnimation(type: playerAnimationType) {
        removeAction(forKey: type.rawValue)
        texture = SKTexture.init(image: #imageLiteral(resourceName: "ic_player"))
    }
    
    private func playWalkingAnimation() {
        run(SKAction.repeatForever(
            SKAction.animate(with: playerWalkingFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)),
            withKey:playerAnimationType.Walk.rawValue)
    }
    
    private func playShootAnimation() {
        if action(forKey: playerAnimationType.Shoot.rawValue) != nil {
            return
        }
        run(SKAction.animate(with: playerShootingFrames, timePerFrame: 0.1, resize: false, restore: true), withKey: playerAnimationType.Shoot.rawValue)
    }
    
    private func playDeathAnimation() {
        run(SKAction.animate(with: playerDeathFrames, timePerFrame: 0.1, resize: false, restore: false), withKey: playerAnimationType.Death.rawValue)
    }
}
