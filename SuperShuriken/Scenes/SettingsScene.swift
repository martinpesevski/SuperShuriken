//
//  SettingsScene.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 1/14/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit

class SettingsScene : SKScene {
    var menuButton : ButtonNode!
    var soundButton : ButtonNode!
    
    override func didMove(to view: SKView) {
        guard let menuPlaceholder = childNode(withName: "backPlaceholder") as? SKSpriteNode else {
            return
        }
        guard let soundPlaceholder = childNode(withName: "soundPlaceholder") as? SKSpriteNode else {
            return
        }
        
        menuButton = ButtonNode.init(normalTexture: SKTexture.init(imageNamed: "button"),
                                     selectedTexture: SKTexture.init(imageNamed: "buttonClicked"),
                                     disabledTexture: nil)
        menuButton.setupWithNode(node: menuPlaceholder)
        menuButton.setButtonAction(target: self, triggerEvent: .TouchUp, action: #selector(onMenuTap))
        menuButton.setButtonLabel(title: "menu", font: "Chalkduster", fontSize: 20)
        
        soundButton = ButtonNode.init(normalTexture: SKTexture.init(imageNamed: "button"),
                                     selectedTexture: SKTexture.init(imageNamed: "buttonClicked"),
                                     disabledTexture: nil)
        soundButton.setupWithNode(node: soundPlaceholder)
        soundButton.setButtonAction(target: self, triggerEvent: .TouchUp, action: #selector(onSoundTap))
        let soundOn = true
        soundButton.setButtonLabel(title: "sound: \(soundOn)" as NSString, font: "Chalkduster", fontSize: 20)
        
        addChild(menuButton)
    }
    
    @objc func onMenuTap() {
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        if let scene = MainMenu(fileNamed: "MainMenu") {
            scene.initialize()
            
            self.view?.presentScene(scene, transition: reveal)
        }
    }
    
    @objc func onSoundTap() {
    }
}
