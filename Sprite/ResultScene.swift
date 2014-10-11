//
//  ResultScene.swift
//  GluttonousSnake
//
//  Created by Jayvic on 14-10-9.
//  Copyright (c) 2014年 Jayvic. All rights reserved.
//

import SpriteKit

class ResultScene: SKScene {
    convenience init(size: CGSize, score: Int) {
        self.init(size: size)
        
        // Set the background color to white.
        self.backgroundColor = SKColor.whiteColor()
        
        // Add a result label to the middle of screen.
        let resultLabel = SKLabelNode(fontNamed: "Chalkduster")
        resultLabel.text = "Your score is " + String(score)
        resultLabel.fontSize = 30
        resultLabel.fontColor = SKColor.blackColor()
        resultLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(resultLabel)
        
        // Add a retry label below the result label.
        let retryLabel = SKLabelNode(fontNamed: "Chalkduster")
        retryLabel.text = "Try again"
        retryLabel.fontSize = 20
        retryLabel.fontColor = SKColor.blueColor()
        retryLabel.position = CGPoint(x: resultLabel.position.x, y: resultLabel.position.y * 0.8)
        retryLabel.name = "retryLabel"
        self.addChild(retryLabel)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // Change to game scene when touches on retry label.
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            let node = self.nodeAtPoint(touchLocation)
            if node.name == "retryLabel" {
                self.changeToGameScene()
            }
        }
    }
    
    // Change to game scene.
    func changeToGameScene() {
        let scene = GameScene.sceneWithSize(self.size)
        let transition = SKTransition.doorsOpenHorizontalWithDuration(1)
        self.view?.presentScene(scene, transition: transition)
    }
}
