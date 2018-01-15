//
//  GameOver.swift
//  SuperShuriken
//
//  Created by Martin.Pesevski on 1/15/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit

class GameOver: SKScene {
    var didWin : Bool!
    
    func setup(didWin: Bool) {
        self.didWin = didWin
    }
    
    override func didMove(to view: SKView) {
        let message = didWin ? "You Win!" : "You Lose :("
        let retryMessage = "Tap anywhere to try again"
        
        guard let mainTextLabel = childNode(withName: "mainTextLabel") as? SKLabelNode else {
            return
        }
        guard let tapToRetryLabel = childNode(withName: "tapToRetryLabel") as? SKLabelNode else {
            return
        }
        
        mainTextLabel.text = message
        tapToRetryLabel.text = retryMessage
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.run {
                let reveal = SKTransition.flipHorizontal(withDuration: 1)
                if let scene = MainMenu(fileNamed: "MainMenu") {
                    scene.initialize()
                    self.view?.presentScene(scene, transition: reveal)
                }
            }]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        if let gameScene = GameScene(fileNamed: "GameScene") {
            gameScene.scaleMode = .aspectFit
            
            self.view?.presentScene(gameScene, transition: reveal)
        }
    }
}
