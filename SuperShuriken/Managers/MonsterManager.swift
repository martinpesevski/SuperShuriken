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
    var barbarianRunningFrames : [SKTexture]
    var barbarianDyingFrames : [SKTexture]
    var meleeOgreRunningFrames : [SKTexture]
    var meleeOgreDyingFrames : [SKTexture]
    var minionShieldedArmoredRunningFrames : [SKTexture]
    var minionShieldedArmoredDyingFrames : [SKTexture]
    var vampireBossWalkingFrames : [SKTexture]
    var vampireBossRunningFrames : [SKTexture]
    var vampireBossRunShootingFrames : [SKTexture]
    var vampireBossDeathFrames : [SKTexture]

    let gameManager = GameManager.sharedInstance
    
    override init() {
        barbarianRunningFrames = createAtlas(name: "barbarian_running")
        barbarianDyingFrames = createAtlas(name: "barbarian_duying")
        meleeOgreRunningFrames = createAtlas(name: "Melee_Ogre_Running")
        meleeOgreDyingFrames = createAtlas(name: "melee_ogre_dying")
        minionShieldedArmoredRunningFrames = createAtlas(name: "minion_shielded_armored_running")
        minionShieldedArmoredDyingFrames = createAtlas(name: "minion_shielded_armored_dying")
        vampireBossWalkingFrames = createAtlas(name: "vampire_boss_walking")
        vampireBossRunningFrames = createAtlas(name: "vampire_boss_running")
        vampireBossRunShootingFrames = createAtlas(name: "vampire_boss_run_shooting")
        vampireBossDeathFrames = createAtlas(name: "vampire_boss_death")
    }
    
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
    
    static func getScaleFactor(monsterType: MonsterType) -> CGFloat {
        let scaleFactor : CGFloat
        switch monsterType {
        case .basicMob:
            scaleFactor = 2
        case .bigMob:
            scaleFactor = 3
        case.meleeMob:
            scaleFactor = 2
        case .boss:
            scaleFactor = 5
        }
        
        return scaleFactor
    }
    
    static func getNumberOfHits(monsterType: MonsterType) -> Int {
        let numberOfHits : Int
        switch monsterType {
        case .basicMob:
            numberOfHits = 1
        case .bigMob:
            numberOfHits = 2
        case .meleeMob:
            numberOfHits = 1
        case .boss:
            numberOfHits = 5
        }
        
        return numberOfHits
    }
    
    static func getWeaknesses(monsterType: MonsterType) -> [AttackType] {
        var weaknessesArray : [AttackType] = [];
        switch monsterType {
        case .basicMob:
            weaknessesArray = [.Melee, .Projectile]
        case .bigMob:
            weaknessesArray = [.Projectile]
        case .meleeMob:
            weaknessesArray = [.Melee]
        case .boss:
            weaknessesArray = [.Projectile]
        }
        
        return weaknessesArray
    }
    
    static func getSpeed(monsterType: MonsterType) -> CGFloat {
        switch monsterType {
        case .basicMob:
            return basicMobSpeed
        case .bigMob:
            return bigMobSpeed
        case .meleeMob:
            return meleeMobSpeed
        case .boss:
            return 0
        }
    }
    
    static func getRunAnimationTextures(monsterType: MonsterType) -> [SKTexture] {
        let monsterManager = MonsterManager.sharedInstance
        switch monsterType {
        case .basicMob:
            return monsterManager.barbarianRunningFrames
        case .bigMob:
            return monsterManager.meleeOgreRunningFrames
        case .meleeMob:
            return monsterManager.minionShieldedArmoredRunningFrames
        case .boss:
            return MonsterManager.getBossRunAnimationTextures(monsterType: .vampire)
        }
    }
    
    static func getDeathAnimationTextures(monsterType: MonsterType) -> [SKTexture] {
        let monsterManager = MonsterManager.sharedInstance
        switch monsterType {
        case .basicMob:
            return monsterManager.barbarianDyingFrames
        case .bigMob:
            return monsterManager.meleeOgreDyingFrames
        case .meleeMob:
            return monsterManager.minionShieldedArmoredDyingFrames
        case .boss:
            return monsterManager.vampireBossDeathFrames
        }
    }
    
    static func getBossDeathAnimationTextures(bossType: BossType) -> [SKTexture] {
        let monsterManager = MonsterManager.sharedInstance
        switch bossType {
        case .vampire:
            return monsterManager.vampireBossDeathFrames
        }
    }
    
    static func getBossWalkAnimationTextures(monsterType: BossType) -> [SKTexture] {
        let monsterManager = MonsterManager.sharedInstance
        switch monsterType {
        case .vampire:
            return monsterManager.vampireBossWalkingFrames
        }
    }
    
    static func getBossRunAnimationTextures(monsterType: BossType) -> [SKTexture] {
        let monsterManager = MonsterManager.sharedInstance
        switch monsterType {
        case .vampire:
            return monsterManager.vampireBossRunningFrames
        }
    }
    
    static func getBossRunShootAnimationTextures(monsterType: BossType) -> [SKTexture] {
        let monsterManager = MonsterManager.sharedInstance
        switch monsterType {
        case .vampire:
            return monsterManager.vampireBossRunShootingFrames
        }
    }
}
