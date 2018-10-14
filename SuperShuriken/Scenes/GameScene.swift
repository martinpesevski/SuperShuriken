//
//  GameScene.swift
//  ClassicPong
//
//  Created by Martin Peshevski on 9/26/17.
//  Copyright © 2017 MP. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate, adMobInterstitialDelegate, GameManagerDelegate, MonsterDelegate {
    
    var menuButton: ButtonNode!
    var player : PlayerNode!
    var didWin = false
    
    var monsterSpawner = SKSpriteNode()
    var monsterGoal = MonsterGoalNode()
    
    var scoreLabel : SKLabelNode!
    var gameOverLabel : SKLabelNode!
    var nextLevelLabel : SKLabelNode!
    var tapToRetryLabel : SKLabelNode!
    
    var gameManager = GameManager()
    var monstersArray = [MonsterNode]()
    var playerProjectilesArray = [ProjectileNode]()
    var enemyProjectilesArray = [ProjectileNode]()

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
        
        guard let menuButtonPlaceholder = self.childNode(withName: "menuButton") as? SKSpriteNode else {
            return
        }
        
        gameOverLabel = gameManager.createLabel(text: "YOU LOST :(", size: 80)
        nextLevelLabel = gameManager.createLabel(text: "GET READY FOR NEXT LEVEL", size: 80)
        tapToRetryLabel = gameManager.createLabel(text: "Tap to retry", size: 40)

        scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode ?? SKLabelNode(text: "Score")
        updateScoreLabel()
        
        menuButton = ButtonNode.init(normalTexture: SKTexture.init(imageNamed: "ic_button"),
                                                  selectedTexture: SKTexture.init(imageNamed: "ic_buttonClicked"),
                                                  disabledTexture: nil)
        menuButton.setupWithNode(node: menuButtonPlaceholder)
        menuButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(onMenuTap))
        menuButton.setButtonLabel(title: "MENU", font: "Chalkduster", fontSize: 40)
        
        player = PlayerNode(imageNamed: "ic_player")
        player.setupWithNode(node: spawnPoint)
        player.setup()
        
        monsterGoal.setupWithNode(node: monsterGoalPlaceholder)
        monsterGoal.setup()
        
        monsterSpawner.setupWithNode(node: enemySpawner)
        
        addChild(player)
        addChild(monsterGoal)
        addChild(monsterSpawner)
        addChild(menuButton)

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
        if gameManager.isGameFinished {
            return
        }
        
        run(SKAction.repeat(SKAction.sequence([SKAction.run(addMonster), SKAction.wait(forDuration: TimeInterval(1.0))]), count: gameManager.numberOfMonstersForCurrentLevel()))
    }
    
    func addMonster() {
        let monster = MonsterNode(imageNamed: "ic_monster")
        var actualY = random(min: monsterSpawner.frame.origin.y + monster.size.height/2,
                             max: (monsterSpawner.frame.origin.y + horizonVerticalLocation) - monster.size.height/2)
        
        let type : MonsterType
        if gameManager.isBossLevel {
            type = MonsterType.boss
        } else {
            type = MonsterType(rawValue: 1 + Int(arc4random_uniform(UInt32(MonsterType.count)))) ?? MonsterType.ghost
        }
        
        if type == .air {
             actualY = random(min: (monsterSpawner.frame.origin.y + horizonVerticalLocation),
                                 max: monsterSpawner.frame.origin.y + monsterSpawner.frame.size.height)
        }
        
        monster.setup(startPoint: CGPoint(x: size.width + monster.size.width/2, y: actualY), type: type)
        monster.actualDuration = gameManager.monsterTimeToCrossScreen()
        monster.monsterDelegate = self
        
        addChild(monster)
        monstersArray.append(monster)
        gameManager.isBossLevel ? monster.playBossAnimation() : monster.playRunAnimation()
    }
    
    func shootProjectile(location: CGPoint) {
        player.playAnimation(type: .Shoot, completion: {})
        
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
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(gameManager.score)"
    }
    
    func levelFinished() {
        if gameManager.isGameFinished {return}
        gameManager.loadNextLevel()
        if nextLevelLabel.parent == nil { self.addChild(nextLevelLabel) }
        nextLevelLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        run(SKAction.sequence([ SKAction.wait(forDuration: 5), SKAction.run({
            self.nextLevelLabel.removeFromParent()
            self.startNextlevel()
        })]), withKey: "startNextLevel")
    }
    
    func endGame(didWin: Bool) {
        self.didWin = didWin
        scene?.view?.isPaused = true
        
        removeAction(forKey: "startNextLevel")
        
        if gameOverLabel.parent == nil { self.addChild(gameOverLabel) }
        if tapToRetryLabel.parent == nil { self.addChild(tapToRetryLabel) }
        
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        tapToRetryLabel.position = CGPoint(x: frame.midX, y: frame.midY/2)
        
        self.gameManager.isGameFinished = true
        AdsManager.sharedInstance.showInterstitial()
    }
    
    func restart() {
        gameManager.restart()
        removeAction(forKey: "startNextLevel")
        gameOverLabel.removeFromParent()
        tapToRetryLabel.removeFromParent()
        updateScoreLabel()
        startNextlevel()
        player.texture = SKTexture.init(imageNamed: "ic_player")
    }
    
    func showGameOverScreen() {
        scene?.view?.isPaused = false
        
        for monster in monstersArray {
            monster.removeFromParent()
        }
        monstersArray.removeAll()
        
        for projectile in playerProjectilesArray {
            projectile.removeFromParent()
        }
        playerProjectilesArray.removeAll()
        
        for projectile in enemyProjectilesArray {
            projectile.removeFromParent()
        }
        enemyProjectilesArray.removeAll()
    }
        
    //MARK: collisions
    
    func projectileDidColideWithMonster (projectile: ProjectileNode, monster: MonsterNode) {
        projectile.removeFromParent()
        playerProjectilesArray = playerProjectilesArray.filter{$0 != projectile}
        
        if monster.hitAndCheckDead() {
            monstersArray = monstersArray.filter{$0 != monster}
            monster.playDeathAnimation()
            
            if gameManager.isBossLevel {
                for projectile in enemyProjectilesArray {
                    projectile.removeFromParent()
                }
                enemyProjectilesArray.removeAll()
            }
            
            gameManager.updateScore(value: monster.type.rawValue)
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
        monstersArray = monstersArray.filter{$0 != monster}

        endGame(didWin: false)
    }
    
    func monsterDidCollideWithPlayer(monster: MonsterNode, player: PlayerNode) {
        monstersArray = monstersArray.filter{$0 != monster}
        monster.playDeathAnimation()
        
        gameManager.updateScore(value: monster.type.rawValue)
        updateScoreLabel()
    }
    
    // MARK: touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameManager.isGameFinished {
            restart()
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
            shootProjectile(location: location)
            break
        default:
            break
        }
    }
    
    @objc func onMenuTap(){
        gameManager.isGameFinished = true
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        if let scene = MainMenu(fileNamed: "MainMenu") {
            scene.initialize()
            
            self.view?.presentScene(scene, transition: reveal)
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
    
    //MARK: admob delegate
    
    func didHideInterstitial() {
        showGameOverScreen()
    }
    
    //MARK: monster delegate
    
    func monsterDidShoot(projectile: ProjectileNode) {
        enemyProjectilesArray.append(projectile)
    }
}
