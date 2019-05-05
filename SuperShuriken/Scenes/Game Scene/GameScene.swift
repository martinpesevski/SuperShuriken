//
//  GameScene.swift
//  ClassicPong
//
//  Created by Martin Peshevski on 9/26/17.
//  Copyright © 2017 MP. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol GameSceneDelegate: class {
    func onDismiss()
}

class GameScene: SKScene, adMobInterstitialDelegate, GameManagerDelegate, MonsterDelegate, EndGameDelegate, UIGestureRecognizerDelegate {
    
    var player : PlayerNode!
    
    weak var gameSceneDelegate: GameSceneDelegate?
    
    private var background = PlayBackground()
    
    var scoreLabel: SKLabelNode!
    var staminaBar: StaminaBarNode!
    var nextLevelLabel : SKLabelNode!
    
    var gameManager = GameManager.sharedInstance
    var monsterManager = MonsterManager.sharedInstance
    var playerProjectilesArray = [ProjectileNode]()
    var enemyProjectilesArray = [ProjectileNode]()

    var activeTouches = [UITouch:String]()
    
    private lazy var endGameMenu: EndGameMenu = {
        let menu = EndGameMenu()
        menu.delegate = self
        menu.alpha = 0
        return menu
    }()
    
    override func didMove(to view: SKView) {
        gameManager.delegate = self
        
        backgroundColor = SKColor.white
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self

        guard let spawnPoint = childNode(withName: "spawnPoint") as? SKSpriteNode,
        let enemySpawner = childNode(withName: "enemySpawner") as? SKSpriteNode,
        let monsterGoalPlaceholder = childNode(withName: "goal") as? SKSpriteNode,
        let staminaBarPlaceholder = childNode(withName: "staminaBar") as? SKSpriteNode,
        let view = scene?.view else {
            return
        }
        
        nextLevelLabel = gameManager.createLabel(text: "GET READY FOR NEXT LEVEL", size: 80)
        nextLevelLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        nextLevelLabel.zPosition = 10
        nextLevelLabel.alpha = 0
        addChild(nextLevelLabel)

        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode ?? SKLabelNode(text: "Score")
        updateScoreLabel()
        
        player = PlayerNode(imageNamed: "Idle")
        player.setupWithNode(node: spawnPoint)
        player.setup()
        
        staminaBar = StaminaBarNode(imageNamed: "ic_stamina_bar_edge")
        staminaBar.setupWithNode(node: staminaBarPlaceholder)
        staminaBar.setupStaminaBar()
        
        monsterManager.monsterGoal.setupWithNode(node: monsterGoalPlaceholder)
        monsterManager.monsterGoal.setup()
        
        monsterManager.monsterSpawner.setupWithNode(node: enemySpawner)
                
        addChild(background)
        addChild(player)
        addChild(staminaBar)
        addChild(monsterManager.monsterGoal.copy() as! SKNode)
        addChild(monsterManager.monsterSpawner.copy() as! SKNode)
        
        view.addSubview(endGameMenu)
        endGameMenu.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        restart()
        
        if Global.sharedInstance.isSoundOn {
            let backgroundMusic = SKAudioNode.init(fileNamed: "background-music-aac.caf")
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(startNextlevel), name: .newLevelStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(levelFinished), name: .levelFinished, object: nil)

        AdsManager.sharedInstance.createAndLoadInterstitial()
        AdsManager.sharedInstance.interstitialDelegate = self
    }
    
    @objc func startNextlevel(){
        guard !gameManager.isGameFinished else { return }

        nextLevelLabel.run(SKAction.fadeOut(withDuration: 0.2))
        gameManager.isBossLevel ? background.stopScrolling() : background.startScrolling()
        run(SKAction.repeat(SKAction.sequence([SKAction.run(addMonster), SKAction.wait(forDuration: TimeInterval(1.0))]), count: gameManager.numberOfMonstersForCurrentLevel()), withKey:"spawnAction")
    }
    
    func addMonster() {
        monsterManager.addMonsterToScene(scene: self)
    }
    
    func shootProjectile(location: CGPoint) {
        guard !staminaBar.isExhausted else { return }
               
        let projectile = ProjectileNode()
        projectile.position = player.position
        projectile.setup(type: .friendly, shuriken: Global.sharedInstance.selectedPlayerShuriken)
        
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
    
    @objc func levelFinished() {
        nextLevelLabel.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    func endGame() {
        guard !gameManager.isGameFinished else {return}
        
        background.stopScrolling()
        scene?.view?.isPaused = true
        
        removeAction(forKey: "startNextLevel")
        removeAction(forKey: "spawnAction")
        
        gameManager.endGame()
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
        updateScoreLabel()
        startNextlevel()
    }
    
    func showEndGameMenu() {
        endGameMenu.fadeIn()
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
        
        showEndGameMenu()
    }
    
    //MARK: - end game delegate
    
    func onMenu() {
        gameSceneDelegate?.onDismiss()
    }
    
    func onRetry() {
        endGameMenu.fadeOut()
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
