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
    var shuriken1Button : ButtonNode!
    var shuriken2Button : ButtonNode!
    var shuriken3Button : ButtonNode!

    override func didMove(to view: SKView) {
        guard let soundPlaceholder = childNode(withName: "soundPlaceholder") as? LabelWithSwitchNode,
            let adsPlaceholder = childNode(withName: "adsPlaceholder") as? LabelWithSwitchNode,
            let menuPlaceholder = childNode(withName: "backPlaceholder") as? SKSpriteNode,
            let selectShuriken1Placeholder = childNode(withName: "selectShuriken1Placeholder") as? SKSpriteNode,
            let selectShuriken2Placeholder = childNode(withName: "selectShuriken2Placeholder") as? SKSpriteNode,
            let selectShuriken3Placeholder = childNode(withName: "selectShuriken3Placeholder") as? SKSpriteNode
            else {
            return
        }
        
        menuButton = ButtonNode.init(normalTexture: SKTexture.init(imageNamed: "ic_button"),
                                     selectedTexture: SKTexture.init(imageNamed: "ic_buttonClicked"),
                                     disabledTexture: nil)
        menuButton.setupWithNode(node: menuPlaceholder)
        menuButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(onMenuTap))
        menuButton.setButtonLabel(title: "menu", font: "Chalkduster", fontSize: 20)
        menuButton.zPosition = 2
        
        soundCell = soundPlaceholder
        soundCell.setupWithText(labelText: "Sound")
        soundCell.switchDelegate = self
        soundCell.setSwitch(isOn: Global.sharedInstance.isSoundOn)
        
        shuriken1Button = ButtonNode(normalTexture: SKTexture(imageNamed: "ic_shuriken"),
                                     selectedTexture: SKTexture(imageNamed: "ic_shuriken"),
                                     disabledTexture: nil)
        shuriken1Button.setupWithNode(node: selectShuriken1Placeholder)
        shuriken1Button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(onShurikenTap(sender:)))
        shuriken1Button.zPosition = 2

        shuriken2Button = ButtonNode(normalTexture: SKTexture(imageNamed: "ic_shuriken2"),
                                     selectedTexture: SKTexture(imageNamed: "ic_shuriken2"),
                                     disabledTexture: nil)
        shuriken2Button.setupWithNode(node: selectShuriken2Placeholder)
        shuriken2Button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(onShurikenTap(sender:)))
        shuriken2Button.zPosition = 2

        shuriken3Button = ButtonNode(normalTexture: SKTexture(imageNamed: "ic_shuriken3"),
                                     selectedTexture: SKTexture(imageNamed: "ic_shuriken3"),
                                     disabledTexture: nil)
        shuriken3Button.setupWithNode(node: selectShuriken3Placeholder)
        shuriken3Button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(onShurikenTap(sender:)))
        shuriken3Button.zPosition = 2

        adsCell = adsPlaceholder
        adsCell.setupWithText(labelText: "Enable ads")
        adsCell.switchDelegate = self
        adsCell.setSwitch(isOn: Global.sharedInstance.adsEnabled)
        
        addChild(menuButton)
        addChild(shuriken1Button)
        addChild(shuriken2Button)
        addChild(shuriken3Button)
    }
    
    @objc func onMenuTap() {
        let reveal = SKTransition.flipHorizontal(withDuration: 1)
        if let scene = MainMenu(fileNamed: "MainMenu") {
            scene.initialize()
            
            self.view?.presentScene(scene, transition: reveal)
        }
    }
    
    func onSoundTap(isOn: Bool) {
        Global.sharedInstance.isSoundOn = isOn
    }
    
    func onAdsTap(isOn: Bool) {
        isOn ? AdsManager.sharedInstance.showAds() : AdsManager.sharedInstance.removeAds()
    }
    
    @objc func onShurikenTap(sender: ButtonNode){
        if sender == self.shuriken1Button {
            Global.sharedInstance.selectedPlayerShuriken = "ic_shuriken"
        } else if sender == self.shuriken2Button{
            Global.sharedInstance.selectedPlayerShuriken = "ic_shuriken2"
        } else if sender == self.shuriken3Button{
            Global.sharedInstance.selectedPlayerShuriken = "ic_shuriken3"
        }
    }
    
    func onSwitchTap(isOn: Bool, sender: SKNode) {
        if sender == soundCell {
            onSoundTap(isOn: isOn)
        } else if sender == adsCell {
            onAdsTap(isOn: isOn)
        }
    }
}
