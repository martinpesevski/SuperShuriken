//
//  Shuriken.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 4/17/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit

enum Shuriken: Int, Codable, Application {
    case basic
    case straight
    case red
    
    static var count: Int { return 3 }
    var app: App { return App.shared }
    
    var image: UIImage {
        switch self {
        case .basic:
            return UIImage(named: "ic_shuriken") ?? UIImage()
        case .straight:
            return UIImage(named: "ic_shuriken2") ?? UIImage()
        case .red:
            return UIImage(named: "ic_shuriken3") ?? UIImage()
        }
    }
    
    var damage: Int {
        switch self {
        case .basic, .straight:
            return 1
        case .red:
            return 2
        }
    }
    
    var isPiercing: Bool {
        switch self {
        case .straight:
            return true
        default:
            return false
        }
    }
    
    var isSelected: Bool {
        get {
            return app.global.selectedPlayerShuriken == self
        }
        
        set {
            if newValue { app.global.selectedPlayerShuriken = self }
        }
    }
    
    var isUnlocked: Bool {
        get {
            return !app.global.lockedShurikenAssets.contains(self)
        }
    }
    
    func unlock() {
        var shurikens = app.global.lockedShurikenAssets
        shurikens = shurikens.filter{$0 != self}
        app.global.lockedShurikenAssets = shurikens
    }
}
