//
//  playerNode.swift
//  SuperShuriken
//
//  Created by Martin.Pesevski on 1/15/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit
import GameplayKit

enum playerAnimationType: String {
    case Walk = "playerWalkAnimation"
    case Jump = "playerJumpAnimation"
    case Shoot = "playerShootAnimation"
    case Death = "playerDeathAnimation"
}

class PlayerNode: SKSpriteNode, GKAgentDelegate {
    private var playerWalkingFrames: [SKTexture] = []
    private var playerShootingFrames: [SKTexture] = []
    private var playerDeathFrames: [SKTexture] = []
    
    private var isJumping = false;
    
    //GameplayKit
    let agent = GKAgent2D()
    let trackingAgent = GKAgent2D()
    var seekGoal : GKGoal = GKGoal()
    let stopGoal : GKGoal = GKGoal()
    
    var seeking : Bool = false {
        willSet {
//            if newValue {
//                agent.behavior?.setWeight(1, for: seekGoal)
//                agent.behavior?.setWeight(0, for: stopGoal)
//            }else{
//                agent.behavior?.setWeight(0, for: seekGoal)
//                agent.behavior?.setWeight(1, for: stopGoal)
//            }
        }
    }
    
    var agentSystem = GKComponentSystem()
    
    var lastUpdateTime : TimeInterval = 0
    

    func setup() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Player
        physicsBody?.contactTestBitMask = PhysicsCategory.EnemyProjectile
        physicsBody?.collisionBitMask = PhysicsCategory.None
        texture = SKTexture.init(image: #imageLiteral(resourceName: "ic_player"))
        
        //GameplayKit
        seekGoal = GKGoal(toSeekAgent: trackingAgent)

        agent.position = vector_float2(Float(position.x), Float(position.y))
        agent.delegate = self
        agent.maxSpeed = 100 * 4
        agent.maxAcceleration = 500 * 4
        agent.behavior = GKBehavior()
        agent.behavior?.setWeight(1, for: seekGoal)
        agent.mass = 0.01

        agentSystem = GKComponentSystem(componentClass: GKAgent2D.self)
        
        agentSystem.addComponent(agent)
        
        
        playerWalkingFrames = createAtlas(name: "playerWalk")
        playerDeathFrames = createAtlas(name: "playerDeath")
        playerShootingFrames = createAtlas(name: "playerShoot")
    }
    
    func update(currentTime: TimeInterval){
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        self.agentSystem.update(deltaTime: delta)
    }
    
    //MARK: touches
    func handleTouchStart(location: CGPoint) {
        self.seeking = true
        playAnimation(type: .Walk, completion: {})
        trackingAgent.position = vector_float2(Float(location.x), Float(location.y))
    }
    
    
    func handleTouchMoved(location: CGPoint) {
        trackingAgent.position = vector_float2(Float(location.x), Float(location.y))
    }
    
    func handleTouchEnded(location: CGPoint) {
        self.seeking = false
        stopAnimation(type: .Walk)
    }
    
    func handleGotHit() {
        stopAnimation(type: .Walk)
        playAnimation(type: .Death, completion:{})
    }
    
    //MARK: animations
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
    
    func walkToPoint(point: CGPoint) {
        if point.y < horizonVerticalLocation {
            let verticalMovePoint = CGPoint(x: position.x, y: point.y)
            run(SKAction.move(to: verticalMovePoint, duration: 0.5))
        } else if point.y >= horizonVerticalLocation + 50 {
            let verticalMovePoint = CGPoint(x: position.x, y: horizonVerticalLocation)
            run(SKAction.sequence([SKAction.move(to: verticalMovePoint, duration: 0.5), SKAction.run {
                self.playAnimation(type: .Jump, completion: {})
                }]))
        } else {
            let verticalMovePoint = CGPoint(x: position.x, y: horizonVerticalLocation)
            run(SKAction.move(to: verticalMovePoint, duration: 0.5))
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
    
    //MARK: gkAgentDelegate
    
    func agentWillUpdate(_ agent: GKAgent) {
        
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        guard let agent2D = agent as? GKAgent2D else {
            return
        }
        
        position = CGPoint(x: position.x, y: CGFloat(agent2D.position.y))
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
