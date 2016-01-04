//
//  MonkeyGameKitHelper.swift
//  MonkeyJump
//
//  Custom GameKit Helper Methods tied to Monkey Jump Model
//  Another solution would have to inherit from GameKitHelper
//  And then provides custom methods inside it.
//  However, I would have to transfer all GameKitHelper calls to MonkeyGameKitHelper
//  Tutorials was not finish so I prefer to stick to the tutorial original design
//
//  Created by philippe eggel on 04/01/2016.
//  Copyright © 2016 PhilEagleDev.com. All rights reserved.
//

import Foundation

class MonkeyGameKitHelper {
    
    static func reportAchievementsForDistance(distance: Int64) {
        
        let rootPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        
        var plistPath = rootPath.stringByAppendingPathComponent(AppConstant.achievementsFilename)
        if !NSFileManager.defaultManager().fileExistsAtPath(plistPath) {
            plistPath = NSBundle.mainBundle().pathForResource(AppConstant.achievementsResourceName, ofType: "plist")!
        }
        
        guard let achievements = NSArray(contentsOfFile: plistPath) as? [[String: String]] else {
            print("Error while reading plist: \(AppConstant.achievementsFilename)")
            return
        }
        
        for details in achievements {
            
            if let
                achievementID = details["achievementID"],
                distanceToRunString = details["distanceToRun"],
                distanceToRun = Double(distanceToRunString) {
                    
                    var percentComplete = (Double(distance) / distanceToRun) * 100
                    if percentComplete > 100 {
                        percentComplete = 100
                    }
                
                    GameKitHelper.sharedInstance.reportAchievementsWithID(achievementID,
                        percentComplete: percentComplete)
            }
            
        }
    }

}