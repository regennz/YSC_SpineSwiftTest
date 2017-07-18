//
//  YSC_SpineBone.swift
//  YSC_Spine
//
//  Created by 최윤석 on 2015. 10. 30..
//  Copyright © 2015년 Yoonsuk Choi. All rights reserved.
//

import Foundation
import SpriteKit

class YSC_SpineBone: SKSpriteNode {
    
    var parentName:String?
    var length = CGFloat(0)
    var inheritRotation = true
    var inheritScale = true         // not currently avaliable
    var hasIKAction = false
    var ikTargetNode:SKNode!
    var ikRootNode:SKNode!
    var ikBendPositive = true
    
    var defaultPosition = CGPoint.zero
    var defaultScaleX = CGFloat(1)
    var defaultScaleY = CGFloat(1)
    var defaultRotation = CGFloat(0)
    var basePosition = CGPoint.zero
    var baseScaleX = CGFloat(1)
    var baseScaleY = CGFloat(1)
    var baseRotation = CGFloat(0)
    
    var SRTAction = Dictionary<String, SKAction>()  // animation name : SRTAction

    // MARK:- SETUP
    func spawn(boneJSON:JSON) {
        
        self.name = boneJSON["name"].stringValue
        self.parentName = boneJSON["parent"].string         // nil if there's no parent
        // Setting its setup pose
        
        if let tempLength = boneJSON["length"].double {         // assue 0 if omitted
            self.length = CGFloat(tempLength)
            self.size.width = CGFloat(tempLength)
            
        }
        if let tempXPos = boneJSON["x"].double {                // assume 0 if ommitted
            self.position.x = CGFloat(tempXPos)
        }
        if let tempYPos = boneJSON["y"].double {                // assume 0 if omitted
            self.position.y = CGFloat(tempYPos)
        }
        if let tempScaleX = boneJSON["scaleX"].double {         // assume 1 if omited
            self.xScale = CGFloat(tempScaleX)
        }
        if let tempScaleY = boneJSON["scaleY"].double {         // assume 1 if omitted
            self.yScale = CGFloat(tempScaleY)
        }
        if let tempZRotation = boneJSON["rotation"].double {    // assume 0 if omitted
            self.zRotation = CGFloat(tempZRotation) * SPINE_DEGTORADFACTOR
        }
        if let tempInheritRotation = boneJSON["inheritRotation"].bool {     // assume true if omitted
            self.inheritRotation = tempInheritRotation
        }
        if let tempInheritScale = boneJSON["inheritScale"].bool {     // assume true if omitted
            self.inheritScale = tempInheritScale
        }

    }
    
    func setDefaultsAndBase() {
        self.defaultPosition = self.position
        self.defaultRotation = self.zRotation
        self.defaultScaleX = self.xScale
        self.defaultScaleY = self.yScale
        self.basePosition = self.position
        self.baseRotation = self.zRotation
        self.baseScaleX = self.xScale
        self.baseScaleY = self.yScale
    }
    
    func setToDefaults() {
        self.position = self.defaultPosition
        self.zRotation = self.defaultRotation
        self.xScale = self.defaultScaleX
        self.yScale = self.defaultScaleY
        self.basePosition = self.position
        self.baseRotation = self.zRotation
        self.baseScaleX = self.xScale
        self.baseScaleY = self.yScale
        
        // set to default attachment
        self.enumerateChildNodes(withName: "*") { (node:SKNode, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            if let slot = node as? YSC_SpineSlot {
                slot.setToDefaultAttachment()
            }
        }
        
    }
    // MARK:- ANIMATION
    
    func createAnimations(_ animationName:String, SRTTimelines:JSON, longestDuration:TimeInterval) {
        
        var duration:TimeInterval = 0
        var elapsedTime:TimeInterval = 0
        var gabageTime:TimeInterval = 0
        var gabageAction = SKAction()
        
        let rotateTimelines = SRTTimelines["rotate"]
        let translateTimelines = SRTTimelines["translate"]
        let scaleTimelines = SRTTimelines["scale"]
        
        var rotateActionSequence = Array<SKAction>()
        var translateActionSequence = Array<SKAction>()
        var scaleActionSequence = Array<SKAction>()
        var noInheritRotSequence = Array<SKAction>()
        
        // Rotate Action
        var dAngle = CGFloat(0)
        var currentAngle = CGFloat(0)
        var action = SKAction()
        
        for (_, rotateTimeline):(String, JSON) in rotateTimelines {
            
            duration = TimeInterval(rotateTimeline["time"].doubleValue) - elapsedTime
            elapsedTime = TimeInterval(rotateTimeline["time"].doubleValue)
            
            dAngle = CGFloat(rotateTimeline["angle"].doubleValue)
            dAngle = dAngle.truncatingRemainder(dividingBy: 360)
            if dAngle < -180 {
                dAngle = dAngle + 360
            } else if dAngle >= 180 {
                dAngle = dAngle - 360
            }
            dAngle = dAngle * SPINE_DEGTORADFACTOR
            currentAngle = self.defaultRotation + dAngle
            
            action = SKAction.rotate(toAngle: currentAngle, duration: duration)

            if rotateTimeline["curve"].exists() {
                let curveInfo = rotateTimeline["curve"].rawValue
                if curveInfo is NSString {
                    let curveString = curveInfo as! String
                    if curveString == "stepped" {
                        // stepped curve
                        action.timingMode = .easeIn
                    }
                } else if curveInfo is NSArray {
                    // bezier curve
                    action.timingMode = .easeInEaseOut
                }
            } else {
                // linear curve
                action.timingMode = .linear
            }
            rotateActionSequence.append(action)
            
        }
        gabageTime = longestDuration - elapsedTime
        gabageAction = SKAction.wait(forDuration: gabageTime)
       
        rotateActionSequence.append(gabageAction)
        noInheritRotSequence.append(gabageAction)

        
        let rotateAction = SKAction.sequence(rotateActionSequence)
        let noInheritRotAction = SKAction.sequence(noInheritRotSequence)
        
        
        // Translate Action
        duration = 0
        elapsedTime = 0
        var dx = CGFloat(0)
        var currentX = CGFloat(0)
        var dy = CGFloat(0)
        var currentY = CGFloat(0)
        for (_, translateTimeline):(String, JSON) in translateTimelines {
            
            duration = TimeInterval(translateTimeline["time"].doubleValue) - elapsedTime
            elapsedTime = TimeInterval(translateTimeline["time"].doubleValue)
            
            dx = CGFloat(translateTimeline["x"].doubleValue)
            dy = CGFloat(translateTimeline["y"].doubleValue)
            currentX = self.defaultPosition.x + dx
            currentY = self.defaultPosition.y + dy
            
            let position = CGPoint(x: currentX, y: currentY)
            action = SKAction.move(to: position, duration: duration)

            if translateTimeline["curve"].exists() {
                let curveInfo = translateTimeline["curve"].rawValue
                if curveInfo is NSString {
                    let curveString = curveInfo as! String
                    if curveString == "stepped" {
                        // stepped curve
                        action.timingMode = .easeIn
                    }
                } else if curveInfo is NSArray {
                    // bezier curve
                    action.timingMode = .easeInEaseOut
                }
            } else {
                // linear curve
                action.timingMode = .linear
            }
            translateActionSequence.append(action)
            
        }
        gabageTime = longestDuration - elapsedTime
        gabageAction = SKAction.wait(forDuration: gabageTime)
        translateActionSequence.append(gabageAction)
        let translateAction = SKAction.sequence(translateActionSequence)
        
        // Scale Action
        duration = 0
        elapsedTime = 0
        for (_, scaleTimeline):(String, JSON) in scaleTimelines {
            duration = TimeInterval(scaleTimeline["time"].doubleValue) - elapsedTime
            elapsedTime = TimeInterval(scaleTimeline["time"].doubleValue)
            
            let scaleX = CGFloat(scaleTimeline["x"].doubleValue)
            let scaleY = CGFloat(scaleTimeline["y"].doubleValue)
            action = SKAction.scaleX(to: scaleX, y: scaleY, duration: duration)

            if scaleTimeline["curve"].exists() {
                let curveInfo = scaleTimeline["curve"].rawValue
                if curveInfo is NSString {
                    let curveString = curveInfo as! String
                    if curveString == "stepped" {
                        // stepped curve
                        action.timingMode = .easeIn
                    }
                } else if curveInfo is NSArray {
                    // bezier curve
                    action.timingMode = .easeInEaseOut
                }
            } else {
                // linear curve
                action.timingMode = .linear
            }
            
            scaleActionSequence.append(action)
        }
        gabageTime = longestDuration - elapsedTime
        gabageAction = SKAction.wait(forDuration: gabageTime)
        scaleActionSequence.append(gabageAction)
        let scaleAction = SKAction.sequence(scaleActionSequence)
        
        
        let SRTActionGroup = [rotateAction, translateAction, scaleAction, noInheritRotAction]
        let finalActionSequence = [SKAction.unhide(), SKAction.group(SRTActionGroup)]
        
        self.SRTAction[animationName] = SKAction.sequence(finalActionSequence)
    }
    
    func runAnimation(_ animationName:String, count:Int) {
        
        self.removeAllActions()     // reset all actions first
        self.setToDefaults()
        
        let SRTAction = self.SRTAction[animationName]!
        if count <= -1 {
            let actionForever = SKAction.repeatForever(SRTAction)
            self.run(actionForever, withKey: animationName)
        } else {
            let repeatedAction = SKAction.repeat(SRTAction, count: count)
            self.run(repeatedAction, withKey: animationName)
        }
    }
    
    func runAnimationUsingQueue(_ animationName:String, count:Int, interval:TimeInterval, queuedAnimationName:String) {
        self.removeAllActions()     // reset all actions first
        self.setToDefaults()
        
        let SRTAction = self.SRTAction[animationName]!
        let repeatingAction = SKAction.repeat(SRTAction, count: count)
        if count <= -1 {
            let actionForever = SKAction.repeatForever(SRTAction)
            self.run(actionForever, withKey: animationName)
        } else  {
            self.run(repeatingAction, completion: { () -> Void in
                let actionSequence:Array<SKAction> = [
                    SKAction.run({ () -> Void in
                        self.setToDefaults()
                    }),
                    SKAction.wait(forDuration: interval),
                    SKAction.repeatForever(self.SRTAction[queuedAnimationName]!)
                    ]
                self.run(SKAction.sequence(actionSequence), withKey: animationName)
            })
        }
    }
    
    func stopAnimation() {
        self.removeAllActions()
    }
    
}















