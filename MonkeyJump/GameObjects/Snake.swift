//
//  Snake.swift
//  MonkeyJump
//
//  Original Objective-C Created by Kauserali on 18/11/13
//  Translated to Swift by Phil Eggel on 01/04/16
//  Copyright © 2016 PhilEagleDev.com. All rights reserved.
//


import Foundation

class Snake: GameElement {
    
    var walkAnim: SKAction!
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.gameElementType = .Snake
        self.walkAnim = self.loadPlistForAnimationName("walkAnim", andClassName: String(self.dynamicType))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}