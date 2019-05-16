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
        GKLocalPlayer.localPlayer().authenticateHandler = { gcAuthVC, error in
            if GKLocalPlayer.localPlayer().isAuthenticated {
                print("Authenticated to Game Center!")
                
                // Get the default leaderboard ID
                GKLocalPlayer.localPlayer().loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
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
    
    func showLeaderboard(viewController: UIViewController) {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = GameCenterManager.leaderboardId
        viewController.present(gcVC, animated: true, completion: nil)
    }
}
