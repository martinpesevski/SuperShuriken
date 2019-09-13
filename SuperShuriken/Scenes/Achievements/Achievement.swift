//
//  Achievement.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/29/19.
//  Copyright © 2019 MP. All rights reserved.
//

import Foundation
import GameKit

enum AchievementType: String {
    case ninjaApprentice = "com.mpesevski.superShuriken.ninjaApprentice"
    case ninjaNovice = "com.mpesevski.superShuriken.ninjaNovice"
    case bossKiller = "com.mpesevski.superShuriken.bossKiller"
}

struct Achievement {
    var achievement: GKAchievement?
    var details: GKAchievementDescription?
}

extension GKAchievement {
    convenience init(type: AchievementType, percent: Double) {
        self.init(identifier: type.rawValue)
        percentComplete = percent
        showsCompletionBanner = true
    }
    
    var progressString: String {
        guard let identifier = identifier, let type = AchievementType(rawValue: identifier) else { return "" }
        switch type {
        case .ninjaNovice:
            return "\(Int(percentComplete / 2))/50"
        default:
            return "\(100 - (100 - percentComplete))/1"
        }
    }
}
