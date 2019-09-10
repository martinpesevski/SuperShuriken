//
//  mainMenuViewController.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 4/24/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import SnapKit

class MainMenuViewController: UIViewController {

    let backgroundImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "splashScreen"))
        image.contentMode = .scaleAspectFill
        
        return image
    }()
    
    lazy var playButton: MenuButton = {
        let button = MenuButton()
        button.addTarget(self, action: #selector(onPlay), for: .touchUpInside)
        button.setTitle("Play", for: .normal)
        
        return button
    }()
    
    lazy var settingsButton: MenuButton = {
        let button = MenuButton()
        button.addTarget(self, action: #selector(onSettings), for: .touchUpInside)
        button.setTitle("Settings", for: .normal)

        return button
    }()
    
    lazy var leaderboardButton: MenuButton = {
        let button = MenuButton()
        button.addTarget(self, action: #selector(onLeaderboard), for: .touchUpInside)
        button.setTitle("Leaderboard", for: .normal)
        
        return button
    }()
    
    lazy var achievementsButton: MenuButton = {
        let button = MenuButton()
        button.addTarget(self, action: #selector(onAchievements), for: .touchUpInside)
        button.setTitle("Achievements", for: .normal)
        
        return button
    }()
    
    lazy var buttonContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [playButton, settingsButton, leaderboardButton, achievementsButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GameCenterManager.shared.authenticate(viewController: self) { [weak self] completed in
            if !completed { self?.showAuthenticationDialog() }
        }
        
        view.addSubview(backgroundImageView)
        view.addSubview(buttonContainer)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        buttonContainer.snp.updateConstraints { make in
            make.right.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
    }
    
    @objc func onPlay() {
        performSegue(withIdentifier: "play", sender: nil)
    }
    
    @objc func onSettings() {
        performSegue(withIdentifier: "settings", sender: nil)
    }
    
    @objc func onLeaderboard() {
        guard GameCenterManager.shared.isAuthenticated() else {
            showAuthenticationDialog()
            return
        }
        performSegue(withIdentifier: "leaderboard", sender: nil)
    }
    
    @objc func onAchievements() {
        guard GameCenterManager.shared.isAuthenticated() else {
            showAuthenticationDialog()
            return
        }
        performSegue(withIdentifier: "achievements", sender: nil)
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
        self.present(alert, animated: true, completion: nil)
    }
}
