//
//  LabelWithSwitchNode.swift
//  SuperShuriken
//
//  Created by Martin.Pesevski on 1/18/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit

protocol switchNodeDelegate {
    func onSwitchTap(isOn: Bool, sender: SKNode)
}

class LabelWithSwitchNode: SKSpriteNode {
    var switchNode : ButtonNode!
    var labelNode: SKLabelNode!
    
    var switchDelegate : switchNodeDelegate?
    
    var switchIsOn: Bool = true
    
    func setupWithText(labelText: String){
        
        switchNode = ButtonNode.init(normalTexture: SKTexture(imageNamed: "ic_button"), selectedTexture: SKTexture(imageNamed: "ic_buttonClicked"), disabledTexture: nil)
        switchNode.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(onSwitchTap))
        switchNode.setButtonLabel(title: switchIsOn ? "ON" : "OFF", font: "Chalkduster", fontSize: 30)
        switchNode.size = CGSize.init(width: 100, height: switchNode.size.height)
        switchNode.position = CGPoint(x: self.frame.maxX - switchNode.size.width/2, y: self.frame.midY - self.position.y)
        switchNode.zPosition = 2
        
        labelNode = SKLabelNode.init(text: labelText)
        labelNode.fontColor = UIColor.white
        labelNode.fontName = "Chalkduster"
        labelNode.fontSize = 30
        labelNode.position = CGPoint(x: self.frame.minX + labelNode.frame.size.width, y: switchNode.frame.midY)
        labelNode.zPosition = 2
        labelNode.horizontalAlignmentMode = .right
        
        addChild(labelNode)
        addChild(switchNode)
    }
    
    @objc func onSwitchTap() {
        setSwitch(isOn: !switchIsOn)
        switchDelegate?.onSwitchTap(isOn: switchIsOn, sender: self)
    }
    
    func setSwitch(isOn: Bool) {
        switchIsOn = isOn
        switchNode.label.text = isOn ? "ON" : "OFF"
    }
}
