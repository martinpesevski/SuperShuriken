//
//  GameManager.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 3/5/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit
import SpriteKit

protocol GameManagerDelegate {
    func levelFinished()
}

let enemyLevelMultiplier = 5//increment in number of enemies for each level
let bossLevelMultiplier = 1//how many levels does it take to encounter a boss

class GameManager: NSObject {
    static let sharedInstance = GameManager()
    
    var delegate : GameManagerDelegate?
    var monstersForCurrentLevel = 0
    var score = 0
    var level = 1
    var isBossLevel = false
    var isGameFinished = false

    func restart() {
        score = 0
        level = 1
        monstersForCurrentLevel = 0
        isBossLevel = false
        isGameFinished = false
    }

    func updateScore(value: Int) {
        score += value
        monstersForCurrentLevel += 1
        if monstersForCurrentLevel == numberOfMonstersForCurrentLevel() {
            delegate?.levelFinished()
        }
    }
    
    func loadNextLevel() {
        level += 1
        isBossLevel = level % bossLevelMultiplier == 0 
        monstersForCurrentLevel = 0
    }
    
    func numberOfMonstersForCurrentLevel() -> Int {
        if level % bossLevelMultiplier == 0 {
            return 1
        } else {
            return level  * enemyLevelMultiplier
        }
    }
    
    func speedUpFactor() -> CGFloat {
        return level > 10 ? 3 : CGFloat(level / 5 + 1)
    }
    
    func createLabel(text: String, size: CGFloat) -> SKLabelNode {
        let nextLevelTextNode = SKLabelNode(text: text)
        nextLevelTextNode.fontName = "Chalkduster"
        nextLevelTextNode.fontSize = size;
        nextLevelTextNode.color = UIColor.white
        nextLevelTextNode.zPosition = 5
        return nextLevelTextNode
    }
}
