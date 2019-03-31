//
//  GameScene.swift
//  ClassicPong
//
//  Created by Martin Peshevski on 9/26/17.
//  Copyright © 2017 MP. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, adMobInterstitialDelegate, GameManagerDelegate, MonsterDelegate, EndGameDelegate {
    
    var player : PlayerNode!
    var didWin = false
    
    private var endGameMenu = EndGameMenuNode()
    private var background = PlayBackground()
    
    var scoreLabel : SKLabelNode!
    var staminaBar : StaminaBarNode!
    var gameOverLabel : SKLabelNode!
    var nextLevelLabel : SKLabelNode!
    
    var gameManager = GameManager.sharedInstance
    var monsterManager = MonsterManager.sharedInstance
    var playerProjectilesArray = [ProjectileNode]()
    var enemyProjectilesArray = [ProjectileNode]()

    private var activeTouches = [UITouch:String]()
    
    
    override func didMove(to view: SKView) {
        gameManager.delegate = self
        
        backgroundColor = SKColor.white
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self

        guard let spawnPoint = childNode(withName: "spawnPoint") as? SKSpriteNode else {
            return
        }
        
        guard let enemySpawner = childNode(withName: "enemySpawner") as? SKSpriteNode else {
            return
        }
        
        guard let monsterGoalPlaceholder = childNode(withName: "goal") as? SKSpriteNode else {
            return
        }
        
        guard let staminaBarPlaceholder = childNode(withName: "staminaBar") as? SKSpriteNode else {
            return
        }
        
        gameOverLabel = gameManager.createLabel(text: "YOU LOST :(", size: 80)
        nextLevelLabel = gameManager.createLabel(text: "GET READY FOR NEXT LEVEL", size: 80)

        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode ?? SKLabelNode(text: "Score")
        updateScoreLabel()
        
        player = PlayerNode(imageNamed: "ic_player")
        player.setupWithNode(node: spawnPoint)
        player.setup()
        
        staminaBar = StaminaBarNode(imageNamed: "ic_stamina_bar_edge")
        staminaBar.setupWithNode(node: staminaBarPlaceholder)
        staminaBar.setupStaminaBar()
        
        monsterManager.monsterGoal.setupWithNode(node: monsterGoalPlaceholder)
        monsterManager.monsterGoal.setup()
        
        monsterManager.monsterSpawner.setupWithNode(node: enemySpawner)
        
        endGameMenu.isHidden = true
        endGameMenu.zPosition = 10
        endGameMenu.position = CGPoint(x: size.width/2, y: size.height/2)
        endGameMenu.delegate = self
        
        addChild(background)
        addChild(player)
        addChild(staminaBar)
        addChild(monsterManager.monsterGoal.copy() as! SKNode)
        addChild(monsterManager.monsterSpawner.copy() as! SKNode)
        addChild(endGameMenu)

        setupWalls()
        restart()
        
        if Global.sharedInstance.isSoundOn {
            let backgroundMusic = SKAudioNode.init(fileNamed: "background-music-aac.caf")
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }

        AdsManager.sharedInstance.createAndLoadInterstitial()
        AdsManager.sharedInstance.interstitialDelegate = self
    }
    
    // MARK: - helper methods
    
    func setupWalls() {
        guard let wallTop = childNode(withName: "wallTop") as? SKSpriteNode,
        let wallBottom = childNode(withName: "wallBottom") else {
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
        if gameManager.isGameFinished {
            return
        }
        gameManager.isBossLevel ? background.stopScrolling() : background.startScrollingPlatform()
        run(SKAction.repeat(SKAction.sequence([SKAction.run(addMonster), SKAction.wait(forDuration: TimeInterval(1.0))]), count: gameManager.numberOfMonstersForCurrentLevel()), withKey:"spawnAction")
    }
    
    func addMonster() {
        monsterManager.addMonsterToScene(scene: self)
    }
    
    func shootProjectile(location: CGPoint) {
        if staminaBar.isExhausted {
            return
        }
               
        let projectile = ProjectileNode()
        projectile.position = player.position
        projectile.setup(type: .friendly, assetName: Global.sharedInstance.selectedPlayerShuriken)
        
        let offset = location - projectile.position
        
        if offset.x < 0 {
            return
        }
        
        addChild(projectile)
        playerProjectilesArray.append(projectile)
        let direction = offset.normalized()
        projectile.shootWithDirection(direction: direction)
        staminaBar.didShoot()
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(gameManager.score)"
    }
    
    func levelFinished() {
        if gameManager.isGameFinished {return}
        gameManager.loadNextLevel()
        if nextLevelLabel.parent == nil { addChild(nextLevelLabel) }
        nextLevelLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        run(SKAction.sequence([ SKAction.wait(forDuration: 5), SKAction.run({
            [weak self] in
            
            if let weakSelf = self {
                weakSelf.nextLevelLabel.removeFromParent()
                weakSelf.startNextlevel()
            }
            
        })]), withKey: "startNextLevel")
    }
    
    func endGame(didWin: Bool) {
        if gameManager.isGameFinished {return}
        
        self.didWin = didWin
        background.stopScrolling()
        scene?.view?.isPaused = true
        
        removeAction(forKey: "startNextLevel")
        removeAction(forKey: "spawnAction")
        
        if gameOverLabel.parent == nil { addChild(gameOverLabel) }
        nextLevelLabel.removeFromParent()
        
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        
        gameManager.isGameFinished = true
        if Global.sharedInstance.adsEnabled {
            AdsManager.sharedInstance.showInterstitial()
        } else {
            showGameOverScreen()
        }
    }
    
    func restart() {
        gameManager.restart()
        removeAction(forKey: "startNextLevel")
        player.stopAnimation(type: .Death)
        gameOverLabel.removeFromParent()
        endGameMenu.isHidden = true
        updateScoreLabel()
        startNextlevel()
        player.playAnimation(type: .Idle, completion: {})
    }
    
    func showGameOverScreen() {
        scene?.view?.isPaused = false
        
        for monster in monsterManager.monstersArray {
            monster.removeFromParent()
        }
        monsterManager.monstersArray.removeAll()
        
        for projectile in playerProjectilesArray {
            projectile.removeFromParent()
        }
        playerProjectilesArray.removeAll()
        
        for projectile in enemyProjectilesArray {
            projectile.removeFromParent()
        }
        enemyProjectilesArray.removeAll()
        
        endGameMenu.isHidden = false
    }
        
    //MARK: - collisions
    
    func projectileDidColideWithMonster (projectile: ProjectileNode, monster: MonsterNode) {
        projectile.removeFromParent()
        playerProjectilesArray = playerProjectilesArray.filter{$0 != projectile}
        
        if monster.hitAndCheckDead(attackType: .Projectile) {
            monsterManager.monstersArray = monsterManager.monstersArray.filter{$0 != monster}
            monster.playDeathAnimation()
            
            if gameManager.isBossLevel {
                for projectile in enemyProjectilesArray {
                    projectile.removeFromParent()
                }
                enemyProjectilesArray.removeAll()
            }
            
            gameManager.updateScore(value: monster.type.scorePoints)
            updateScoreLabel()
        } else {
            monster.playHitAnimation()
        }
    }
    
    func projectileDidColideWithProjectile(projectile1: ProjectileNode, projectile2: ProjectileNode) {
        projectile1.removeFromParent()
        playerProjectilesArray = playerProjectilesArray.filter{$0 != projectile1}
        
        projectile2.removeFromParent()
        enemyProjectilesArray = enemyProjectilesArray.filter{$0 != projectile2}
    }
    
    func enemyProjectileHitPlayer(projectile: ProjectileNode, player: PlayerNode) {
        projectile.removeFromParent()
        enemyProjectilesArray = enemyProjectilesArray.filter{$0 != projectile}
        player.handleGotHit()
        endGame(didWin: false)
    }
    
    func projectileDidColideWithWall(projectile: ProjectileNode, wall: SKSpriteNode) {

    }
    
    func monsterDidReachGoal(monster: MonsterNode, goal: MonsterGoalNode) {
        monster.removeFromParent()
        monsterManager.monstersArray = monsterManager.monstersArray.filter{$0 != monster}

        endGame(didWin: false)
    }
    
    func monsterDidCollideWithPlayer(monster: MonsterNode, player: PlayerNode) {
        monsterManager.monstersArray = monsterManager.monstersArray.filter{$0 != monster}
        monster.playDeathAnimation()

        if monster.hitAndCheckDead(attackType: .Melee) {
            player.handleSlash()
            gameManager.updateScore(value: monster.type.scorePoints)
            updateScoreLabel()
        } else {
            player.handleGotHit()
            endGame(didWin: false)
        }
        
    }
    
    // MARK: - touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameManager.isGameFinished {
            return
        }

        for touch in touches {
            let touchName = getTouchName(touch: touch)
            activeTouches[touch] = touchName
            tapBeginOn(touchName: touchName, location: touch.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            guard let touchName = activeTouches[touch] else {
                return
            }
            
            tapMovedOn(touchName: touchName, location: touch.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let touchName = activeTouches[touch] else {
                return
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
    
    func tapBeginOn(touchName: String, location: CGPoint) {
        switch touchName {
        case "movePlayer":
            player.handleTouchStart(location: location)
            break
        case "shoot":
            player.handleShootStart()
            break
        default:
            break
        }
    }
    
    func tapMovedOn(touchName: String, location: CGPoint) {
        switch touchName {
        case "movePlayer":
            player.handleTouchMoved(location: location)
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
            player.handleTouchEnded(location: location)
            break
        case "shoot":
            player.handleShootEnd()
            shootProjectile(location: location)
            break
        default:
            break
        }
    }
    
    @objc func onMenuTap(){
        gameManager.restart()
        let reveal = SKTransition.moveIn(with: .up, duration: 0.3)

        if let scene = MainMenu(fileNamed: "MainMenu") {
            scene.initialize()
            
            view?.presentScene(scene, transition: reveal)
        }
    }
    
    // MARK: - Physics
    
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
        } else if (firstBody.categoryBitMask == PhysicsCategory.Monster) &&
            (secondBody.categoryBitMask == PhysicsCategory.Player) {
            if let monster = firstBody.node as? MonsterNode, let player = secondBody.node as? PlayerNode {
                monsterDidCollideWithPlayer(monster: monster, player: player)
            }
        } else if (firstBody.categoryBitMask == PhysicsCategory.EnemyProjectile) &&
            (secondBody.categoryBitMask == PhysicsCategory.Player){
            if let projectile = firstBody.node as? ProjectileNode, let player = secondBody.node as? PlayerNode {
                enemyProjectileHitPlayer(projectile: projectile, player: player)
            }
        } else if (firstBody.categoryBitMask == PhysicsCategory.Projectile) &&
            (secondBody.categoryBitMask == PhysicsCategory.EnemyProjectile){
            if let projectile1 = firstBody.node as? ProjectileNode, let projectile2 = secondBody.node as? ProjectileNode {
                projectileDidColideWithProjectile(projectile1: projectile1, projectile2: projectile2)
            }
        }
    }
    
    func onMenu() {
        let reveal = SKTransition.fade(withDuration: 1)
        if let mainMenuScene = MainMenu(fileNamed: "MainMenu") {
            mainMenuScene.initialize()
            
            self.view?.presentScene(mainMenuScene, transition: reveal)
        }
    }
    
    func onRetry() {
        restart()
    }
    
    //MARK: - admob delegate
    
    func didHideInterstitial() {
        showGameOverScreen()
    }
    
    //MARK: - monster delegate
    
    func monsterDidShoot(projectile: ProjectileNode) {
        enemyProjectilesArray.append(projectile)
    }
}
