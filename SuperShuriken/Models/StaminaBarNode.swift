//
//  StaminaBarNode.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 2/10/19.
//  Copyright © 2019 MP. All rights reserved.
//

import SpriteKit

class StaminaBarNode: SKSpriteNode {
    var isExhausted = false
    private var staminaBar = SKSpriteNode()
    private var stamina = 10.0

    func setupStaminaBar() {
        stamina = 10.0
        isExhausted = false
        staminaBar = SKSpriteNode(color: .green, size:
            CGSize(width: size.width - 20, height: size.height - 20))
        staminaBar.anchorPoint = CGPoint(x: 0, y: 0)
        staminaBar.position = CGPoint(x: -size.width/2 + 10, y: -size.height/2 + 10)
        addChild(staminaBar)
        increaseStamina()
    }
    
    func didShoot() {
        if stamina <= 0 {
            return
        }
        
        stamina -= 1
        if stamina < 0 {
            stamina = 0
            handleExhausted()
        }
        staminaBar.xScale = CGFloat(stamina/10.0)
    }
    
    func increaseStamina(){
        let increaseStaminaGradually = SKAction.run { [unowned self] in
            if self.stamina >= 10 {return}
            self.stamina += 0.1
            if self.stamina > 10 {self.stamina = 10}
            self.staminaBar.xScale = CGFloat(self.stamina/10.0)
        }
        
        run(SKAction.repeatForever(SKAction.sequence([increaseStaminaGradually, SKAction.wait(forDuration: 0.03)])),
            withKey: "increaseStaminaAction")
    }
    
    func handleExhausted(){
        isExhausted = true
        removeAction(forKey: "increaseStaminaAction")
        run(SKAction.wait(forDuration: 1.5)) { [unowned self] in
            self.isExhausted = false
            self.increaseStamina()
        }
    }
}
