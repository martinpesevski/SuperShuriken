//
//  Global.swift
//  SuperShuriken
//
//  Created by Martin.Pesevski on 1/15/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit

class Global: NSObject {
    var isSoundOn : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isSoundOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isSoundOn")
        }
    }
}
