//
//  GameCenterManager.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/15/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import GameKit

class GameCenterManager: NSObject, GKGameCenterControllerDelegate {
    static let leaderboardId = "super-shuriken-leaderboard"

    static let shared = GameCenterManager()
    var defaultLeaderboard: String?
    let localPLayer = GKLocalPlayer.localPlayer()
    
    func isAuthenticated() -> Bool {
        return localPLayer.isAuthenticated
    }
    
    func authenticate(viewController: UIViewController?, completion: @escaping (Bool)->() = {_ in }){
        localPLayer.authenticateHandler = { [weak self] gcAuthVC, error in
            guard let self = self else {
                completion(false)
                return
            }
            
            if self.localPLayer.isAuthenticated {
                print("Authenticated to Game Center!")
                completion(true)
            } else if let vc = gcAuthVC {
                viewController?.present(vc, animated: true)
            }
            else {
                print("Error authentication to GameCenter: " +
                    "\(error?.localizedDescription ?? "none")")
                completion(false)
            }
        }
    }
    
    func submitScore(_ score: Int) {
        let newScore = GKScore(leaderboardIdentifier: GameCenterManager.leaderboardId)
        newScore.value = Int64(score)
        GKScore.report([newScore]) { error in
            guard error == nil else {
                print(error?.localizedDescription ?? "error getting score")
                return
            }
            
            print("Best Score submitted to your Leaderboard!")
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func getHighScores(completion: @escaping ([GKScore]?, Error?) -> ()) {
        let leaderBoardRequest = GKLeaderboard()
        leaderBoardRequest.identifier = GameCenterManager.leaderboardId // my GC Leaderboard ID
        leaderBoardRequest.playerScope = GKLeaderboardPlayerScope.global
        leaderBoardRequest.timeScope = GKLeaderboardTimeScope.allTime
        leaderBoardRequest.range = NSMakeRange(1,10)
        
        leaderBoardRequest.loadScores { scores, error in
            completion(scores, error)
        }
    }
    
    func getAchievements(completion: @escaping ([Achievement]?, Error?) -> ()) {
        
        GKAchievementDescription.loadAchievementDescriptions(completionHandler: { (descriptions, error) in
            guard let descriptions = descriptions else {
                completion(nil, nil)
                return
            }
            
            var array = [Achievement]()
            for index in 0 ..< descriptions.count {
                array.append(Achievement(achievement: nil, details: descriptions[index]))
            }
            
            GKAchievement.loadAchievements { achievements, error in
                guard let achievements = achievements else {
                    completion(nil, nil)
                    return
                }
                
                for i in 0..<achievements.count {
                    for j in 0 ..< array.count {
                        if array[j].details?.identifier == achievements[i].identifier { array[j].achievement = achievements[i] }
                    }
                }
                
                completion(array, error)
            }
        })
    }
    
    func reportAchievement(_ achievement: Achievement) {
        guard let achievement = achievement.achievement else { return }
        
        GKAchievement.report([achievement]) { error in
            if let error = error { print("achievement error" + error.localizedDescription) }
        }
    }
}
