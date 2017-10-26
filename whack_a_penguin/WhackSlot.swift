//
//  WhackSlot.swift
//  whack_a_penguin
//
//  Created by Erin Moon on 10/25/17.
//  Copyright © 2017 Erin Moon. All rights reserved.
//

import SpriteKit
import UIKit

class WhackSlot: SKNode {
    var charNode: SKSpriteNode!
    //Makes sure penguin is showing and hasn't been hit.
    var isVisible = false
    var isHit = false
    
    //Creates a hole + mask + penguin object.
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        
        addChild(sprite)
        
        //CropNode uses an alpha mask to hide the penguin on the stage. So we don't have to spawn penguins each time, just change y axis.
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")

        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)

        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        charNode.xScale = 1
        charNode.yScale = 1
        
        //Moves penguin up 80 pixels to appear past the mask.
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        //Randomly assigns the penguins as either blue or red.
        if RandomInt(min: 0, max: 2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        //Hides the penguin if it hasn't been tapped.
        DispatchQueue.main.asyncAfter(deadline: .now() +  (hideTime * 3.5)) {
            [unowned self] in
            self.hide()
        }
    }
    
    //Lowers the penguins behind the cropNode.
    func hide() {
        if !isVisible { return }
        
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    //When a penguin is hit, delays actions for 0.25 seconds, lowers penguin, sets hole to have no penguin visible.
    func hit() {
        isHit = true
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [unowned self] in self.isVisible = false }
        charNode.run(SKAction.sequence([delay, hide, notVisible]))
    }
}
