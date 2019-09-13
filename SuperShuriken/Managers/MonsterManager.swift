//
//  MonsterManager.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 10/20/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit
import SpriteKit

class MonsterManager: NSObject, Application {
    var app: App { return App.shared }
    
    static let shared = MonsterManager()
    
    var monsterSpawner = SKSpriteNode()
    var monsterGoal = MonsterGoalNode()
    
    var monstersArray = [MonsterNode]()

    func addMonsterToScene(scene: GameScene) {
        var monster = MonsterNode()
        let actualY = random(min: 100,
                             max: horizonVerticalLocation - monster.size.height/2)
        monster.zPosition = horizonVerticalLocation/actualY
        let type : MonsterType
        if app.gameManager.isBossLevel {
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
        app.gameManager.isBossLevel ? (monster as! BossNode).playBossAnimation() : monster.playRunAnimation()
    }
    
    func getRunAnimationTextures(monsterType: MonsterType) -> [SKTexture] {
        switch monsterType {
        case .basicMob:
            return app.animationManager.barbarianRunningFrames
        case .bigMob:
            return app.animationManager.meleeOgreRunningFrames
        case .meleeMob:
            return app.animationManager.minionShieldedArmoredRunningFrames
        case .boss:
            return getBossRunAnimationTextures(monsterType: .vampire)
        }
    }
    
    func getDeathAnimationTextures(monsterType: MonsterType) -> [SKTexture] {
        switch monsterType {
        case .basicMob:
            return app.animationManager.barbarianDyingFrames
        case .bigMob:
            return app.animationManager.meleeOgreDyingFrames
        case .meleeMob:
            return app.animationManager.minionShieldedArmoredDyingFrames
        case .boss:
            return app.animationManager.vampireBossDeathFrames
        }
    }
    
    func getBossDeathAnimationTextures(bossType: BossType) -> [SKTexture] {
        switch bossType {
        case .vampire:
            return app.animationManager.vampireBossDeathFrames
        }
    }
    
    func getBossWalkAnimationTextures(monsterType: BossType) -> [SKTexture] {
        switch monsterType {
        case .vampire:
            return app.animationManager.vampireBossWalkingFrames
        }
    }
    
    func getBossRunAnimationTextures(monsterType: BossType) -> [SKTexture] {
        switch monsterType {
        case .vampire:
            return app.animationManager.vampireBossRunningFrames
        }
    }
    
    func getBossRunShootAnimationTextures(monsterType: BossType) -> [SKTexture] {
        switch monsterType {
        case .vampire:
            return app.animationManager.vampireBossRunShootingFrames
        }
    }
}
