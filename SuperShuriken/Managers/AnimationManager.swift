//
//  AnimationManager.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 3/30/19.
//  Copyright © 2019 MP. All rights reserved.
//

import Foundation
import SpriteKit

class AnimationManager: NSObject {
    static let sharedInstance = AnimationManager()

    var barbarianRunningFrames : [SKTexture] = []
    var barbarianDyingFrames : [SKTexture] = []
    var meleeOgreRunningFrames : [SKTexture] = []
    var meleeOgreDyingFrames : [SKTexture] = []
    var minionShieldedArmoredRunningFrames : [SKTexture] = []
    var minionShieldedArmoredDyingFrames : [SKTexture] = []
    var vampireBossWalkingFrames : [SKTexture] = []
    var vampireBossRunningFrames : [SKTexture] = []
    var vampireBossRunShootingFrames : [SKTexture] = []
    var vampireBossDeathFrames : [SKTexture] = []
    var bloodSplatterTextures : [SKTexture] = []
    
    var playerWalkingFrames: [SKTexture] = []
    var playerShootingFrames: [SKTexture] = []
    var playerRunShootFrames: [SKTexture] = []
    var playerDeathFrames: [SKTexture] = []
    var playerIdleFrames: [SKTexture] = []
    var playerRunSlashFrames: [SKTexture] = []
    
    override init() {
        super.init()
        
        createAtlas(name: "barbarian_running") { [unowned self] textures in
            self.barbarianRunningFrames = textures
        }
        createAtlas(name: "barbarian_duying") { [unowned self] textures in
            self.barbarianDyingFrames = textures
        }
        createAtlas(name: "Melee_Ogre_Running") { [unowned self] textures in
            self.meleeOgreRunningFrames = textures
        }
        createAtlas(name: "melee_ogre_dying") { [unowned self] textures in
            self.meleeOgreDyingFrames = textures
        }
        createAtlas(name: "minion_shielded_armored_running") { [unowned self] textures in
            self.minionShieldedArmoredRunningFrames = textures
        }
        createAtlas(name: "minion_shielded_armored_dying") { [unowned self] textures in
            self.minionShieldedArmoredDyingFrames = textures
        }
        createAtlas(name: "vampire_boss_walking") { [unowned self] textures in
            self.vampireBossWalkingFrames = textures
        }
        createAtlas(name: "vampire_boss_running") { [unowned self] textures in
            self.vampireBossRunningFrames = textures
        }
        createAtlas(name: "vampire_boss_run_shooting") { [unowned self] textures in
            self.vampireBossRunShootingFrames = textures
        }
        createAtlas(name: "vampire_boss_death") { [unowned self] textures in
            self.vampireBossDeathFrames = textures
        }
        createAtlas(name: "bloodSplatter") { [unowned self] textures in
            self.bloodSplatterTextures = textures
        }
        createAtlas(name: "Run_Throwing") { [unowned self] textures in
            self.playerRunShootFrames = textures
        }
        createAtlas(name: "Run_Slashing") { [unowned self] textures in
            self.playerRunSlashFrames = textures
        }
        createAtlas(name: "Running") { [unowned self] textures in
            self.playerWalkingFrames = textures
        }
        createAtlas(name: "Dying") { [unowned self] textures in
            self.playerDeathFrames = textures
        }
        createAtlas(name: "Throwing") { [unowned self] textures in
            self.playerShootingFrames = textures
        }
        createAtlas(name: "Idle") { [unowned self] textures in
            self.playerIdleFrames = textures
        }
    }
}
