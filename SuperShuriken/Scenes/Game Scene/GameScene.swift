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

class GameScene: SKScene, adMobInterstitialDelegate, GameManagerDelegate, MonsterDelegate, EndGameDelegate, TutorialDelegate, UIGestureRecognizerDelegate {
    
    var player : PlayerNode!
    
    weak var gameSceneDelegate: GameSceneDelegate?
    
    private var background = PlayBackground()
    
    var gameManager = GameManager.sharedInstance
    var monsterManager = MonsterManager.sharedInstance
    var playerProjectilesArray = [ProjectileNode]()
    var enemyProjectilesArray = [ProjectileNode]()

    var activeTouches = [UITouch:String]()
    
    private lazy var tutorial = TutorialView()
    
    private lazy var endGameMenu: EndGameMenu = {
        let menu = EndGameMenu()
        menu.delegate = self
        menu.alpha = 0
        return menu
    }()
    
    private let overlay = GameSceneOverlay()
    
    override func didMove(to view: SKView) {
        guard let spawnPoint = childNode(withName: "spawnPoint") as? SKSpriteNode,
        let enemySpawner = childNode(withName: "enemySpawner") as? SKSpriteNode,
        let monsterGoalPlaceholder = childNode(withName: "goal") as? SKSpriteNode,
        let view = scene?.view else {
            return
        }
        
        gameManager.delegate = self
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        player = PlayerNode(imageNamed: "Idle")
        player.setupWithNode(node: spawnPoint)
        player.setup()
        
        monsterManager.monsterGoal.setupWithNode(node: monsterGoalPlaceholder)
        monsterManager.monsterGoal.setup()
        
        monsterManager.monsterSpawner.setupWithNode(node: enemySpawner)
                
        addChild(background)
        addChild(player)
        addChild(monsterManager.monsterGoal.copy() as! SKNode)
        addChild(monsterManager.monsterSpawner.copy() as! SKNode)
        
        view.addSubview(overlay)
        overlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(endGameMenu)
        endGameMenu.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
                
        if Global.sharedInstance.isSoundOn {
            let backgroundMusic = SKAudioNode.init(fileNamed: "background-music-aac.caf")
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(startNextlevel), name: .newLevelStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(levelFinished), name: .levelFinished, object: nil)

        AdsManager.sharedInstance.interstitialDelegate = self
    }
    
    @objc func startNextlevel(){
        guard !gameManager.isGameFinished else { return }

        overlay.nextLevelLabel.fadeOut()
        gameManager.isBossLevel ? background.stopScrolling() : background.startScrolling()
        run(SKAction.repeat(SKAction.sequence([SKAction.run(addMonster), SKAction.wait(forDuration: TimeInterval(1.0))]), count: gameManager.numberOfMonstersForCurrentLevel()), withKey:"spawnAction")
    }
    
    func addMonster() {
        monsterManager.addMonsterToScene(scene: self)
    }
    
    func shootProjectile(location: CGPoint) {
        guard !overlay.staminaBar.isExhausted else { return }
        
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
        overlay.staminaBar.didShoot()
    }
    
    func updateScoreLabel() {
        overlay.scoreLabel.text = "Score: \(gameManager.score)"
    }
    
    @objc func levelFinished() {
        overlay.nextLevelLabel.fadeIn()
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
    
    func playTutorial() {
        scene?.view?.addSubview(tutorial)
        tutorial.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tutorial.delegate = self
    }
    
    func restart() {
        overlay.countDownView.startCounting { [unowned self] in
            self.gameManager.restart()
            self.removeAction(forKey: "startNextLevel")
            self.player.stopAnimation(type: .Death)
            self.updateScoreLabel()
            self.startNextlevel()
        }
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
    
    //MARK: - tutorial delegate
    
    func didComplete() {
        restart()
    }
}
