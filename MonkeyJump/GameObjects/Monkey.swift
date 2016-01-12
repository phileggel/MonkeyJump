//
//  Croc.swift
//  MonkeyJump
//
//  Original Objective-C Created by Kauserali on 18/11/13
//  Translated to Swift by Phil Eggel on 12/01/16
//  Copyright © 2016 PhilEagleDev.com. All rights reserved.
//

import SpriteKit

enum MonkeyState {
    case Idle, Walking, Jumping, Dead
}

class Monkey: GameElement {
    
    static let walkAnimationKey = "walkAnimation"
    static let jumpAnimationKey = "jumpAnimation"
    
    private var walkAnimation: SKAction!
    private var jumpAnimation: SKAction!
    
    var lives: Int
    var state: MonkeyState {
        didSet {
            if oldValue != state {
                selectCurrentAction()
            }
        }
    }
    
    private func selectCurrentAction() {
        
        switch state {
        case .Walking:
            if let _ = actionForKey(Monkey.jumpAnimationKey) {
                removeActionForKey(Monkey.jumpAnimationKey)
            }
            runAction(SKAction.repeatActionForever(walkAnimation), withKey: Monkey.walkAnimationKey)
        
        case .Jumping:
            if let _ = actionForKey(Monkey.walkAnimationKey) {
                removeActionForKey(Monkey.walkAnimationKey)
            }
            runAction(jumpAnimation, withKey: Monkey.jumpAnimationKey)
        
        case .Dead:
            removeAllActions()
            let gameAtlas = SKTextureAtlas(named: "characteranimations")
            texture = gameAtlas.textureNamed("monkey_dead.png")
        
        case .Idle:
            break
        }
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        self.lives = 3
        self.state = .Idle
        
        super.init(texture: texture, color: color, size: size)
        self.gameElementType = .Monkey
        self.walkAnimation = loadPlistForAnimationName("walkAnim", andClassName: String(self.dynamicType))
        self.jumpAnimation = loadPlistForAnimationName("jumpAnim", andClassName: String(self.dynamicType))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
