//
//  GameManager.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 3/5/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit

protocol GameManagerDelegate {
    func levelFinished()
}

let startSpeed : (min:CGFloat, max:CGFloat) = (5.0, 7.0)
let enemyLevelMultiplier = 5

class GameManager: NSObject {
    
    var delegate : GameManagerDelegate?
    var monstersForCurrentLevel = 0
    var score = 0
    var level = 1
    
    func restart() {
        score = 0
        level = 1
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
        monstersForCurrentLevel = 0
    }
    
    func monsterTimeToCrossScreen() -> CGFloat {
        return random(min: startSpeed.min * speedUpFactor(), max: startSpeed.max * speedUpFactor())
    }
    
    func numberOfMonstersForCurrentLevel() -> Int {
        return level  * enemyLevelMultiplier
    }
    
    func speedUpFactor() -> CGFloat {
        return level - 1 >= 10 ? 0.1 : CGFloat((10.0 - Double(level - 1)) / 10.0)
    }
}
