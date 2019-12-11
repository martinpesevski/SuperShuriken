//
//  LoadingViewController.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 9/12/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import GoogleMobileAds

class LoadingViewController: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "splashScreen"))
        image.contentMode = .scaleAspectFill
        
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        load()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.performSegue(withIdentifier: "mainMenu", sender: self)
    }
    
    func load() {
        // Initialize the Google Mobile Ads SDK.
        // Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3254751950638386~5582425980")
        let queue = OperationQueue()
        let operation = BlockOperation { [weak self] in
            let group = DispatchGroup()
            
            group.enter()
            self?.app.gameCenterManager.authenticate(viewController: UIApplication.getTopViewController()) { [weak self] completed in
                if !completed {
                    self?.app.gameCenterManager.showAuthenticationDialog()
                    group.leave()
                }
                else {
                    self?.app.achievementManager.getAchievements(completion: { (_, _) in
                        group.leave()
                    })
                }
            }
            group.enter()
            self?.app.storeManager.fetchAvailableProducts() {
                group.leave()
            }
            
            group.wait()
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "mainMenu", sender: self)
            }
        }
        queue.addOperation(operation)
    }
}
