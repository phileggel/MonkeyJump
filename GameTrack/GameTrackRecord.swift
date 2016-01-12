//
//  GameTrackRecord.swift
//  MonkeyJump
//
//  Created by philippe eggel on 12/01/2016.
//  Copyright © 2016 PhilEagleDev.com. All rights reserved.
//

import Foundation

class GameTrackRecord: NSObject {
    var randomSeed: UInt32
    var jumpTimingSinceStartOfGame: [NSTimeInterval]
    var hitTimingSinceStartOfGame: [NSTimeInterval]
    
    override init() {
        randomSeed = 1
        jumpTimingSinceStartOfGame = []
        hitTimingSinceStartOfGame = []
    }
    
    func addJumpTime(jumpTime: NSTimeInterval) {
        jumpTimingSinceStartOfGame.append(jumpTime)
    }
    
    func addHitTime(hitTime: NSTimeInterval) {
        hitTimingSinceStartOfGame.append(hitTime)
    }

    override var description: String {
        return
            "Jump times: \(jumpTimingSinceStartOfGame.description), " +
            "Hit times: \(hitTimingSinceStartOfGame.description), " +
            "Seed: \(randomSeed)"
    }
}

extension GameTrackRecord: NSCopying {
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = GameTrackRecord()
        copy.jumpTimingSinceStartOfGame = self.jumpTimingSinceStartOfGame
        copy.hitTimingSinceStartOfGame = self.hitTimingSinceStartOfGame
        copy.randomSeed = self.randomSeed
        
        return copy
    }
}
