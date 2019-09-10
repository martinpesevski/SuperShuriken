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
    var achievements = [Achievement]()
    var highScores = [GKScore]()
    
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
    
    func getHighScores(completion: (([GKScore]?, Error?) -> ())?) {
        let leaderBoardRequest = GKLeaderboard()
        leaderBoardRequest.identifier = GameCenterManager.leaderboardId // my GC Leaderboard ID
        leaderBoardRequest.playerScope = GKLeaderboardPlayerScope.global
        leaderBoardRequest.timeScope = GKLeaderboardTimeScope.allTime
        leaderBoardRequest.range = NSMakeRange(1,10)
        
        leaderBoardRequest.loadScores { [weak self] scores, error in
            guard let self = self, let scores = scores else {
                completion?(nil, nil)
                return
            }
            
            self.highScores = scores
            completion?(scores, error)
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
        guard let achievement = achievement.achievement else { return }
        
        GKAchievement.report([achievement]) { error in
            if let error = error { print("achievement error" + error.localizedDescription) }
        }
    }
    
    func showAuthenticationDialog() {
        let alert = UIAlertController(title: "You need to log in to game center to be able to track your scores and achievements", message: "please login to the Game Center from settings if you wish to use the leaderboard feature", preferredStyle: .alert)
        let loginButton = UIAlertAction(title: "Log in", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(loginButton)
        alert.addAction(cancelButton)
        UIApplication.getTopViewController()?.present(alert, animated: true, completion: nil)
    }
}
