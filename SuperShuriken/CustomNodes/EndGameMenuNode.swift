//
//  EndGameMenuNode.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 3/30/19.
//  Copyright © 2019 MP. All rights reserved.
//

import SpriteKit

protocol EndGameDelegate: class {
    func onRetry()
    func onMenu()
}

class EndGameMenuNode: SKSpriteNode {
    private let menuButton: ButtonNode
    private let retryButton: ButtonNode
    weak var delegate: EndGameDelegate?
    
    init() {
        menuButton = ButtonNode(normalTexture: SKTexture(imageNamed: "ic_button"), selectedTexture: SKTexture(imageNamed: "ic_button_clicked"), disabledTexture: nil)
        
        retryButton = ButtonNode(normalTexture: SKTexture(imageNamed: "ic_button"), selectedTexture: SKTexture(imageNamed: "ic_button_clicked"), disabledTexture: nil)

        super.init(texture: nil, color: .blue, size: CGSize(width: 700, height: 700))
        
        menuButton.size = CGSize(width: 300, height: 100)
        menuButton.position = CGPoint(x: -menuButton.size.width/2 - 20, y: -size.height/2 + menuButton.size.height)
        menuButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(onMenuTap))
        menuButton.setButtonLabel(title: "menu", font: "Chalkduster", fontSize: 20)
        
        retryButton.size = CGSize(width: 300, height: 100)
        retryButton.position = CGPoint(x: menuButton.size.width/2 + 20, y: -size.height/2 +  retryButton.size.height)
        retryButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(onRetryTap))
        retryButton.setButtonLabel(title: "retry", font: "Chalkduster", fontSize: 20)
        
        zPosition = 2
        
        addChild(menuButton)
        addChild(retryButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onMenuTap() {
        delegate?.onMenu()
    }
    
    @objc func onRetryTap() {
        delegate?.onRetry()
    }
    
}
