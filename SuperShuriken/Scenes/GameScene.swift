//
//  GameScene.swift
//  ClassicPong
//
//  Created by Martin Peshevski on 9/26/17.
//  Copyright © 2017 MP. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

extension SKSpriteNode {
    func setupWithNode(node: SKSpriteNode){
        self.position = node.position
        self.zPosition = node.zPosition
        self.size = node.size
        node.removeFromParent()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player : PlayerNode!
    var monstersDestroyed = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        guard let spawnPoint = self.childNode(withName: "spawnPoint") as? SKSpriteNode else {
            return
        }
        
        player = PlayerNode.init(texture: SKTexture(imageNamed: "player"))
        player.setupWithNode(node: spawnPoint)
        
        addChild(player)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMonster), SKAction.wait(forDuration: TimeInterval(1.0))])))
        
        let backgroundMusic = SKAudioNode.init(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    
    // MARK: helper methods
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        let monster = SKSpriteNode(imageNamed: "monster")
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualY = random(min: -size.height/2 - monster.size.height/2, max: size.height/2 + monster.size.height/2)
        
        monster.position = CGPoint(x: size.width/2 + monster.size.width/2, y: actualY)
        
        addChild(monster)
        
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: -size.width/2 - monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.run {
            self.endGame(didWin: false)
        }
        
        monster.run(SKAction.sequence([actionMove, loseAction, actionDone]))
    }
    
    func projectileDidColideWithMonster (projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("hit")
        monstersDestroyed += 1
        if monstersDestroyed > 30 {
            endGame(didWin: true)
        }
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    
    func endGame(didWin: Bool) {
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        if let gameWonScene = GameOverScene(fileNamed: "GameOverScene") {
            gameWonScene.scaleMode = .aspectFit
            gameWonScene.setup(didWin: didWin)
            
            self.view?.presentScene(gameWonScene, transition: reveal)
        }
    }
    
    // MARK: touches
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
//        run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        let touchLocation = touch.location(in: self)
        
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        let offset = touchLocation - projectile.position
        
        if offset.x < 0 {
            return
        }
        
        addChild(projectile)
        let direction = offset.normalized()
        let shootAmount = direction * 2000
        let destination = shootAmount + projectile.position
        
        let actionMove = SKAction.move(to: destination, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        let projectileMovement = SKAction.sequence([actionMove, actionMoveDone])
        let projectileRotation = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.2))
        projectile.run(SKAction.group([projectileMovement, projectileRotation]))
    }
    
    // MARK: Physics
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0) {
            if let monster = firstBody.node as? SKSpriteNode, let projectile = secondBody.node as? SKSpriteNode {
                projectileDidColideWithMonster(projectile: projectile, monster: monster)
            }
        }
    }
}
