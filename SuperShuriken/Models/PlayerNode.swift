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
    case Jump = "playerJumpAnimation"
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
    
    func playAnimation(type: playerAnimationType, completion: @escaping () -> Void) {
        switch type {
        case .Walk:
            playWalkingAnimation(completion: completion)
        case .Shoot:
            playShootAnimation(completion: completion)
        case .Death:
            playDeathAnimation(completion: completion)
        case .Jump:
            playJumpAnimation(completion: completion)
        }
    }
    func stopAnimation(type: playerAnimationType) {
        removeAction(forKey: type.rawValue)
        texture = SKTexture.init(image: #imageLiteral(resourceName: "ic_player"))
    }
    
    private func playWalkingAnimation(completion: () -> Void) {
        run(SKAction.repeatForever(
            SKAction.animate(with: playerWalkingFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)),
            withKey:playerAnimationType.Walk.rawValue)
    }
    
    private func playShootAnimation(completion: () -> Void) {
        if action(forKey: playerAnimationType.Shoot.rawValue) != nil {
            return
        }
        run(SKAction.animate(with: playerShootingFrames, timePerFrame: 0.1, resize: false, restore: true), withKey: playerAnimationType.Shoot.rawValue)
    }
    
    private func playDeathAnimation(completion: () -> Void) {
        run(SKAction.animate(with: playerDeathFrames, timePerFrame: 0.1, resize: false, restore: false), withKey: playerAnimationType.Death.rawValue)
    }
    
    private func playJumpAnimation(completion: @escaping () -> Void) {
        let jumpUp = SKAction.move(to: CGPoint(x: position.x, y: position.y + 300), duration: 0.3)
        let fallDown = SKAction.move(to: CGPoint(x: position.x, y: position.y), duration: 0.3)
        let spriteAnimation = SKAction.animate(with: playerShootingFrames, timePerFrame: 0.3, resize: false, restore: true)
        
        let motionAnimation = SKAction.sequence([jumpUp, fallDown])
        run(action: SKAction.group([motionAnimation, spriteAnimation]), withKey: playerAnimationType.Jump.rawValue) {
            completion()
        }
    }
}

extension SKNode
{
    func run(action: SKAction!, withKey: String!, optionalCompletion:(() -> Void)?) {
        if let completion = optionalCompletion
        {
            let completionAction = SKAction.run(completion)
            let compositeAction = SKAction.sequence([ action, completionAction ])
            run(compositeAction, withKey: withKey )
        }
        else
        {
            run( action, withKey: withKey )
        }
    }
    
    func actionForKeyIsRunning(key: String) -> Bool {
        return self.action(forKey: key) != nil ? true : false
    }
}
