//
//  MainMenu.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 12/16/17.
//  Copyright © 2017 MP. All rights reserved.
//

import SpriteKit
import GameplayKit

class MainMenu: SKScene {
    
    var playButtonNode : SKSpriteNode!
    var backgroundNode : SKSpriteNode!
    
    override func didMove(to view: SKView) {
        playButtonNode = self.childNode(withName: "playButton") as? SKSpriteNode
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        if playButtonNode.contains(location) {
            let reveal = SKTransition.flipHorizontal(withDuration: 1)
            let gameScene = GameScene.init(size: size)
            self.view?.presentScene(gameScene, transition: reveal)
        }
    }
}
