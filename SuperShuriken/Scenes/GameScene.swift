//
//  GameScene.swift
//  ClassicPong
//
//  Created by Martin Peshevski on 9/26/17.
//  Copyright © 2017 MP. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, adMobInterstitialDelegate, GameManagerDelegate {
    
    var player : PlayerNode!
    var didWin = false
    
    var monsterSpawner = SKSpriteNode()
    var monsterGoal = MonsterGoalNode()
    var scoreLabel : SKLabelNode!
    
    var gameManager = GameManager()
    var monstersArray = [MonsterNode]()
    
    var isMovingPlayer = false
    private var activeTouches = [UITouch:String]()

    override func didMove(to view: SKView) {
        gameManager.delegate = self
        
        backgroundColor = SKColor.white
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self

        guard let spawnPoint = self.childNode(withName: "spawnPoint") as? SKSpriteNode else {
            return
        }
        
        guard let enemySpawner = self.childNode(withName: "enemySpawner") as? SKSpriteNode else {
            return
        }
        
        guard let monsterGoalPlaceholder = self.childNode(withName: "goal") as? SKSpriteNode else {
            return
        }
        
        scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode ?? SKLabelNode(text: "Score")
        updateScoreLabel()
        
        player = PlayerNode.init(texture: SKTexture(imageNamed: "ic_ninja_stance"))
        player.setupWithNode(node: spawnPoint)
        player.setup()
        
        monsterGoal.setupWithNode(node: monsterGoalPlaceholder)
        monsterGoal.setup()
        
        monsterSpawner.setupWithNode(node: enemySpawner)
        
        addChild(player)
        addChild(monsterGoal)
        addChild(monsterSpawner)
        
        setupWalls()
        startNextlevel()
        
        if Global.sharedInstance.isSoundOn {
            let backgroundMusic = SKAudioNode.init(fileNamed: "background-music-aac.caf")
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }

        AdsManager.sharedInstance.createAndLoadInterstitial()
        AdsManager.sharedInstance.interstitialDelegate = self
    }
    
    // MARK: helper methods
    
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
    
    func startNextlevel(){
        run(SKAction.repeat(SKAction.sequence([SKAction.run(addMonster), SKAction.wait(forDuration: TimeInterval(1.0))]), count: gameManager.numberOfMonstersForCurrentLevel()))
    }
    
    func addMonster() {
        let monster = MonsterNode(imageNamed: "ic_monster")

        let actualY = random(min: (monsterSpawner.frame.origin.y + monsterSpawner.size.height) - monster.size.height/2,
                             max: monsterSpawner.frame.origin.y + monster.size.height/2)
        
        let type : MonsterType
        if gameManager.isBossLevel {
            type = MonsterType.boss
        } else {
            type = MonsterType(rawValue: 1 + Int(arc4random_uniform(UInt32(MonsterType.count)))) ?? MonsterType.ghost
        }
        
        monster.setup(startPoint: CGPoint(x: size.width + monster.size.width/2, y: actualY), type: type)
        monster.actualDuration = gameManager.monsterTimeToCrossScreen()
        
        addChild(monster)
        monstersArray.append(monster)
        gameManager.isBossLevel ? monster.playBossAnimation() : monster.playRunAnimation()
    }
    
    func shootProjectile(location: CGPoint) {
        player.texture = SKTexture.init(imageNamed: "ic_ninja_stance")
        
        let projectile = ProjectileNode(imageNamed: "ic_shuriken")
        projectile.position = player.position
        projectile.setup(type: .friendly)
        
        let offset = location - projectile.position
        
        if offset.x < 0 {
            return
        }
        
        addChild(projectile)
        let direction = offset.normalized()
        projectile.shootWithDirection(direction: direction)
    }
    
    func projectileDidColideWithMonster (projectile: ProjectileNode, monster: MonsterNode) {
        projectile.removeFromParent()

        if monster.hitAndCheckDead() {
            gameManager.updateScore(value: monster.type.rawValue)
            updateScoreLabel()
            
            if let index = monstersArray.index(of:monster) {
                monstersArray.remove(at: index)
            }
            monster.playDeathAnimation()
        } else {

            monster.playHitAnimation()
        }
        
    }
    
    func projectileDidColideWithProjectile(projectile1: ProjectileNode, projectile2: ProjectileNode) {
        projectile1.removeFromParent()
        projectile2.removeFromParent()
    }
    
    func projectileDidColideWithWall(projectile: ProjectileNode, wall: SKSpriteNode) {

    }
    
    func monsterDidReachGoal(monster: MonsterNode, goal: MonsterGoalNode) {
        monster.removeFromParent()
        endGame(didWin: false)
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(gameManager.score)"
    }
    
    func levelFinished() {
        gameManager.loadNextLevel()
        let nextlevelLabel = gameManager.createNextLevelText()
        self.addChild(nextlevelLabel)
        nextlevelLabel.position = CGPoint(x: frame.midX, y: frame.midY) 
        run(SKAction.sequence([ SKAction.wait(forDuration: 5), SKAction.run({
            nextlevelLabel.removeFromParent()
            self.startNextlevel()
        })]))
    }
    
    func endGame(didWin: Bool) {
        self.didWin = didWin
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
        for touch in touches {
            let touchName = getTouchName(touch: touch)
            activeTouches[touch] = touchName
            tapBeginOn(touchName: touchName)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let touchName = activeTouches[touch] else {
                fatalError("Touch just ended but not found into activeTouches")
            }
            
            tapMovedOn(touchName: touchName, location: touch.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let touchName = activeTouches[touch] else {
                fatalError("Touch just ended but not found into activeTouches")
            }
            
            activeTouches[touch] = nil
            tapEndedOn(touchName: touchName, location: touch.location(in: self))
        }
    }
    
    func getTouchName(touch: UITouch) -> String {
        let touchLocation = touch.location(in: self)
        if touchLocation.x < frame.width/10 {
            return "movePlayer"
        } else {
            return "shoot"
        }
    }
    
    func tapBeginOn(touchName: String) {
        switch touchName {
        case "movePlayer":
            isMovingPlayer = true
            break
        case "shoot":
            player.texture = SKTexture.init(imageNamed: "ic_ninja_throw")
            break
        default:
            break
        }
    }
    
    func tapMovedOn(touchName: String, location: CGPoint) {
        switch touchName {
        case "movePlayer":
            if isMovingPlayer {
                player.position.y = min(location.y, monsterSpawner.frame.maxY);
            }
            break
        case "shoot":
            break
        default:
            break
        }
    }
    
    func tapEndedOn(touchName: String, location: CGPoint) {
        switch touchName {
        case "movePlayer":
            isMovingPlayer = false
            break
        case "shoot":
            shootProjectile(location: location)
            break
        default:
            break
        }
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
        
        if (firstBody.categoryBitMask == PhysicsCategory.Monster) &&
            (secondBody.categoryBitMask == PhysicsCategory.Projectile) {
            if let monster = firstBody.node as? MonsterNode, let projectile = secondBody.node as? ProjectileNode {
                projectileDidColideWithMonster(projectile: projectile, monster: monster)
            }
        } else if (firstBody.categoryBitMask == PhysicsCategory.Wall) &&
            (secondBody.categoryBitMask == PhysicsCategory.Projectile) {
            if let wall = firstBody.node as? SKSpriteNode, let projectile = secondBody.node as? ProjectileNode {
                projectileDidColideWithWall(projectile: projectile, wall: wall)
            }
        } else if (firstBody.categoryBitMask == PhysicsCategory.Monster) &&
            (secondBody.categoryBitMask == PhysicsCategory.Goal) {
            if let monster = firstBody.node as? MonsterNode, let goal = secondBody.node as? MonsterGoalNode {
                monsterDidReachGoal(monster: monster, goal: goal)
            }
        } else if (firstBody.categoryBitMask == PhysicsCategory.EnemyProjectile) &&
            (secondBody.categoryBitMask == PhysicsCategory.Player){
            endGame(didWin: false)
        } else if (firstBody.categoryBitMask == PhysicsCategory.Projectile) &&
            (secondBody.categoryBitMask == PhysicsCategory.EnemyProjectile){
            if let projectile1 = firstBody.node as? ProjectileNode, let projectile2 = secondBody.node as? ProjectileNode {
                projectileDidColideWithProjectile(projectile1: projectile1, projectile2: projectile2)
            }
        }
    }
    
    func didHideInterstitial() {
        showGameOverScreen()
    }
}
