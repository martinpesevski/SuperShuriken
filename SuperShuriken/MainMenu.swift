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
    
    var playButtonNode : MenuButton!
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        playButtonNode = MenuButton.init(color: UIColor.blue, size: CGSize.init(width: size.width/2, height: 70), text: "Play")
        playButtonNode.position = CGPoint.init(x: size.width/2, y: size.height * 0.8)
        
        addChild(playButtonNode)
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
