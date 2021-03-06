//
//  Snake.swift
//  MonkeyJump
//
//  Original Objective-C Created by Kauserali on 18/11/13
//  Translated to Swift by Phil Eggel on 04/01/16
//  Copyright © 2016 PhilEagleDev.com. All rights reserved.
//


import SpriteKit

class Snake: GameElement {
    
    var crawlAnim: SKAction!
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.gameElementType = .Snake
        self.crawlAnim = self.loadPlistForAnimationName("crawlAnim", andClassName: String(self.dynamicType))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}