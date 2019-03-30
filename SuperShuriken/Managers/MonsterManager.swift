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
    let animationManager = AnimationManager.sharedInstance

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
            type = MonsterType.random()
        }
        
        monster.setup(startPoint: CGPoint(x: scene.size.width + monster.size.width/2, y: actualY), type: type)
        monster.monsterDelegate = scene
        
        scene.addChild(monster)
        monstersArray.append(monster)
        gameManager.isBossLevel ? (monster as! BossNode).playBossAnimation() : monster.playRunAnimation()
    }
    
    func getRunAnimationTextures(monsterType: MonsterType) -> [SKTexture] {
        switch monsterType {
        case .basicMob:
            return animationManager.barbarianRunningFrames
        case .bigMob:
            return animationManager.meleeOgreRunningFrames
        case .meleeMob:
            return animationManager.minionShieldedArmoredRunningFrames
        case .boss:
            return getBossRunAnimationTextures(monsterType: .vampire)
        }
    }
    
    func getDeathAnimationTextures(monsterType: MonsterType) -> [SKTexture] {
        switch monsterType {
        case .basicMob:
            return animationManager.barbarianDyingFrames
        case .bigMob:
            return animationManager.meleeOgreDyingFrames
        case .meleeMob:
            return animationManager.minionShieldedArmoredDyingFrames
        case .boss:
            return animationManager.vampireBossDeathFrames
        }
    }
    
    func getBossDeathAnimationTextures(bossType: BossType) -> [SKTexture] {
        switch bossType {
        case .vampire:
            return animationManager.vampireBossDeathFrames
        }
    }
    
    func getBossWalkAnimationTextures(monsterType: BossType) -> [SKTexture] {
        switch monsterType {
        case .vampire:
            return animationManager.vampireBossWalkingFrames
        }
    }
    
    func getBossRunAnimationTextures(monsterType: BossType) -> [SKTexture] {
        switch monsterType {
        case .vampire:
            return animationManager.vampireBossRunningFrames
        }
    }
    
    func getBossRunShootAnimationTextures(monsterType: BossType) -> [SKTexture] {
        switch monsterType {
        case .vampire:
            return animationManager.vampireBossRunShootingFrames
        }
    }
}
