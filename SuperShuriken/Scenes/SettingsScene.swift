//
//  SettingsScene.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 1/14/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit
import UIKit

class SettingsScene : SKScene, switchNodeDelegate {
    var menuButton : ButtonNode!
    var soundCell : LabelWithSwitchNode!
    var adsCell : LabelWithSwitchNode!

    override func didMove(to view: SKView) {
        guard let soundPlaceholder = childNode(withName: "soundPlaceholder") as? LabelWithSwitchNode,
            let adsPlaceholder = childNode(withName: "adsPlaceholder") as? LabelWithSwitchNode,
            let menuPlaceholder = childNode(withName: "backPlaceholder") as? SKSpriteNode else {
            return
        }
        
        menuButton = ButtonNode.init(normalTexture: SKTexture.init(imageNamed: "button"),
                                     selectedTexture: SKTexture.init(imageNamed: "buttonClicked"),
                                     disabledTexture: nil)
        menuButton.setupWithNode(node: menuPlaceholder)
        menuButton.setButtonAction(target: self, triggerEvent: .TouchUp, action: #selector(onMenuTap))
        menuButton.setButtonLabel(title: "menu", font: "Chalkduster", fontSize: 20)
        
        soundCell = soundPlaceholder
        soundCell.setupWithText(labelText: "Sound")
        soundCell.switchDelegate = self
        
        adsCell = adsPlaceholder
        adsCell.setupWithText(labelText: "Enable ads")
        adsCell.switchDelegate = self
        adsCell.setSwitch(isOn: AdsManager.sharedInstance.adsEnabled)
        
        addChild(menuButton)
    }
    
    @objc func onMenuTap() {
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        if let scene = MainMenu(fileNamed: "MainMenu") {
            scene.initialize()
            
            self.view?.presentScene(scene, transition: reveal)
        }
    }
    
    func onSoundTap(isOn: Bool) {
        
    }
    
    func onAdsTap(isOn: Bool) {
        isOn ? AdsManager.sharedInstance.showAds() : AdsManager.sharedInstance.removeAds()
    }
    
    func onSwitchTap(isOn: Bool, sender: SKNode) {
        if sender == soundCell {
            onSoundTap(isOn: isOn)
        } else if sender == adsCell {
            onAdsTap(isOn: isOn)
        }
    }
}
