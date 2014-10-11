//
//  GameScene.swift
//  GluttonousSnake
//
//  Created by Jayvic on 14-10-8.
//  Copyright (c) 2014年 Jayvic. All rights reserved.
//

import SpriteKit
import AVFoundation

extension Array {
    // Remove certain object in the array.
    mutating func removeObject<X: AnyObject>(obj: X?) {
        if obj == nil {
            return
        }
        for (idx, one) in enumerate(self) {
            if one as X === obj {
                self.removeAtIndex(idx)
                break
            }
        }
    }
}

class GameScene: SKScene {
    var monsters = [SKNode]()
    var projectiles = [SKNode]()
    var score = 0
    let projectileSound = SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false)
    var bgmPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("background-music-aac", ofType: "caf")!), error: nil)
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        // Add player to the scene.
        let player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: player.size.width / 2, y: self.size.height / 2)
        self.addChild(player)
        monsters.removeObject(SKNode() as AnyObject)
        
        // Add monsters with interval.
        let actionMonster = SKAction.runBlock({[unowned self] in self.addMonster()})
        let actionWait = SKAction.waitForDuration(1)
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([actionMonster, actionWait])))
        
        // Add BGM for the game.
        self.bgmPlayer.numberOfLoops = -1
        self.bgmPlayer.play()
//        let playBGM = SKAction.playSoundFileNamed("background-music-aac.caf", waitForCompletion: true)
//        self.runAction(SKAction.repeatActionForever(playBGM))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        for touch in touches {
            self.launchProjectile(touch.locationInNode(self))
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        self.checkCollision()
    }
    
    // Add a monster to the scene.
    func addMonster() {
        // Add the monster at random Y position.
        let monster = SKSpriteNode(imageNamed: "monster")
        let randInt = UInt(arc4random()) % UInt(self.size.height - monster.size.height + 1.0)
        let actualY = CGFloat(randInt) + monster.size.height / 2
        monster.position = CGPoint(x: self.size.width + monster.size.width / 2, y: actualY)
        self.addChild(monster)
        self.monsters.append(monster)
        
        // Move the monster with random speed.
        let duration = 2.0 + Double(arc4random() % 200) / 100
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width / 2, y: actualY), duration: duration)
        monster.runAction(actionMove){
            [unowned self, unowned monster] in
            self.monsters.removeObject(monster)
            monster.removeFromParent()
            self.changeToResultScene()
        }
    }
    
    // Launch a projectile cross the aim point.
    func launchProjectile(aim: CGPoint) {
        let projectile = SKSpriteNode(imageNamed: "projectile")
        let fromPoint = CGPoint(x: projectile.size.width / 2, y: self.size.height / 2)
        
        // Launch only when the position is legal.
        if aim.x > fromPoint.x {
            // Show the projectile.
            projectile.position = fromPoint
            self.addChild(projectile)
            self.projectiles.append(projectile)
            
            // Calc destination and velocity of the projectile.
            let actualY = (aim.y - fromPoint.y) / (aim.x - fromPoint.x) * self.size.width + fromPoint.y
            let toPoint = CGPoint(x: self.size.width + projectile.size.width / 2, y: actualY)
            let length = self.calcDistance(fromPoint, pointTo: toPoint)
            let velocity = self.size.width
            
            // Let the velocity move.
            let actionMove = SKAction.moveTo(toPoint, duration: Double(length / velocity))
            projectile.runAction(SKAction.group([actionMove, self.projectileSound])){
                [unowned self, unowned projectile] in
                self.projectiles.removeObject(projectile)
                projectile.removeFromParent()
            }
        }
    }
    
    // Check collision between projectiles and monsters.
    func checkCollision() {
        for projectile in self.projectiles {
            // Find the monsters collided with the projectile.
            var killed = [Int]()
            for (index, monster) in enumerate(self.monsters) {
                if CGRectIntersectsRect(projectile.frame, monster.frame) {
                    killed.append(index)
                }
            }
            
            // Remove the projectile and monsters collided.
            if killed.count > 0 {
                self.projectiles.removeObject(projectile)
                projectile.removeFromParent()
                for index in killed {
                    self.monsters.removeAtIndex(index).removeFromParent()
                }
                
                // Calculate the score.
                score += killed.count
            }
        }
    }
    
    // Calc Euclidean distance.
    func calcDistance(pointFrom: CGPoint, pointTo: CGPoint) -> CGFloat {
        return sqrt(sqr(pointTo.x - pointFrom.x) + sqr(pointTo.y - pointFrom.y))
    }
    
    // Calc square of certain number.
    func sqr(x: CGFloat) -> CGFloat {
        return x * x
    }
    
    // Change to result scene.
    func changeToResultScene() {
        // Stop the BGM.
        self.bgmPlayer.stop()
        
        let resScene = ResultScene(size: self.size, score: self.score)
        let transition = SKTransition.fadeWithDuration(1)
        self.view?.presentScene(resScene, transition: transition)
    }
}
