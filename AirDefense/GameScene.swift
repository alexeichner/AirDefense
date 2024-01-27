//
//  GameScene.swift
//  AirDefense
//
//  Created by Happy Alex on 3/16/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    
    var pointsLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var explosionHitbox: SKSpriteNode!
    var enemyMissile: SKSpriteNode!
    var enemyTrail: SKEmitterNode!
    var enemyTrails: [SKEmitterNode] = []
    var defaultHitbox: SKSpriteNode!
    var hitboxes: [SKSpriteNode] = []
    var enemyMissiles: [SKSpriteNode] = []
    let launcherBarrel = SKSpriteNode(imageNamed: "launcherBarrel")
    
    let defaults = UserDefaults.standard
    var totalCities = 6
    var totalMissiles = 0
    var isGameOver = false
    var pointsMultiplier = 6
    var points: Int = 0 {
        didSet {
            pointsLabel.text = "Points: \(points)"
        }
    }
    var city: SKSpriteNode!
    var city2: SKSpriteNode!
    var city3: SKSpriteNode!
    var city4: SKSpriteNode!
    var city5: SKSpriteNode!
    var city6: SKSpriteNode!
    
    var city1IsDestroyed = false
    var city2IsDestroyed = false
    var city3IsDestroyed = false
    var city4IsDestroyed = false
    var city5IsDestroyed = false
    var city6IsDestroyed = false
    
    override func didMove(to view: SKView) {
        
        
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -5
        addChild(background)
        
        let missileLauncher = SKSpriteNode(imageNamed: "launcherStand")
        missileLauncher.position = CGPoint(x: 512, y: 68)
        missileLauncher.zPosition = -2
        addChild(missileLauncher)
        
        
        launcherBarrel.position = CGPoint(x: 512, y: 100)
        launcherBarrel.zPosition = 1
        launcherBarrel.physicsBody = SKPhysicsBody(rectangleOf: launcherBarrel.frame.size)
        launcherBarrel.physicsBody!.affectedByGravity = false
        addChild(launcherBarrel)
        
        let barrelAnchor = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 1, height: 1))
        barrelAnchor.physicsBody = SKPhysicsBody(rectangleOf: barrelAnchor.frame.size)
        barrelAnchor.physicsBody?.node?.position = CGPoint(x: 512, y: 100)
        barrelAnchor.physicsBody!.affectedByGravity = false
        barrelAnchor.physicsBody!.mass = 99999999999
        addChild(barrelAnchor)
        let joint = SKPhysicsJointPin.joint(withBodyA: barrelAnchor.physicsBody!, bodyB: launcherBarrel.physicsBody!, anchor: barrelAnchor.position)
        self.physicsWorld.add(joint)
        
        city = SKSpriteNode(imageNamed: "city")
        city.position = CGPoint(x: 180, y: 90)
        city.physicsBody = SKPhysicsBody(rectangleOf: city.frame.size)
        city.physicsBody?.isDynamic = false
        addChild(city)
        
        city2 = SKSpriteNode(imageNamed: "city")
        city2.position = CGPoint(x: 300, y: 90)
        city2.physicsBody = SKPhysicsBody(rectangleOf: city2.frame.size)
        city2.physicsBody?.isDynamic = false
        addChild(city2)
        
        city3 = SKSpriteNode(imageNamed: "city")
        city3.position = CGPoint(x: 420, y: 90)
        city3.physicsBody = SKPhysicsBody(rectangleOf: city3.frame.size)
        city3.physicsBody?.isDynamic = false
        addChild(city3)
        
        city4 = SKSpriteNode(imageNamed: "city")
        city4.position = CGPoint(x: 600, y: 90)
        city4.physicsBody = SKPhysicsBody(rectangleOf: city4.frame.size)
        city4.physicsBody?.isDynamic = false
        addChild(city4)
        
        city5 = SKSpriteNode(imageNamed: "city")
        city5.position = CGPoint(x: 720, y: 90)
        city5.physicsBody = SKPhysicsBody(rectangleOf: city5.frame.size)
        city5.physicsBody?.isDynamic = false
        addChild(city5)
        
        city6 = SKSpriteNode(imageNamed: "city")
        city6.position = CGPoint(x: 840, y: 90)
        city6.physicsBody = SKPhysicsBody(rectangleOf: city6.frame.size)
        city6.physicsBody?.isDynamic = false
        addChild(city6)
        
        pointsLabel = SKLabelNode()
        pointsLabel.text = "Points: 0"
        pointsLabel.horizontalAlignmentMode = .right
        pointsLabel.position = CGPoint(x: 980, y: 700)
        addChild(pointsLabel)
        
        defaultHitbox = SKSpriteNode(color: UIColor.red, size: CGSize(width: 1, height: 1))
        defaultHitbox.position = CGPoint(x: 1, y: 1)
        hitboxes.append(defaultHitbox)
        
        playGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        var index = 0
        for missile in enemyMissiles {
            
            for hitbox in hitboxes {
                if missile.intersects(hitbox) {
                    if let missileIndex = enemyMissiles.firstIndex(of: missile) {
                        missile.removeFromParent()
                        destroyMissile(missile: missile)
                        enemyMissiles.remove(at: missileIndex)
                        points = points + (10 * pointsMultiplier)
                    }
                } else if missile.position.y < 5 {
                    if let missileIndex = enemyMissiles.firstIndex(of: missile) {
                        missile.removeFromParent()
                        destroyMissile(missile: missile)
                        enemyMissiles.remove(at: missileIndex)
                        let explosion = SKEmitterNode(fileNamed: "Explosion")
                        explosion?.position = missile.position
                        addChild(explosion!)
                    }
                } else {
                    areCitiesBeingHit(missile: missile, index: index)
                }
            }
            index += 1
        }
        for trail in enemyTrails {
            if trail.position.y < 60 {
                if let enemyTrail = enemyTrails.firstIndex(of: trail) {
                    trail.removeFromParent()
                    enemyTrails.remove(at: enemyTrail)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let rocket = SKSpriteNode(imageNamed: "missile")
            rocket.position = CGPoint(x: 512, y: 100)
            rocket.zPosition = -4
            rocket.zRotation = angle(between: rocket.position, ending: location) - (.pi / 2)
            addChild(rocket)
            
            let rocketTrail = SKEmitterNode(fileNamed: "RocketTrail")
            rocketTrail?.position = CGPoint(x: 512, y: 100)
            rocketTrail?.zRotation = angle(between: rocket.position, ending: location) - .pi
            addChild(rocketTrail!)
            
            launcherBarrel.zRotation = angle(between: rocket.position, ending: location) - (.pi / 2)
            
            let vertical = sinf(Float(angle(between: rocket.position, ending: location))) * 21
            let horizontal = cosf(Float(angle(between: rocket.position, ending: location))) * 21
            
            let rocketDuration = getDistanceBetweenNodes(first: rocket.position, second: location) / 300
            let trailDuration = getDistanceBetweenNodes(first: rocketTrail!.position, second: CGPoint(x: location.x - CGFloat(horizontal), y: location.y - CGFloat(vertical))) / 300
            rocket.run(SKAction.move(to: location, duration: rocketDuration))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                [unowned self] in
                rocketTrail?.run(SKAction.move(to: CGPoint(x: location.x - CGFloat(horizontal), y: location.y - CGFloat(vertical)), duration: trailDuration))
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + rocketDuration) {
                [unowned self] in
                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                    explosion.position = location
                    addChild(explosion)
                    rocket.removeFromParent()
                    rocketTrail?.removeFromParent()
                    createExplosionHitboxes(position: location)
                }
            }
        }
    }
    
    func addCityExplosion(city: SKSpriteNode) {
        let cityExplosion = SKEmitterNode(fileNamed: "CityExplosion")
        cityExplosion?.position = CGPoint(x: city.position.x, y: city.position.y - 34)
        addChild(cityExplosion!)
    }
    
    func areCitiesBeingHit(missile: SKSpriteNode, index: Int) {
        
        if missile.intersects(city) {
            if let missileIndex = enemyMissiles.firstIndex(of: missile) {
                missile.removeFromParent()
                destroyMissile(missile: missile)
                enemyMissiles.remove(at: missileIndex)
                if !city1IsDestroyed {
                    addCityExplosion(city: city)
                    totalCities -= 1
                    pointsMultiplier -= 1
                }
                city1IsDestroyed = true
            }
            
            
        } else if missile.intersects(city2) {
            if let missileIndex = enemyMissiles.firstIndex(of: missile) {
                missile.removeFromParent()
                destroyMissile(missile: missile)
                enemyMissiles.remove(at: missileIndex)
                if !city2IsDestroyed {
                    addCityExplosion(city: city2)
                    totalCities -= 1
                    pointsMultiplier -= 1
                }
                city2IsDestroyed = true
            }
            
        } else if missile.intersects(city3) {
            if let missileIndex = enemyMissiles.firstIndex(of: missile) {
                missile.removeFromParent()
                destroyMissile(missile: missile)
                enemyMissiles.remove(at: missileIndex)
                if !city3IsDestroyed {
                    addCityExplosion(city: city3)
                    totalCities -= 1
                    pointsMultiplier -= 1
                }
                city3IsDestroyed = true
            }
            
        } else if missile.intersects(city4) {
            if let missileIndex = enemyMissiles.firstIndex(of: missile) {
                missile.removeFromParent()
                destroyMissile(missile: missile)
                enemyMissiles.remove(at: missileIndex)
                if !city4IsDestroyed {
                    addCityExplosion(city: city4)
                    totalCities -= 1
                    pointsMultiplier -= 1
                }
                city4IsDestroyed = true
            }
            
        } else if missile.intersects(city5) {
            if let missileIndex = enemyMissiles.firstIndex(of: missile) {
                missile.removeFromParent()
                destroyMissile(missile: missile)
                enemyMissiles.remove(at: missileIndex)
                if !city5IsDestroyed {
                    addCityExplosion(city: city5)
                    totalCities -= 1
                    pointsMultiplier -= 1
                }
                city5IsDestroyed = true
            }
            
        } else if missile.intersects(city6) {
            if let missileIndex = enemyMissiles.firstIndex(of: missile) {
                missile.removeFromParent()
                destroyMissile(missile: missile)
                enemyMissiles.remove(at: missileIndex)
                if !city6IsDestroyed {
                    addCityExplosion(city: city6)
                    totalCities -= 1
                    pointsMultiplier -= 1
                }
                city6IsDestroyed = true
            }
        }
        
        if totalCities <= 0 {
            isGameOver = true
        }
    }
    
    func destroyMissile(missile: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")
        explosion?.position = missile.position
        addChild(explosion!)
    }
    
    func createExplosionHitboxes(position: CGPoint) {
        for index in 1...3 {
            explosionHitbox = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 50, height: 50))
            explosionHitbox.name = "hitbox\(index)"
            explosionHitbox.position = position
            if index == 1 {
                explosionHitbox.zRotation = 0.524
            } else if index == 2 {
                explosionHitbox.zRotation = 1.048
            }
            addChild(explosionHitbox)
            hitboxes.append(explosionHitbox)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                [unowned self] in
                for hitbox in hitboxes {
                    hitbox.removeFromParent()
                    hitboxes.remove(at: hitboxes.firstIndex(of: hitbox)!)
                }
            }
        }
    }
    
    func gameOver() {
        let gameOverScene = GameOverScene(fileNamed: "GameOverScene")
        gameOverScene!.lastPoints = points

        gameOverScene!.scaleMode = .fill
        let transition = SKTransition.crossFade(withDuration: 2)
        self.view?.presentScene(gameOverScene!, transition: transition)
    }
    
    func playGame() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [unowned self] in
            if !isGameOver {
                spawnEnemies()
                playGame()
            } else {
                gameOver()
            }
        }
    }
    
    func spawnEnemies() {
        totalMissiles += 1
        let randomX = Int.random(in: 100...900)
        let target = CGPoint(x: randomX, y: 35)
        
        enemyMissile = SKSpriteNode(imageNamed: "missile")
        enemyMissile.name = "missile\(totalMissiles)"
        enemyMissiles.append(enemyMissile)
        enemyMissile.position = CGPoint(x: Int.random(in: 100...900), y: 768)
        enemyMissile.zRotation = angle(between: enemyMissile.position, ending: target) - (.pi / 2)
        addChild(enemyMissile)
        
        enemyTrail = SKEmitterNode(fileNamed: "RocketTrail")
        enemyTrail.name = "trail\(totalMissiles)"
        enemyTrail.position = enemyMissile.position
        enemyTrail.zRotation = angle(between: enemyMissile.position, ending: target) - .pi
        addChild(enemyTrail)
        enemyTrails.append(enemyTrail)
        
        let vertical = sinf(Float(angle(between: enemyMissile.position, ending: target))) * 21
        let horizontal = cosf(Float(angle(between: enemyMissile.position, ending: target))) * 21
        
        enemyTrail.run(SKAction.move(to: CGPoint(x: target.x - CGFloat(horizontal), y: target.y - CGFloat(vertical)), duration: 5))
        enemyMissile.run(SKAction.move(to: target, duration: 5))
    }
    
    func getDistanceBetweenNodes(first: CGPoint, second: CGPoint) -> CGFloat {
        return hypot(second.x - first.x, second.y - first.y)
    }
    
    func angle(between starting: CGPoint, ending: CGPoint) -> CGFloat {
        let relativeToStart = CGPoint(x: ending.x - starting.x, y: ending.y - starting.y)
        let radians = atan2(relativeToStart.y, relativeToStart.x)
        return radians > 0 ? radians : (.pi * 2) + radians
    }
}

