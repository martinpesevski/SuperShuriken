//
//  MonsterManager.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 10/20/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit
import SpriteKit

class MonsterManager: NSObject {
    static let sharedInstance = MonsterManager()
    
    var monsterSpawner = SKSpriteNode()
    var monsterGoal = MonsterGoalNode()
    
    var monstersArray = [MonsterNode]()

    let gameManager = GameManager.sharedInstance
    
    func addMonsterToScene(scene: GameScene) {
        
        var monster = MonsterNode()
        let actualY = random(min: monsterSpawner.frame.origin.y + monster.size.height/2,
                             max: (monsterSpawner.frame.origin.y + horizonVerticalLocation) - monster.size.height/2)
        
        let type : MonsterType
        if gameManager.isBossLevel {
            type = MonsterType.boss
            monster = BossNode()
            (monster as! BossNode).setupRandom()
        } else {
            type = MonsterType(rawValue: 1 + Int(arc4random_uniform(UInt32(MonsterType.count)))) ?? MonsterType.basicMob
        }
        
        monster.setup(startPoint: CGPoint(x: scene.size.width + monster.size.width/2, y: actualY), type: type)
        monster.monsterDelegate = scene
        
        scene.addChild(monster)
        monstersArray.append(monster)
        gameManager.isBossLevel ? (monster as! BossNode).playBossAnimation() : monster.playRunAnimation()
    }
}
