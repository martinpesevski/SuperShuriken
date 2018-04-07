//
//  Global.swift
//  SuperShuriken
//
//  Created by Martin.Pesevski on 1/15/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit

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
            if isFirstRun { UserDefaults.standard.set(true, forKey: "isSoundOn")}

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
    
    var selectedPlayerShuriken: String {
        get {
            return UserDefaults.standard.string(forKey: "playerShurikenAssetName") ?? "ic_shuriken"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "playerShurikenAssetName")
        }
    }
}
