//
//  GameScene.swift
//  YSC_SpineSwiftTest
//
//  Created by 최윤석 on 2015. 11. 13..
//  Copyright (c) 2015년 Yoonsuk Choi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var alien = YSC_SpineSkeleton()
    var hero = YSC_SpineSkeleton()
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 45;
        myLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY);
        
        self.addChild(myLabel)
        
        alien.spawn(JSONName: "alien", atlasName:"alien",skinName: nil)
        alien.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        alien.xScale = 0.5
        alien.yScale = 0.5
        alien.queuedAnimation = "run"
        self.addChild(alien)
        alien.runQueue()
        
        
        hero.spawn(JSONName: "hero", atlasName:"hero", skinName: nil)
        hero.position = CGPoint(x:self.frame.midX, y:self.frame.minY + 100)
        hero.xScale = 0.5
        hero.yScale = 0.5
        hero.queuedAnimation = "Run"
        self.addChild(hero)
        hero.runQueue()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.location(in: self)
            let nodeTouched = atPoint(location)
            if let attachment = nodeTouched as? YSC_SpineAttachment {
                if attachment.inParentHierarchy(self.alien) {
                    self.alien.runAnimationUsingQueue("death", count: 1, interval: 0)
                }
                if attachment.inParentHierarchy(self.hero) {
                    self.hero.runAnimationUsingQueue("Attack", count: 1, interval: 0)
                }
            }
            
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    override func didFinishUpdate() {
        hero.ikActionUpdate()
    }
}
