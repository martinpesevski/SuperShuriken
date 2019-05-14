//
//  Util.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 3/5/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Wall      : UInt32 = 0b10       // 2
    static let Goal      : UInt32 = 0b11       // 3
    static let Projectile: UInt32 = 0b100       // 4
    static let EnemyProjectile: UInt32 = 0b101  // 5
    static let Player    : UInt32 = 0b110       // 6
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
}

public func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

public func getDuration(pointA:CGPoint,pointB:CGPoint,speed:CGFloat)->TimeInterval {
    let xDist = (pointB.x - pointA.x)
    let yDist = (pointB.y - pointA.y)
    let distance = sqrt((xDist * xDist) + (yDist * yDist));
    let duration : TimeInterval = TimeInterval(distance/speed)
    return duration
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

extension SKSpriteNode {
    func setupWithNode(node: SKSpriteNode){
        self.position = node.position
        self.zPosition = node.zPosition
        self.size = node.size
        node.removeFromParent()
    }
}

public func createAtlas(name: String, completion: @escaping ([SKTexture]) -> ()) {
    let animationAtlas = SKTextureAtlas(named: name)
    animationAtlas.preload {
        var animationFrames: [SKTexture] = []
        
        let numImages = animationAtlas.textureNames.count
        for i in 0..<numImages {
            let textureName = "\(name)_\(String.init(format: "%03d", i))"
            animationFrames.append(animationAtlas.textureNamed(textureName))
        }
        completion(animationFrames)
    }
}

extension UIView {
    func fadeIn() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
}

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
