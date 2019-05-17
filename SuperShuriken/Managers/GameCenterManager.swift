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

    func authenticate(viewController: UIViewController?){
//        guard localPLayer.authenticateHandler == nil else {
//            localPLayer.authenticateHandler
//        }
        localPLayer.authenticateHandler = { [weak self] gcAuthVC, error in
            guard let self = self else {return}
            
            if self.localPLayer.isAuthenticated {
                print("Authenticated to Game Center!")
                
                // Get the default leaderboard ID
                self.localPLayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    guard error == nil else {
                        print(error?.localizedDescription ?? "error getting leaderboard")
                        return
                    }
                    
                    self.defaultLeaderboard = leaderboardIdentifer
                })
            } else if let vc = gcAuthVC {
                viewController?.present(vc, animated: true)
            }
            else {
                print("Error authentication to GameCenter: " +
                    "\(error?.localizedDescription ?? "none")")
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
