//
//  monsterModel.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 3/30/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit

enum MobAnimationType: CaseIterable {
    case Run
    case Shoot
    case RunShoot
    case Death
    case RunSlash
    
    var name: String {
        switch self {
        case .Run:
            return "mobRunAnimation"
        case .Shoot:
            return "mobShootAnimation"
        case .RunShoot:
            return "mobRunShootAnimation"
        case .Death:
            return "mobDeathAnimation"
        case .RunSlash:
            return "mobRunSlashAnimation"
        }
    }
}

enum MonsterType: Int {
    case basicMob = 1
    case bigMob = 2
    case meleeMob = 3
    case boss = 4
    
    var scorePoints: Int {
        switch self {
        case .basicMob:
            return 1
        case .bigMob:
            return 2
        case .meleeMob:
            return 3
        case .boss:
            return 10
        }
    }
    
    var numberOfHits: Int {
        switch self {
        case .basicMob:
            return 1
        case .bigMob:
            return 2
        case .meleeMob:
            return 1
        case .boss:
            return 5
        }
    }
    
    var size: CGSize {
        switch self {
        case .basicMob:
            return CGSize(width: 267, height: 267)
        case .bigMob:
            return CGSize(width: 400, height: 320)
        case .meleeMob:
            return CGSize(width: 267, height: 267)
        case .boss:
            return CGSize(width: 667, height: 667)
        }
    }
    
    var hitBoxSize: (size: CGSize, center: CGPoint) {
        switch self {
        case .basicMob:
            return (CGSize(width: 122, height: 169), CGPoint(x: 0, y: 0))
        case .bigMob:
            return (CGSize(width: 229, height: 184), CGPoint(x: 0, y: -30))
        case .meleeMob:
            return (CGSize(width: 92, height: 165), CGPoint(x: 0, y: 0))
        case .boss:
            return (CGSize(width: 288, height: 406), CGPoint(x: 0, y: 0))
        }
    }
    
    var weaknesses: [AttackType] {
        switch self {
        case .basicMob:
            return [.Melee, .Projectile(shuriken: .basic), .Projectile(shuriken: .straight), .Projectile(shuriken: .red)]
        case .bigMob:
            return [.Projectile(shuriken: .basic), .Projectile(shuriken: .straight), .Projectile(shuriken: .red)]
        case .meleeMob:
            return [.Melee]
        case .boss:
            return [.Projectile(shuriken: .basic), .Projectile(shuriken: .straight), .Projectile(shuriken: .red)]
        }
    }
    
    var speed: CGFloat {
        switch self {
        case .basicMob:
            return basicMobSpeed
        case .bigMob:
            return bigMobSpeed
        case .meleeMob:
            return meleeMobSpeed
        case .boss:
            return 0
        }
    }
    
    var runFrameTime: TimeInterval {
        switch self {
        case .basicMob:
            return 0.07
        case .bigMob:
            return 0.07
        case .meleeMob:
            return 0.04
        case .boss:
            return 0.04
        }
    }
    
    static func random() -> MonsterType {
        let rand = arc4random_uniform(UInt32(self.count))
        return MonsterType(rawValue: Int(rand)) ?? .basicMob
    }
    
    static var count: Int { return 3 }
}
