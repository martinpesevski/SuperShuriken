//
//  GameViewController.swift
//  ClassicPong
//
//  Created by Martin Peshevski on 9/26/17.
//  Copyright © 2017 MP. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController, GADBannerViewDelegate, GameSceneDelegate {
    var bannerView : GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
//        skView.showsPhysics = true

        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .fill
            scene.gameSceneDelegate = self
            skView.presentScene(scene)
        }
        
        AdsManager.sharedInstance.showBanner()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func onDismiss() {
        dismiss(animated: true, completion: nil)
    }
}
