//
//  Shuriken.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 4/17/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit

enum Shuriken: Int, Codable {
    case basic
    case straight
    case red
    
    static var count: Int {
        return 3
    }
    
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
        case .basic:
            return 1
        case .straight:
            return 1
        case .red:
            return 2
        }
    }
    
    var isPiercing: Bool {
        switch self {
        case .basic:
            return false
        case .straight:
            return true
        case .red:
            return false
        }
    }
    
    var isSelected: Bool {
        get {
            return Global.sharedInstance.selectedPlayerShuriken == self
        }
        
        set {
            if newValue { Global.sharedInstance.selectedPlayerShuriken = self }
        }
    }
}
