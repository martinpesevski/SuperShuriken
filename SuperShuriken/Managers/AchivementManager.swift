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
        let achievement = Achievement(achievement: GKAchievement(type: .ninjaNovice, percent: 100), details: nil)
        reportAchievement(achievement)
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
        guard let achievement = achievement.achievement else { return }
        
        GKAchievement.report([achievement]) { error in
            if let error = error { print("achievement error" + error.localizedDescription) }
        }
    }
    
    func resetAchievements() {
        GKAchievement.resetAchievements { error in
            if let error = error?.localizedDescription { print(error) }
        }
    }
}
