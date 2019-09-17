//
//  Global.swift
//  SuperShuriken
//
//  Created by Martin.Pesevski on 1/15/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit

let projectileSpeed : CGFloat = 1000
let meleeMobSpeed : CGFloat = 300
let basicMobSpeed : CGFloat = 100
let bigMobSpeed : CGFloat = 60

class Global: NSObject {
    static let shared = Global()
    override init() {
        super.init()
//        if isFirstRun {
            lockedShurikenAssets = [Shuriken.red]
//        }
    }

    var isFirstRun : Bool {
        get { return !UserDefaults.standard.bool(forKey: "wasLaunchedBefore") }
        set { UserDefaults.standard.set(true, forKey: "wasLaunchedBefore") }
    }
    
    var hasFinishedTutorial : Bool {
        get { return UserDefaults.standard.bool(forKey: "hasFinishedTutorial") }
        set { UserDefaults.standard.set(newValue, forKey: "hasFinishedTutorial") }
    }
    
    var isSoundOn : Bool {
        get { return UserDefaults.standard.bool(forKey: "isSoundOn") }
        set { UserDefaults.standard.set(newValue, forKey: "isSoundOn") }
    }
    
    var adsEnabled : Bool {
        get { return UserDefaults.standard.bool(forKey: "shurikenAdsEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "shurikenAdsEnabled") }
    }
    
    var selectedPlayerShuriken: Shuriken {
        get {
            guard let shuriken = Shuriken(rawValue: UserDefaults.standard.integer(forKey: "selectedShuriken")) else {
                return.basic
            }
            return shuriken
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "selectedShuriken") }
    }
    
    var lockedShurikenAssets: [Shuriken] {
        get {
            guard let decoded = UserDefaults.standard.array(forKey: "lockedShurikenAssets") as? [Int] else { return [] }
            
            var shurikens: [Shuriken] = []
            for name in decoded {
                if let shuriken = Shuriken(rawValue: name) { shurikens.append(shuriken) }
            }
            return shurikens
        }
        
        set {
            let shurikenValuesArray = newValue.map { $0.rawValue }
            UserDefaults.standard.set(shurikenValuesArray, forKey: "lockedShurikenAssets")
        }
    }
}
