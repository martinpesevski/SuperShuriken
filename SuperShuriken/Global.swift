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

    var isSoundOn : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isSoundOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isSoundOn")
            UserDefaults.standard.synchronize()
        }
    }
    
    var adsEnabled : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "shurikenAdsEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "shurikenAdsEnabled")
            UserDefaults.standard.synchronize()
        }
    }
}
