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
    var settingsButtonNode : ButtonNode!
    var backgroundNode : SKSpriteNode!
    
    func initialize () {
        scaleMode = .aspectFit
    }
    
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
        playButtonNode.setButtonAction(target: self, triggerEvent: .TouchUp, action: #selector(onPlayTap))
        playButtonNode.setButtonLabel(title: "Play", font: "Chalkduster", fontSize: 20.0)
        playButtonNode.name = "playButton"
        playPlaceholder.removeFromParent()
        self.addChild(playButtonNode)
        
        guard let settingsPlaceholder = childNode(withName: "settingsPlaceholder") else {
            return
        }
        
        settingsButtonNode = ButtonNode.init(normalTexture: buttonTexture,
                                         selectedTexture: buttonClickedTexture,
                                         disabledTexture: nil)
        settingsButtonNode.position = CGPoint.init(x: settingsPlaceholder.frame.origin.x, y: settingsPlaceholder.frame.origin.y)
        settingsButtonNode.size = CGSize.init(width: 500, height: 100)
        settingsButtonNode.zPosition = 2
        settingsButtonNode.setButtonAction(target: self, triggerEvent: .TouchUp, action: #selector(onSettingsTap))
        settingsButtonNode.setButtonLabel(title: "Settings", font: "Chalkduster", fontSize: 20.0)
        settingsButtonNode.name = "settingsButton"
        settingsPlaceholder.removeFromParent()
        self.addChild(settingsButtonNode)
    }
    
    @objc func onPlayTap() {
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        let gameScene = GameScene.init(size: size)
        self.view?.presentScene(gameScene, transition: reveal)
    }
    
    @objc func onSettingsTap() {
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        if let scene = SettingsScene(fileNamed: "SettingsScene") {
            scene.scaleMode = .aspectFit
            
            self.view?.presentScene(scene, transition: reveal)
        }
    }
}
