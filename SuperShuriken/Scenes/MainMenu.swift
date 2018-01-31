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
        let buttonTexture = SKTexture.init(imageNamed: "ic_button")
        let buttonClickedTexture = SKTexture.init(imageNamed: "ic_buttonClicked")

        guard let playPlaceholder = childNode(withName: "playPlaceholder") as? SKSpriteNode else {
            return
        }
        playButtonNode = ButtonNode.init(normalTexture: buttonTexture,
                                         selectedTexture: buttonClickedTexture,
                                         disabledTexture: nil)
        playButtonNode.setupWithNode(node: playPlaceholder)
        playButtonNode.setButtonAction(target: self, triggerEvent: .TouchUp, action: #selector(onPlayTap))
        playButtonNode.setButtonLabel(title: "Play", font: "Chalkduster", fontSize: 20.0)
        playButtonNode.name = "playButton"
        self.addChild(playButtonNode)
        
        guard let settingsPlaceholder = childNode(withName: "settingsPlaceholder") as? SKSpriteNode else {
            return
        }
        
        settingsButtonNode = ButtonNode.init(normalTexture: buttonTexture,
                                         selectedTexture: buttonClickedTexture,
                                         disabledTexture: nil)
        settingsButtonNode.setupWithNode(node: settingsPlaceholder)
        settingsButtonNode.setButtonAction(target: self, triggerEvent: .TouchUp, action: #selector(onSettingsTap))
        settingsButtonNode.setButtonLabel(title: "Settings", font: "Chalkduster", fontSize: 20.0)
        settingsButtonNode.name = "settingsButton"
        self.addChild(settingsButtonNode)
    }
    
    @objc func onPlayTap() {
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFit
            
            self.view?.presentScene(scene, transition: reveal)
        }
    }
    
    @objc func onSettingsTap() {
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        if let scene = SettingsScene(fileNamed: "SettingsScene") {
            scene.scaleMode = .aspectFit
            
            self.view?.presentScene(scene, transition: reveal)
        }
    }
}
