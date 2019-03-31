//
//  PlayBackground.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 3/30/19.
//  Copyright © 2019 MP. All rights reserved.
//

import SpriteKit

enum ScrollNodeType {
    case paralaxFront
    case paralaxMiddle
    case paralaxBack
    case ground
    
    var nodes: [SKSpriteNode] {
        switch self {
        case .ground:
            return [SKSpriteNode(imageNamed: "grass"),
                    SKSpriteNode(imageNamed: "grass"),
                    SKSpriteNode(imageNamed: "grass")]
        case .paralaxFront:
            return [SKSpriteNode(imageNamed: "trees-front"),
             SKSpriteNode(imageNamed: "trees-front"),
             SKSpriteNode(imageNamed: "trees-front"),
             SKSpriteNode(imageNamed: "trees-front")]
        case .paralaxMiddle:
            return [SKSpriteNode(imageNamed: "trees-middle"),
                    SKSpriteNode(imageNamed: "trees-middle"),
                    SKSpriteNode(imageNamed: "trees-middle"),
                    SKSpriteNode(imageNamed: "trees-middle")]
        case .paralaxBack:
            return [SKSpriteNode(imageNamed: "trees-back"),
                    SKSpriteNode(imageNamed: "trees-back"),
                    SKSpriteNode(imageNamed: "trees-back"),
                    SKSpriteNode(imageNamed: "trees-back")]
        }
    }
    
    var yPosition: CGFloat {
        switch self {
        case .ground:
            return 0
        case .paralaxMiddle:
            return 830
        case .paralaxFront:
            return 800
        case .paralaxBack:
            return 800
        }
    }
    
    var zIndex: CGFloat {
        switch self {
        case .ground:
            return 0
        case .paralaxFront:
            return 0
        case .paralaxMiddle:
            return -0.5
        case .paralaxBack:
            return -1
        }
    }
    
    var scrollAction: SKAction {
        var duration = 0.0
        switch self {
        case .ground:
            duration = 15
        case .paralaxFront:
            duration = 10
        case .paralaxMiddle:
            duration = 13
        case .paralaxBack:
            duration = 17
        }
        
        let moveLeft = SKAction.moveBy(x: -nodes[0].size.width, y: 0, duration: duration)
        let moveReset = SKAction.moveBy(x: nodes[0].size.width, y: 0, duration: 0)
        let moveLoop = SKAction.sequence([moveLeft, moveReset])
        return SKAction.repeatForever(moveLoop)
    }
}

class PlayBackground: SKSpriteNode {
    let skyNode = SKSpriteNode(imageNamed: "sky-background")
    
    let groundNodes = ScrollNodeType.ground.nodes
    let paralaxFrontNodes = ScrollNodeType.paralaxFront.nodes
    let paralaxMiddleNodes = ScrollNodeType.paralaxMiddle.nodes
    let paralaxBackNodes = ScrollNodeType.paralaxBack.nodes

    let groundScrollAction = ScrollNodeType.ground.scrollAction
    let paralaxFrontScrollAction = ScrollNodeType.paralaxFront.scrollAction
    let paralaxMiddleScrollAction = ScrollNodeType.paralaxMiddle.scrollAction
    let paralaxBackScrollAction = ScrollNodeType.paralaxBack.scrollAction

    init() {
        super.init(texture: nil, color: .clear, size: CGSize(width: 1920, height: 1080))
        
        anchorPoint = CGPoint(x: 0, y: 0)
        zPosition = -2
        skyNode.anchorPoint = CGPoint(x: 0, y: 1)
        skyNode.position = CGPoint(x: 0, y: size.height)
        skyNode.zPosition = -2
        addChild(skyNode)
        
        positionNodes(groundNodes,
                      yPosition: ScrollNodeType.ground.yPosition,
                      zIndex: ScrollNodeType.ground.zIndex)
        positionNodes(paralaxFrontNodes,
                      yPosition: ScrollNodeType.paralaxFront.yPosition,
                      zIndex: ScrollNodeType.paralaxFront.zIndex)
        positionNodes(paralaxMiddleNodes,
                      yPosition: ScrollNodeType.paralaxMiddle.yPosition,
                      zIndex: ScrollNodeType.paralaxMiddle.zIndex)
        positionNodes(paralaxBackNodes, yPosition: ScrollNodeType.paralaxBack.yPosition,
                      zIndex: ScrollNodeType.paralaxBack.zIndex)
        startScrolling()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func positionNodes(_ nodes: [SKSpriteNode], yPosition: CGFloat, zIndex: CGFloat) {
        for (index, node) in nodes.enumerated() {
            node.anchorPoint = CGPoint.zero
            node.position = CGPoint(x: (node.size.width * CGFloat(index)) - CGFloat(index), y: yPosition)
            node.zPosition = zIndex
            addChild(node)
        }
    }
    
    func startScrolling () {
        startScrolling(groundNodes, action: groundScrollAction)
        startScrolling(paralaxFrontNodes, action: paralaxFrontScrollAction)
        startScrolling(paralaxMiddleNodes, action: paralaxMiddleScrollAction)
        startScrolling(paralaxBackNodes, action: paralaxBackScrollAction)
    }
    
    func stopScrolling () {
        stopScrolling(groundNodes)
        stopScrolling(paralaxFrontNodes)
        stopScrolling(paralaxMiddleNodes)
        stopScrolling(paralaxBackNodes)
    }
    
    private func startScrolling(_ nodes: [SKSpriteNode], action: SKAction) {
        for node in nodes {
            if node.position.x + node.size.width < 0 {
                node.position = CGPoint(x: node.position.x + node.size.width * CGFloat(nodes.count), y: node.position.y)
            }
            
            node.run(action, withKey: "scroll")
        }
    }
    
    func stopScrolling(_ nodes: [SKSpriteNode]) {
        for background in nodes {
            background.removeAction(forKey: "scroll")
        }
    }
}
