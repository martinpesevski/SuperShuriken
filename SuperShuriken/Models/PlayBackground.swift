//
//  PlayBackground.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 3/30/19.
//  Copyright © 2019 MP. All rights reserved.
//

import SpriteKit

class PlayBackground: SKSpriteNode {
    private let groundNodes: [SKSpriteNode]
    private let skyNode: SKSpriteNode
    private var scrollAction = SKAction()
    
    init() {
        skyNode = SKSpriteNode(color: .blue, size: CGSize(width: 1920, height: 280))
        groundNodes = [SKSpriteNode(imageNamed: "grass"),
                       SKSpriteNode(imageNamed: "grass"),
                       SKSpriteNode(imageNamed: "grass")]
        
        super.init(texture: nil, color: .red, size: CGSize(width: 1920, height: 1080))
        
        anchorPoint = CGPoint(x: 0, y: 0)
        zPosition = -2
        
        skyNode.anchorPoint = CGPoint(x: 0, y: 0)
        skyNode.position = CGPoint(x: 0, y: 800)
        
        createActions()
        createScrollableBackground(nodes: groundNodes, yPosition: 0)
        startScrollingPlatform()
        addChild(skyNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createScrollableBackground(nodes: [SKSpriteNode], yPosition: CGFloat) {
        for (index, node) in nodes.enumerated() {
            node.anchorPoint = CGPoint.zero
            node.position = CGPoint(x: (node.size.width * CGFloat(index)), y: yPosition)
            addChild(node)
        }
    }
    
    private func createActions() {
        let moveLeft = SKAction.moveBy(x: -groundNodes[0].size.width, y: 0, duration: 15)
        let moveReset = SKAction.moveBy(x: groundNodes[0].size.width, y: 0, duration: 0)
        let moveLoop = SKAction.sequence([moveLeft, moveReset])
        scrollAction = SKAction.repeatForever(moveLoop)
    }
    
    func startScrollingPlatform() {
        for background in groundNodes {
            if background.position.x + background.size.width < 0 {
                background.position = CGPoint(x: background.position.x + background.size.width * CGFloat(groundNodes.count), y: background.position.y)
            }
            
            background.run(scrollAction, withKey: "scroll")
        }
    }
    
    func stopScrolling() {
        for background in groundNodes {
            background.removeAction(forKey: "scroll")
        }
    }
}
