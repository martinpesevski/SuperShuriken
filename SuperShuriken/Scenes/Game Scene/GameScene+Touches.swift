//
//  GameScene+Touches.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/5/19.
//  Copyright © 2019 MP. All rights reserved.
//
import UIKit

extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if app.gameManager.isGameFinished { return }
        
        for touch in touches {
            let touchName = getTouchName(touch: touch)
            activeTouches[touch] = touchName
            tapBeginOn(touchName: touchName, location: touch.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let touchName = activeTouches[touch] else { return }
            
            tapMovedOn(touchName: touchName, location: touch.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let touchName = activeTouches[touch] else { return }
            
            activeTouches[touch] = nil
            tapEndedOn(touchName: touchName, location: touch.location(in: self))
        }
    }
    
    func getTouchName(touch: UITouch) -> String {
        let touchLocation = touch.location(in: self)
        if touchLocation.x < frame.width/5 {
            return "movePlayer"
        } else {
            return "shoot"
        }
    }
    
    func tapBeginOn(touchName: String, location: CGPoint) {
        switch touchName {
        case "movePlayer":
            player.handleTouchStart(location: location)
            break
        case "shoot":
            player.handleShootStart()
            break
        default:
            break
        }
    }
    
    func tapMovedOn(touchName: String, location: CGPoint) {
        switch touchName {
        case "movePlayer":
            player.handleTouchMoved(location: location)
            break
        case "shoot":
            break
        default:
            break
        }
    }
    
    func tapEndedOn(touchName: String, location: CGPoint) {
        switch touchName {
        case "movePlayer":
            player.handleTouchEnded(location: location)
            break
        case "shoot":
            player.handleShootEnd()
            shootProjectile(location: location)
            break
        default:
            break
        }
    }
}
