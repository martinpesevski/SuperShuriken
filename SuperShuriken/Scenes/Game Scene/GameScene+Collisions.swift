//
//  GameScene+Collisions.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/5/19.
//  Copyright © 2019 MP. All rights reserved.
//

import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    
    func projectileDidColideWithMonster (projectile: ProjectileNode, monster: MonsterNode) {
        projectile.removeFromParent()
        playerProjectilesArray = playerProjectilesArray.filter{$0 != projectile}
        
        if monster.hitAndCheckDead(attackType: .Projectile) {
            app.monsterManager.monstersArray = app.monsterManager.monstersArray.filter{$0 != monster}
            monster.playDeathAnimation()
            
            if app.gameManager.isBossLevel {
                for projectile in enemyProjectilesArray {
                    projectile.removeFromParent()
                }
                enemyProjectilesArray.removeAll()
            }
            
            app.gameManager.updateScore(value: monster.type.scorePoints)
            updateScoreLabel()
        } else {
            monster.playHitAnimation()
        }
    }
    
    func projectileDidColideWithProjectile(projectile1: ProjectileNode, projectile2: ProjectileNode) {
        projectile1.removeFromParent()
        playerProjectilesArray = playerProjectilesArray.filter{$0 != projectile1}
        
        projectile2.removeFromParent()
        enemyProjectilesArray = enemyProjectilesArray.filter{$0 != projectile2}
    }
    
    func enemyProjectileHitPlayer(projectile: ProjectileNode, player: PlayerNode) {
        projectile.removeFromParent()
        enemyProjectilesArray = enemyProjectilesArray.filter{$0 != projectile}
        player.handleGotHit()
        endGame()
    }
    
    func projectileDidColideWithWall(projectile: ProjectileNode, wall: SKSpriteNode) {
        
    }
    
    func monsterDidReachGoal(monster: MonsterNode, goal: MonsterGoalNode) {
        monster.removeFromParent()
        app.monsterManager.monstersArray = app.monsterManager.monstersArray.filter{$0 != monster}
        
        endGame()
    }
    
    func monsterDidCollideWithPlayer(monster: MonsterNode, player: PlayerNode) {
        app.monsterManager.monstersArray = app.monsterManager.monstersArray.filter{$0 != monster}
        monster.playDeathAnimation()
        
        if monster.hitAndCheckDead(attackType: .Melee) {
            player.handleSlash()
            app.gameManager.updateScore(value: monster.type.scorePoints)
            updateScoreLabel()
        } else {
            player.handleGotHit()
            endGame()
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask == PhysicsCategory.Monster) &&
            (secondBody.categoryBitMask == PhysicsCategory.Projectile) {
            if let monster = firstBody.node as? MonsterNode, let projectile = secondBody.node as? ProjectileNode {
                projectileDidColideWithMonster(projectile: projectile, monster: monster)
            }
        } else if (firstBody.categoryBitMask == PhysicsCategory.Wall) &&
            (secondBody.categoryBitMask == PhysicsCategory.Projectile) {
            if let wall = firstBody.node as? SKSpriteNode, let projectile = secondBody.node as? ProjectileNode {
                projectileDidColideWithWall(projectile: projectile, wall: wall)
            }
        } else if (firstBody.categoryBitMask == PhysicsCategory.Monster) &&
            (secondBody.categoryBitMask == PhysicsCategory.Goal) {
            if let monster = firstBody.node as? MonsterNode, let goal = secondBody.node as? MonsterGoalNode {
                monsterDidReachGoal(monster: monster, goal: goal)
            }
        } else if (firstBody.categoryBitMask == PhysicsCategory.Monster) &&
            (secondBody.categoryBitMask == PhysicsCategory.Player) {
            if let monster = firstBody.node as? MonsterNode, let player = secondBody.node as? PlayerNode {
                monsterDidCollideWithPlayer(monster: monster, player: player)
            }
        } else if (firstBody.categoryBitMask == PhysicsCategory.EnemyProjectile) &&
            (secondBody.categoryBitMask == PhysicsCategory.Player){
            if let projectile = firstBody.node as? ProjectileNode, let player = secondBody.node as? PlayerNode {
                enemyProjectileHitPlayer(projectile: projectile, player: player)
            }
        } else if (firstBody.categoryBitMask == PhysicsCategory.Projectile) &&
            (secondBody.categoryBitMask == PhysicsCategory.EnemyProjectile){
            if let projectile1 = firstBody.node as? ProjectileNode, let projectile2 = secondBody.node as? ProjectileNode {
                projectileDidColideWithProjectile(projectile1: projectile1, projectile2: projectile2)
            }
        }
    }
}
