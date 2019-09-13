//
//  playerNode.swift
//  SuperShuriken
//
//  Created by Martin.Pesevski on 1/15/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit
import GameplayKit

enum PlayerAnimationType: String, CaseIterable {
    case Walk = "playerWalkAnimation"
    case Jump = "playerJumpAnimation"
    case Shoot = "playerShootAnimation"
    case RunShoot = "playerRunShootAnimation"
    case Death = "playerDeathAnimation"
    case Idle = "playerIdleAnimation"
    case RunSlash = "playerRunSlashAnimation"
    case walkToPoint = "playerWalkToPointAnimation"
}

enum AttackType: Int {
    case Melee = 0
    case Projectile = 1
}

class PlayerNode: SKSpriteNode, GKAgentDelegate {
    private var defaultAnimationType = PlayerAnimationType.Walk
    private var walkAction = SKAction()
    private var shootAction = SKAction()
    private var runShootAction = SKAction()
    private var deathAction = SKAction()
    private var idleAction = SKAction()
    private var runSlashAction = SKAction()

    private var isJumping = false;
    private var isDragging = false;
    private var isScrollingBackground = true;

    func setup() {
        let prevAnchor = anchorPoint
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 111, height: 156), center: CGPoint(x: 0, y: 20))
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Player
        physicsBody?.contactTestBitMask = PhysicsCategory.EnemyProjectile
        physicsBody?.collisionBitMask = PhysicsCategory.None
        anchorPoint = prevAnchor
        
        setupActions()
        
        playAnimation(type: defaultAnimationType, completion: {})
        
        NotificationCenter.default.addObserver(self, selector: #selector(onLevelChanged), name: Notification.Name.newLevelStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onGameStarted), name: Notification.Name.gameStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onGameEnded), name: Notification.Name.gameOver, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onLevelChanged(notification: Notification) {
        guard let isBossLevel = notification.userInfo?["isBossLevel"] as? Bool else {
            return
        }
        isScrollingBackground = !isBossLevel
        setNewDefaultAnimation(isBossLevel ? .Idle : .Walk)
    }
    
    @objc func onGameStarted() {
        setNewDefaultAnimation(.Walk)
    }
    
    @objc func onGameEnded() {
        if self.action(forKey: PlayerAnimationType.Death.rawValue) == nil {
            setNewDefaultAnimation(.Idle)
        }
    }
    
    func setNewDefaultAnimation(_ type: PlayerAnimationType) {
        switch type {
        case .Walk:
            stopAnimation(type: .Idle)
        case .Idle:
            stopAnimation(type: .Walk)
        default:
            break
        }
        
        defaultAnimationType = type
        
        if self.action(forKey: defaultAnimationType.rawValue) == nil {
            playAnimation(type: defaultAnimationType, completion: {}   )
        }
    }
    
    func setupActions() {
        walkAction = SKAction.repeatForever(
            SKAction.animate(with: app.animationManager.playerWalkingFrames,
                             timePerFrame: 0.03,
                             resize: false,
                             restore: true))
        
        shootAction = SKAction.animate(with: app.animationManager.playerShootingFrames, timePerFrame: 0.03, resize: false, restore: true)
        
        runShootAction = SKAction.animate(with: app.animationManager.playerRunShootFrames, timePerFrame: 0.03, resize: false, restore: true)
        
        deathAction = SKAction.animate(with: app.animationManager.playerDeathFrames, timePerFrame: 0.05, resize: false, restore: false)
        
        idleAction = SKAction.repeatForever(SKAction.animate(with: app.animationManager.playerIdleFrames, timePerFrame: 0.05, resize: false, restore: false))
        
        runSlashAction = SKAction.animate(with: app.animationManager.playerRunSlashFrames, timePerFrame: 0.05, resize: false, restore: false)
    }
    
    //MARK: - touches
    func handleTouchStart(location: CGPoint) {
        removeAction(forKey: "runToPoint")
        stopAllAnimations()
        playAnimation(type: .Walk, completion: {})
        if fabs(location.y.distance(to: position.y)) < 50 {
            isDragging = true
            position = CGPoint(x: position.x, y: min(horizonVerticalLocation, location.y))
        } else {
            isDragging = false
            walkToPoint(point: CGPoint(x: position.x, y: min(horizonVerticalLocation, location.y)), completion: {})
        }
    }
    
    
    func handleTouchMoved(location: CGPoint) {
        if app.gameManager.isGameFinished {
            self.stopAllAnimationsExcept(animationType: .Death)
            return;
        }
        
        if isDragging || fabs(location.y.distance(to: position.y)) < 50 {
            self.stopAnimation(type: .walkToPoint)
            self.stopAnimation(type: .Idle)
            isDragging = true;
            position = CGPoint(x: position.x, y: min(horizonVerticalLocation, location.y))
        }
    }
    
    func handleTouchEnded(location: CGPoint) {
        isDragging = false

        if app.gameManager.isGameFinished {
            stopAllAnimationsExcept(animationType: .Death)
            return;
        }
        
        stopAllAnimations()
        
        if self.action(forKey: PlayerAnimationType.Walk.rawValue) == nil {
            playAnimation(type: .Walk, completion: {})
        }
    
        walkToPoint(point: CGPoint(x: position.x, y: min(horizonVerticalLocation, location.y))) { [unowned self] in
            if self.action(forKey: self.defaultAnimationType.rawValue) == nil {
                self.playAnimation(type: self.defaultAnimationType, completion: {}   )
            }
        }
    }
    
    func handleShootStart(){

    }
    
    func handleShootEnd(){
        stopAllAnimations()
        if isDragging || isScrollingBackground {
            playAnimation(type: .RunShoot, completion: { [unowned self] in
                self.playAnimation(type: self.isDragging ? .Walk : self.defaultAnimationType, completion: {})
            })
        } else {
            playAnimation(type: .Shoot) { [unowned self] in
                self.playAnimation(type: self.isDragging ? .Walk : self.defaultAnimationType, completion: {})
            }
        }
    }
    
    func handleGotHit() {
        stopAllAnimations()
        playAnimation(type: .Death, completion:{})
    }
    
    func handleSlash() {
        playAnimation(type: .RunSlash) { [unowned self] in
            self.playAnimation(type: self.defaultAnimationType, completion: {})
        }
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
        case .RunShoot:
            playRunShootAnimation(completion: completion)
        case .Death:
            playDeathAnimation(completion: completion)
        case .Idle:
            playIdleAnimation(completion: completion)
        case .RunSlash:
            playRunSlashAnimation(completion: completion)
        default:
            break
        }
    }
    
    func stopAnimation(type: PlayerAnimationType) {
        if action(forKey: type.rawValue) != nil {
            removeAction(forKey: type.rawValue)
        }
    }
    
    func stopAllAnimations() {
        PlayerAnimationType.allCases.forEach { (type) in
            removeAction(forKey: type.rawValue)
        }
    }
    
    func stopAllAnimationsExcept(animationType: PlayerAnimationType) {
        PlayerAnimationType.allCases.forEach { (type) in
            if animationType != type {
                removeAction(forKey: type.rawValue)
            }
        }
    }
    
    private func playWalkingAnimation(completion: @escaping () -> Void) {
        run(walkAction,
            withKey:PlayerAnimationType.Walk.rawValue)
    }
    
    private func playShootAnimation(completion: @escaping () -> Void) {
        run(action: shootAction, withKey: PlayerAnimationType.Shoot.rawValue) {
            completion()
        }
    }
    
    private func playRunShootAnimation(completion: @escaping () -> Void) {
        run(action: runShootAction, withKey: PlayerAnimationType.RunShoot.rawValue) {
            completion()
        }
    }
    
    private func playDeathAnimation(completion: @escaping () -> Void) {
        run(action: deathAction, withKey: PlayerAnimationType.Death.rawValue) {
            completion()
        }
    }
    
    private func playIdleAnimation(completion: @escaping () -> Void) {
        run(idleAction, withKey: PlayerAnimationType.Idle.rawValue)
    }
    
    private func playRunSlashAnimation(completion: @escaping () -> Void) {
        run(runSlashAction, withKey: PlayerAnimationType.RunSlash.rawValue)
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
        return action(forKey: key) != nil ? true : false
    }
}
