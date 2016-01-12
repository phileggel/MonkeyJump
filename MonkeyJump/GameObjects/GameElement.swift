//
//  GameElement.swift
//  MonkeyJump
//
//  Original Objective-C Created by Kauserali on 18/11/13
//  Translated to Swift by Phil Eggel on 12/01/16
//  Copyright © 2016 PhilEagleDev.com. All rights reserved.
//

import SpriteKit

enum GameElementType {
    case Monkey, Snake, Croc, HedgeHog
}

class GameElement: SKSpriteNode {
    
    var gameElementType: GameElementType?
    
    func loadPlistForAnimationName(animationName: String, andClassName className: String) -> SKAction? {

        let fullFileName = className + ".plist"
        
        // 1: Get the Path to the plist file
        let rootPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString
        var plistPath = rootPath.stringByAppendingPathComponent(fullFileName)
        if !NSFileManager.defaultManager().fileExistsAtPath(plistPath) {
            plistPath = NSBundle.mainBundle().pathForResource(className, ofType: "plist")!
        }
    
        // 2: Read in the plist file and 3: test if the plistDictionary was null, the file was not found.
        guard let plistDictionary = NSDictionary(contentsOfFile: plistPath) else {
            print("Error reading plist: \(className).plist")
            return nil; // No Plist Dictionary or file found
        }
    
        // 4: Get just the mini-dictionary for this animation
        guard let animationSettings = plistDictionary[animationName] as? [String: String] else {
            print("Could not locate AnimationWithName: \(animationName)")
            return nil;
        }
    
        // 5: Get the delay value for the animation
        let animationDelay = Double(animationSettings["delay"]!)!
    
        // 6: Add the frames to the animation
        let animationFramePrefix = animationSettings["filenamePrefix"]!
        let animationFrames = animationSettings["animationFrames"]!
        let animationFrameNumbers = animationFrames.componentsSeparatedByString(",")
    
        var atlasName = "characteranimations"
        if isLargeScreen() && isRetina() {
            atlasName = atlasName + "@3x"
        }
        else if isRetina() {
            atlasName = atlasName + "@2x"
        }

        let gameAtlas = SKTextureAtlas(named: atlasName)
        
        var textures: [SKTexture] = []
        for frameNumber in animationFrameNumbers {
            let frameName = animationFramePrefix.stringByAppendingString(frameNumber)
            textures.append(gameAtlas.textureNamed(frameName))
        }
        
        return SKAction.animateWithTextures(textures, timePerFrame: animationDelay)
    }
    
    func isLargeScreen() -> Bool {
        // return true if the device has a large screen (>= 736)
        return max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height) >= 736
    }
    
    func isRetina() -> Bool {
        // return true if the device is retina 2x (or 3x)
        return UIScreen.mainScreen().scale > 1.9
    }
    
}