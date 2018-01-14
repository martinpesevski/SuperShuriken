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
    
    override func didMove(to view: SKView) {
        guard let menuPlaceholder = childNode(withName: "backPlaceholder") else {
            return
        }
        
        menuButton = ButtonNode.init(normalTexture: SKTexture.init(imageNamed: "button"),
                                     selectedTexture: SKTexture.init(imageNamed: "buttonClicked"),
                                     disabledTexture: nil)
        menuButton.position = CGPoint.init(x: menuPlaceholder.frame.origin.x, y: menuPlaceholder.frame.origin.y)
        menuButton.size = CGSize.init(width: 500, height: 100)
        menuButton.zPosition = 2
        menuButton.setButtonAction(target: self, triggerEvent: .TouchUp, action: #selector(onMenuTap))
        menuButton.setButtonLabel(title: "menu", font: "Chalkduster", fontSize: 20)
        
        menuPlaceholder.removeFromParent()
        addChild(menuButton)
    }
    
    @objc func onMenuTap() {
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        if let scene = MainMenu(fileNamed: "MainMenu") {
            scene.initialize()
            
            self.view?.presentScene(scene, transition: reveal)
        }
    }
}
