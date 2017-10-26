//
//  GameScene.swift
//  whack_a_penguin
//
//  Created by Erin Moon on 10/25/17.
//  Copyright © 2017 Erin Moon. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    //Keeps track of each hole created.
    var slots = [WhackSlot]()
    //Base time between each group of penguins appearing.
    var popupTime = 0.85
    var numRounds = 0
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        //Background styling and position.
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        //Score board styling and position.
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontColor = SKColor.darkGray
        addChild(gameScore)
        
        //Creates 4 rows of holes each evenly spaced.
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        //Initial call to start game.
        createEnemy()
        
        //Cycles the game till it ends.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [unowned self] in
            self.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Records which node is touched first.
        if let touch = touches.first {
            let location = touch.location(in: self)
            let tappedNodes = nodes(at: location)
            
            //Checks if user tapped on good or bad penguin.
            for node in tappedNodes {
                if node.name == "charFriend" {
                    //Node is penguin -> parent is mask -> parent is Whackslot node.
                    let whackSlot = node.parent!.parent as! WhackSlot
                    if !whackSlot.isVisible { continue }
                    if whackSlot.isHit { continue }
                    
                    whackSlot.charNode.xScale = 0.85
                    whackSlot.charNode.yScale = 0.85
                    
                    //Calls hit() in the WhackSlot class.
                    whackSlot.hit()
                    score += 1
                    
                    run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                } else if node.name == "charEnemy" {
                    let whackSlot = node.parent!.parent as! WhackSlot
                    if !whackSlot.isVisible { continue }
                    if whackSlot.isHit { continue }
                    
                    whackSlot.hit()
                    score -= 5
                    
                    run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
                }
            }
        }
    }
    
    //Create a slot based on the WhackSlot class.
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        //Slowly increases penguin spawn rate.
        popupTime *= 0.991
        
        //Shuffles the holes to randomize the order penguins spawn.
        slots = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: slots) as! [WhackSlot]
        slots[0].show(hideTime: popupTime)
        
        //Allows up to 4 additional penguins to spawn randomly.
        if RandomInt(min: 0, max: 12) > 4 {
            slots[1].show(hideTime: popupTime) }
        if RandomInt(min: 0, max: 12) > 8 {
            slots[2].show(hideTime: popupTime) }
        if RandomInt(min: 0, max: 12) > 10 {
            slots[3].show(hideTime: popupTime) }
        if RandomInt(min: 0, max: 12) > 11 {
            slots[4].show(hideTime: popupTime) }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = RandomDouble(min: minDelay, max: maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            [unowned self] in
            self.createEnemy()
        }
        
        numRounds += 1
        
        //How many times createEnemy gets called before the game ends.
        if numRounds >= 30 {
            //Hides all holes.
            for slot in slots {
                slot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            
            return
        }
    }
}
