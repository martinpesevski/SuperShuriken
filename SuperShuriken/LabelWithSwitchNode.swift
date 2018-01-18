//
//  LabelWithSwitchNode.swift
//  SuperShuriken
//
//  Created by Martin.Pesevski on 1/18/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit

protocol switchNodeDelegate {
    func onSwitchTap(isOn: Bool)
}

class LabelWithSwitchNode: SKSpriteNode {
    var switchNode : ButtonNode!
    var labelNode: SKLabelNode!
    
    var switchDelegate : switchNodeDelegate?
    
    var switchIsOn: Bool = true
    
    func setupWithText(labelText: String){
        switchNode = ButtonNode.init(normalTexture: SKTexture(imageNamed: "button"), selectedTexture: SKTexture(imageNamed: "buttonClicked"), disabledTexture: nil)
        switchNode.setButtonAction(target: self, triggerEvent: .TouchUp, action: #selector(onSwitchTap))
        switchNode.setButtonLabel(title: "ON", font: "Chalkduster", fontSize: 30)
        switchNode.size = CGSize.init(width: 100, height: switchNode.size.height)
        
        switchNode.constraints = [SKConstraint.distance(SKRange.init(constantValue: 20), to: CGPoint.init(x: self.frame.maxX, y: self.frame.midY))]
        
        labelNode = SKLabelNode.init(text: labelText)
        labelNode.fontColor = UIColor.white
        labelNode.fontName = "Chalkduster"
        labelNode.fontSize = 30
        labelNode.constraints = [SKConstraint.distance(SKRange.init(constantValue: -20), to: CGPoint.init(x: switchNode.frame.minX, y: switchNode.frame.midY)),
                                 SKConstraint.distance(SKRange.init(constantValue: 20), to: CGPoint.init(x: self.frame.minX, y: self.frame.midY))]
        
        addChild(labelNode)
        addChild(switchNode)
    }
    
    @objc func onSwitchTap() {
        switchIsOn = !switchIsOn
        switchDelegate?.onSwitchTap(isOn: switchIsOn)
    }
}
