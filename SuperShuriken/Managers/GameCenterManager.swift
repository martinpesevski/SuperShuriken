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
}
