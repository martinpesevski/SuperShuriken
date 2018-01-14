//
//  GameOverScene.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 10/25/17.
//  Copyright © 2017 MP. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won: Bool) {
        super.init(size: size)
        
        backgroundColor = SKColor.white
        
        let message = won ? "You Win!" : "You Lose :("
        let retryMessage = "Tap anywhere to try again"
        
        let label = CustomLabel.init(fontName: "Chalkduster", text: message)
        label.fontSize = 40
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        let retryMessageLabel = CustomLabel.init(fontName: "Chalkduster", text: retryMessage)
        retryMessageLabel.fontSize = 25
        retryMessageLabel.position = CGPoint(x: size.width/2, y: size.height * 0.1)
        addChild(retryMessageLabel)
        
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
        guard let touch = touches.first else {
            return
        }
        
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        let gameScene = GameScene.init(size: self.size)
        self.view?.presentScene(gameScene, transition: reveal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
