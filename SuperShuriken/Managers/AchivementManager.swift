//
//  AchivementManager.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 9/10/19.
//  Copyright © 2019 MP. All rights reserved.
//

import Foundation
import GameKit

class AchievementManager {
    static let shared = AchievementManager()

    func didKillMonster(type: MonsterType) {
        let achievement = GKAchievement(type: .ninjaNovice, percent: 100)
        GameCenterManager.shared.reportAchievement(Achievement(achievement: achievement, details: nil))
    }
}
