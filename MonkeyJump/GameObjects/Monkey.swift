//
//  Croc.swift
//  MonkeyJump
//
//  Original Objective-C Created by Kauserali on 18/11/13
//  Translated to Swift by Phil Eggel on 12/01/16
//  Copyright © 2016 PhilEagleDev.com. All rights reserved.
//

import Foundation

enum MonkeyState {
    case Idle, Walking, Jumping, Dead
}

class Monkey: GameElement {
    
    static let walkAnimationKey = "walkAnimation"
    static let jumpAnimationKey = "jumpAnimation"
    
    private var walkAnimation: SKAction!
    private var jumpAnimation: SKAction!
    
    var lives: Int
    var state: MonkeyState

    static let shareInstance = Monkey(imageNamed: "monkey_run1.png")
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        self.lives = 3
        self.state = .Idle
        
        super.init(texture: texture, color: color, size: size)
        self.gameElementType = .Monkey
        self.initAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initAnimations() {
        walkAnimation = loadPlistForAnimationName("walkAnim", andClassName: String(self.dynamicType))
        jumpAnimation = loadPlistForAnimationName("jumpAnim", andClassName: String(self.dynamicType))
    }
    
    private func setState(newState: MonkeyState) {
        if newState == state {
            return
        }
        
        state = newState
        
        var action: SKAction?
        var key: String?
        if state == .Walking {
            if let _ = actionForKey(Monkey.jumpAnimationKey) {
                removeActionForKey(Monkey.jumpAnimationKey)
            }
            action = SKAction.repeatActionForever(walkAnimation)
            key = Monkey.walkAnimationKey
        }
        else if state == .Jumping {
            if let _ = actionForKey(Monkey.walkAnimationKey) {
                removeActionForKey(Monkey.walkAnimationKey)
            }
            action = jumpAnimation
            key = Monkey.jumpAnimationKey
        }
        else if state == .Dead {
            removeAllActions()
            let gameAtlas = SKTextureAtlas(named: "characteranimations")
            texture = gameAtlas.textureNamed("monkey_dead.png")
        }
        
        if let action = action {
            runAction(action, withKey: key!)
        }
    }
}
