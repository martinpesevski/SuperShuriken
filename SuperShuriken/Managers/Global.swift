//
//  Global.swift
//  SuperShuriken
//
//  Created by Martin.Pesevski on 1/15/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit

let projectileSpeed : CGFloat = 1000
let meleeMobSpeed : CGFloat = 600
let basicMobSpeed : CGFloat = 500
let bigMobSpeed : CGFloat = 400

class Global: NSObject {
    static let sharedInstance = Global()

    var isFirstRun : Bool {
        get {
            return !UserDefaults.standard.bool(forKey: "wasLaunchedBefore")
        }
        set {
            UserDefaults.standard.set(true, forKey: "wasLaunchedBefore")
        }
    }
    
    var isSoundOn : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isSoundOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isSoundOn")
        }
    }
    
    var adsEnabled : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "shurikenAdsEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "shurikenAdsEnabled")
        }
    }
    
    var selectedPlayerShuriken: Shuriken {
        get {
            guard let shuriken = Shuriken(rawValue: UserDefaults.standard.integer(forKey: "selectedShuriken")) else {
                return.basic
            }
            return shuriken
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedShuriken")
        }
    }
    
    var lockedShurikenAssets: [String] {
        get {
            return UserDefaults.standard.array(forKey: "lockedShurikenAssets") as? [String] ?? ["ic_shuriken3"]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lockedShurikenAssets")
        }
    }
}
