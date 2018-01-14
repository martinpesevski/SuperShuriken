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
    
    var playButtonNode : ButtonNode!
    var backgroundNode : SKSpriteNode!
    
    override func didMove(to view: SKView) {
        let buttonTexture = SKTexture.init(imageNamed: "button")
        let buttonClickedTexture = SKTexture.init(imageNamed: "buttonClicked")

        guard let playPlaceholder = childNode(withName: "playPlaceholder") else {
            return
        }
        playButtonNode = ButtonNode.init(normalTexture: buttonTexture,
                                         selectedTexture: buttonClickedTexture,
                                         disabledTexture: nil)
        playButtonNode.position = CGPoint.init(x: playPlaceholder.frame.origin.x, y: playPlaceholder.frame.origin.y)
        playButtonNode.size = CGSize.init(width: 500, height: 100)
        playButtonNode.zPosition = 2
        playButtonNode.setButtonAction(target: self, triggerEvent: .TouchUp, action: #selector(onMenuTap))
        playButtonNode.setButtonLabel(title: "Play", font: "Chalkduster", fontSize: 20.0)
        playButtonNode.name = "playButton"
        playPlaceholder.removeFromParent()
        self.addChild(playButtonNode)
    }
    
    @objc func onMenuTap() {
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        let gameScene = GameScene.init(size: size)
        self.view?.presentScene(gameScene, transition: reveal)
    }
}
