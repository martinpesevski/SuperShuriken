//
//  GameManager.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 3/5/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit

class GameManager: NSObject {
    static let sharedInstance = GameManager()
    
    var score = 0
    var level = 1
    
    func restart() {
        score = 0
        level = 1
    }

}
