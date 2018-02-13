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
    static let Wall      : UInt32 = 0b10      // 2
    static let Projectile: UInt32 = 0b11     // 3
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

class GameScene: SKScene, SKPhysicsContactDelegate, adMobInterstitialDelegate {
    
    var player : PlayerNode!
    var monstersDestroyed = 0
    var didWin = false
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        guard let spawnPoint = self.childNode(withName: "spawnPoint") as? SKSpriteNode else {
            return
        }
        
        player = PlayerNode.init(texture: SKTexture(imageNamed: "ic_ninja_stance"))
        player.setupWithNode(node: spawnPoint)
        
        addChild(player)
        
        setupWalls()
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMonster), SKAction.wait(forDuration: TimeInterval(1.0))])))
        
        if Global.sharedInstance.isSoundOn {
            let backgroundMusic = SKAudioNode.init(fileNamed: "background-music-aac.caf")
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }

        AdsManager.sharedInstance.createAndLoadInterstitial()
        AdsManager.sharedInstance.interstitialDelegate = self
    }
    
    // MARK: helper methods
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func setupWalls() {
        guard let wallTop = self.childNode(withName: "wallTop") as? SKSpriteNode,
        let wallBottom = self.childNode(withName: "wallBottom") else {
            return
        }
        
        wallTop.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        wallTop.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        wallTop.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        wallBottom.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        wallBottom.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        wallBottom.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    func addMonster() {
        let monster = SKSpriteNode(imageNamed: "ic_monster")
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile 
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualY = random(min: -size.height/2 - monster.size.height/2, max: size.height/2 + monster.size.height/2)
        
        monster.position = CGPoint(x: size.width/2 + monster.size.width/2, y: actualY)
        
        addChild(monster)
        
        let actualDuration = random(min: CGFloat(5.0), max: CGFloat(7.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: -size.width/2 - monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.run {
            self.endGame(didWin: false)
        }
        
        monster.run(SKAction.sequence([actionMove, loseAction, actionDone]))
    }
    
    func projectileDidColideWithMonster (projectile: SKSpriteNode, monster: SKSpriteNode) {
        monstersDestroyed += 1
        if monstersDestroyed > 30 {
            endGame(didWin: true)
        }
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    
    func projectileDidColideWithWall(projectile: ProjectileNode, wall: SKSpriteNode) {
        let direction = CGPoint(x: projectile.destination.x, y: projectile.destination.y - ((projectile.destination.y - projectile.position.y) * 2))

        projectile.shootWithDirection(direction: direction.normalized())
    }
    
    func endGame(didWin: Bool) {
        scene?.view?.isPaused = true
        AdsManager.sharedInstance.showInterstitial()
    }
    
    func showGameOverScreen() {
        scene?.view?.isPaused = false
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        if let gameWonScene = GameOverScene(fileNamed: "GameOverScene") {
            gameWonScene.scaleMode = .aspectFit
            gameWonScene.setup(didWin: didWin)
            
            self.view?.presentScene(gameWonScene, transition: reveal)
        }
    }
    
    // MARK: touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.texture = SKTexture.init(imageNamed: "ic_ninja_throw")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
//        run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        let touchLocation = touch.location(in: self)
        
        player.texture = SKTexture.init(imageNamed: "ic_ninja_stance")
        
        let projectile = ProjectileNode(imageNamed: "ic_shuriken")
        projectile.position = player.position
        projectile.setup()
        
        let offset = touchLocation - projectile.position
        
        if offset.x < 0 {
            return
        }
        
        addChild(projectile)
        let direction = offset.normalized()
        projectile.shootWithDirection(direction: direction)
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
        } else if (firstBody.categoryBitMask & PhysicsCategory.Wall != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0) {
            if let wall = firstBody.node as? SKSpriteNode, let projectile = secondBody.node as? ProjectileNode {
                projectileDidColideWithWall(projectile: projectile, wall: wall)
            }
        }
    }
    
    func didHideInterstitial() {
        showGameOverScreen()
    }
}
