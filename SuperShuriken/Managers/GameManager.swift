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

let startSpeed : (min:CGFloat, max:CGFloat) = (5.0, 7.0)
let enemyLevelMultiplier = 5
let bossLevelMultiplier = 2

class GameManager: NSObject {
    
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
    
    func monsterTimeToCrossScreen() -> CGFloat {
        return random(min: startSpeed.min * speedUpFactor(), max: startSpeed.max * speedUpFactor())
    }
    
    func numberOfMonstersForCurrentLevel() -> Int {
        if level % bossLevelMultiplier == 0 {
            return 1
        } else {
            return level  * enemyLevelMultiplier
        }
    }
    
    func speedUpFactor() -> CGFloat {
        return level - 1 >= 10 ? 0.1 : CGFloat((10.0 - Double(level - 1)) / 10.0)
    }
    
    func createNextLevelText() -> SKLabelNode {
        let nextLevelTextNode = SKLabelNode(text: "Level \(level)")
        nextLevelTextNode.fontName = "Chalkduster"
        nextLevelTextNode.fontSize = 80;
        nextLevelTextNode.color = UIColor.white
        nextLevelTextNode.zPosition = 5
        return nextLevelTextNode
    }
    
    func createGameOverText() -> SKLabelNode {
        let gameOverTextNode = SKLabelNode(text: "YOU LOST :(")
        gameOverTextNode.fontName = "Chalkduster"
        gameOverTextNode.fontSize = 80;
        gameOverTextNode.color = UIColor.white
        gameOverTextNode.zPosition = 5
        return gameOverTextNode
    }
}
