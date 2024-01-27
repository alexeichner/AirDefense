//
//  GameOverScene.swift
//  AirDefense
//
//  Created by Student on 4/14/23.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    
    var lastPoints = 0
    var playAgainButton: SKLabelNode!
    let defaults = UserDefaults.standard
    override func didMove(to view: SKView) {
        
        let highScore = defaults.integer(forKey: "highScore")
        
        if lastPoints > defaults.integer(forKey: "highScore") {
            defaults.set(lastPoints, forKey: "highScore")
        }
        
        
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -5
        background.blendMode = .replace
        addChild(background)
        
        playAgainButton = SKLabelNode(text: "Play Again?")
        playAgainButton.fontSize = 40
        playAgainButton.position = CGPoint(x: 512, y: 384)
        addChild(playAgainButton)
        
        let highScoreLabel = SKLabelNode(text: "Your High Score is: \(defaults.integer(forKey: "highScore"))")
        highScoreLabel.fontSize = 30
        highScoreLabel.position = CGPoint(x: 512, y: 500)
        addChild(highScoreLabel)
        
        let lastPointsLabel = SKLabelNode(text: "Your score was: \(lastPoints)")
        lastPointsLabel.fontSize = 30
        lastPointsLabel.position = CGPoint(x: 512, y: 430)
        addChild(lastPointsLabel)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodes = nodes(at: location)
            
            if nodes.contains(playAgainButton) {
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene!.scaleMode = .fill
                let transition = SKTransition.crossFade(withDuration: 2)
                self.view?.presentScene(gameScene!, transition: transition)
            }
        }
    }
}
