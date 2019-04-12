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

let enemyLevelMultiplier = 2//increment in number of enemies for each level
let bossLevelMultiplier = 2//how many levels does it take to encounter a boss

extension Notification.Name {
    static let gameOver = Notification.Name("GameOverNotification")
    static let levelFinished = Notification.Name("levelFinished")
    static let gameStarted = Notification.Name("GameStartedNotification")
    static let newLevelStarted = Notification.Name("NewLevelStartedNotification")
}

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
        
        NotificationCenter.default.post(Notification(name: Notification.Name.gameStarted))
    }

    func updateScore(value: Int) {
        score += value
        monstersForCurrentLevel += 1
        if monstersForCurrentLevel == numberOfMonstersForCurrentLevel() {
            loadNextLevel()
        }
    }
    
    func loadNextLevel() {
        level += 1
        isBossLevel = level % bossLevelMultiplier == 0 
        monstersForCurrentLevel = 0
        NotificationCenter.default.post(name: Notification.Name.levelFinished, object: nil, userInfo: ["isBossLevelNext": self.isBossLevel])

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            NotificationCenter.default.post(name: Notification.Name.newLevelStarted, object: nil, userInfo: ["isBossLevel": self.isBossLevel])
        }
    }
    
    func endGame() {
        isGameFinished = true
        
        NotificationCenter.default.post(Notification(name: Notification.Name.gameOver))
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
