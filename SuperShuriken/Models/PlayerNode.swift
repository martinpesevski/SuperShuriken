//
//  playerNode.swift
//  SuperShuriken
//
//  Created by Martin.Pesevski on 1/15/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit
import GameplayKit

enum PlayerAnimationType: String {
    case Walk = "playerWalkAnimation"
    case Jump = "playerJumpAnimation"
    case Shoot = "playerShootAnimation"
    case Death = "playerDeathAnimation"
    case walkToPoint = "playerWalkToPointAnimation"
}

enum AttackType: Int {
    case Melee = 0
    case Projectile = 1
}

class PlayerNode: SKSpriteNode, GKAgentDelegate {
    private var playerWalkingFrames: [SKTexture] = []
    private var playerShootingFrames: [SKTexture] = []
    private var playerDeathFrames: [SKTexture] = []
    
    private var isJumping = false;
    private var isDragging = false;

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
    
    //MARK: - touches
    func handleTouchStart(location: CGPoint) {
        removeAction(forKey: "runToPoint")
        self.stopAnimation(type: .walkToPoint)
        playAnimation(type: .Walk, completion: {})
        if fabs(location.y.distance(to: position.y)) < 50 {
            isDragging = true
            position = CGPoint(x: position.x, y: location.y)
        } else {
            isDragging = false
            walkToPoint(point: CGPoint(x: position.x, y: location.y), completion: {})
        }
    }
    
    
    func handleTouchMoved(location: CGPoint) {
        if GameManager.sharedInstance.isGameFinished {
            self.stopAnimation(type: .walkToPoint)
            self.stopAnimation(type: .Walk)
            return;
        }
        
        if isDragging || fabs(location.y.distance(to: position.y)) < 50 {
            self.stopAnimation(type: .walkToPoint)
            isDragging = true;
            position = CGPoint(x: position.x, y: location.y)
        }
    }
    
    func handleTouchEnded(location: CGPoint) {
        if GameManager.sharedInstance.isGameFinished {
            self.stopAnimation(type: .walkToPoint)
            self.stopAnimation(type: .Walk)
            return;
        }
        
        self.stopAnimation(type: .walkToPoint)	
        walkToPoint(point: location) {
            self.stopAnimation(type: .Walk)
        }
    }
    
    func handleGotHit() {
        stopAnimation(type: .Walk)
        playAnimation(type: .Death, completion:{})
    }
    
    func walkToPoint(point: CGPoint, completion: @escaping () -> Void) {
        let distanceToWalk = distance(float2(Float(position.x), Float(point.y)),
                                      float2(Float(position.x),Float(position.y)))
        let duration = distanceToWalk/400
        let destinationPoint = CGPoint(x: position.x, y: point.y)
        run(action: SKAction.move(to: destinationPoint, duration: TimeInterval(duration)), withKey: PlayerAnimationType.walkToPoint.rawValue) {
            completion()
        }
    }
    
    //MARK: - animations
    func playAnimation(type: PlayerAnimationType, completion: @escaping () -> Void) {
        switch type {
        case .Walk:
            playWalkingAnimation(completion: completion)
        case .Shoot:
            playShootAnimation(completion: completion)
        case .Death:
            playDeathAnimation(completion: completion)
        case .Jump:
            playJumpAnimation(completion: completion)
        default:
            break
        }
    }
    
    func stopAnimation(type: PlayerAnimationType) {
        if action(forKey: type.rawValue) != nil {
            removeAction(forKey: type.rawValue)
            texture = SKTexture.init(image: #imageLiteral(resourceName: "ic_player"))
        }
    }
    
    private func playWalkingAnimation(completion: () -> Void) {
        run(SKAction.repeatForever(
            SKAction.animate(with: playerWalkingFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)),
            withKey:PlayerAnimationType.Walk.rawValue)
    }
    
    private func playShootAnimation(completion: () -> Void) {
        if action(forKey: PlayerAnimationType.Shoot.rawValue) != nil {
            return
        }
        run(SKAction.animate(with: playerShootingFrames, timePerFrame: 0.1, resize: false, restore: true), withKey: PlayerAnimationType.Shoot.rawValue)
    }
    
    private func playDeathAnimation(completion: () -> Void) {
        run(SKAction.animate(with: playerDeathFrames, timePerFrame: 0.1, resize: false, restore: false), withKey: PlayerAnimationType.Death.rawValue)
    }
    
    private func playJumpAnimation(completion: @escaping () -> Void) {
        let jumpUp = SKAction.move(to: CGPoint(x: position.x, y: position.y + 300), duration: 0.3)
        let fallDown = SKAction.move(to: CGPoint(x: position.x, y: position.y), duration: 0.3)
        let spriteAnimation = SKAction.animate(with: playerShootingFrames, timePerFrame: 0.3, resize: false, restore: true)
        
        let motionAnimation = SKAction.sequence([jumpUp, fallDown])
        run(action: SKAction.group([motionAnimation, spriteAnimation]), withKey: PlayerAnimationType.Jump.rawValue) {
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
