//
//  App.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 9/12/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import SpriteKit

protocol Application {
    var app: App { get }
}

class App {
    static let shared = App()
    let global = Global.shared
    let adsManager = AdsManager.shared
    let gameManager = GameManager.shared
    let monsterManager = MonsterManager.shared
    let animationManager = AnimationManager.shared
    let gameCenterManager = GameCenterManager.shared
    let achievementManager = AchievementManager.shared
    let storeManager = StoreManager.shared
}

extension UIViewController: Application {
    var app: App { return App.shared }
}

extension UIView: Application {
    var app: App { return App.shared }
}

extension SKScene: Application {
    var app: App { return App.shared }
}

extension SKSpriteNode: Application {
    var app: App { return App.shared }
}
