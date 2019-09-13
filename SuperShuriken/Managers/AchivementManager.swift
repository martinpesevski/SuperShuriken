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
    var achievements = [Achievement]()

    func didKillMonster(type: MonsterType) {
        if achievements.achievementOfType(.ninjaApprentice) == nil {
            let achievement = Achievement(achievement: GKAchievement(type: .ninjaApprentice, percent: 100), details: nil)
            reportAchievement(achievement)
        }
        if let novice = achievements.achievementOfType(.ninjaNovice), novice.achievement?.isCompleted == false {
            novice.achievement?.percentComplete += 2
            reportAchievement(novice)
        } else {
            let novice = Achievement(achievement: GKAchievement(type: .ninjaNovice, percent: 2), details: nil)
            reportAchievement(novice)
        }
    }
    
    func didKillBoss() {
        if achievements.achievementOfType(.bossKiller) == nil {
            let achievement = Achievement(achievement: GKAchievement(type: .bossKiller, percent: 100), details: nil)
            reportAchievement(achievement)
        }
    }
    
    func getAchievements(completion: (([Achievement]?, Error?) -> ())?) {
        
        GKAchievementDescription.loadAchievementDescriptions(completionHandler: { [weak self] (descriptions, error) in
            guard let self = self, let descriptions = descriptions else {
                completion?(nil, nil)
                return
            }
            
            self.achievements = [Achievement]()
            for index in 0 ..< descriptions.count {
                self.achievements.append(Achievement(achievement: nil, details: descriptions[index]))
            }
            
            GKAchievement.loadAchievements { [weak self] achievements, error in
                guard let self = self, let achievements = achievements else {
                    completion?(nil, nil)
                    return
                }
                
                for i in 0 ..< achievements.count {
                    for j in 0 ..< self.achievements.count {
                        if self.achievements[j].details?.identifier == achievements[i].identifier { self.achievements[j].achievement = achievements[i] }
                    }
                }
                
                completion?(self.achievements, error)
            }
        })
    }
    
    func reportAchievement(_ achievement: Achievement) {
        guard let gkAchievement = achievement.achievement else { return }
        achievements.append(achievement)
        
        GKAchievement.report([gkAchievement]) { error in
            if let error = error { print("achievement error" + error.localizedDescription) }
        }
    }
    
    func resetAchievements() {
        achievements.removeAll()
        GKAchievement.resetAchievements { error in
            if let error = error?.localizedDescription { print(error) }
        }
    }
}

extension Array where Element == Achievement {
    func achievementOfType(_ type: AchievementType) -> Achievement? {
        for achievement in self where achievement.achievement?.identifier == type.rawValue {
            return achievement
        }
        return nil
    }
}
