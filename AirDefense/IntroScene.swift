//
//  IntroScene.swift
//  AirDefense
//
//  Created by Student on 4/17/23.
//

import UIKit
import SpriteKit

class IntroScene: SKScene {

    var playButton: SKLabelNode!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -5
        addChild(background)
        
        playButton = SKLabelNode(text: "Play")
        playButton.fontSize = 50
        playButton.position = CGPoint(x: 512, y: 384)
        addChild(playButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodes = nodes(at: location)
            
            if nodes.contains(playButton) {
                let scene = GameScene(fileNamed: "GameScene")
                scene!.scaleMode = .fill
                let transition = SKTransition.crossFade(withDuration: 2)
                self.view?.presentScene(scene!, transition: transition)
            }
        }
    }
}
