//
//  Achievement.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/29/19.
//  Copyright © 2019 MP. All rights reserved.
//

import Foundation
import GameKit

struct Achievement {
    enum AchievementType {
        case ninjaApprentice
        case ninjaNovice
        case bossKiller
    }
    
    var achievement: GKAchievement?
    var details: GKAchievementDescription?
}
