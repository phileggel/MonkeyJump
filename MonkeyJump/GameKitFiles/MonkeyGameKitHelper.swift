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

import GameKit

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
    
    static func presentChallengeComposeControllerFromViewController(controller:UIViewController, leaderBoardID: String,
        withSelectedPlayers players: [GKPlayer], withScore score: Int64, message: String,
        gameTrackRecord: GameTrackRecord) {
        
            let challengeID = UInt64(arc4random_uniform(10000)) + 1
            HttpClient.sharedInstance.postGameTrackRecordDetails(gameTrackRecord, challengeID: challengeID) { (error) -> () in
                if let error = error {
                    print("Failed to send track record to server: \(error.localizedDescription)")
                }
                else {
                    GameKitHelper.sharedInstance.presentChallengeComposeControllerFromViewController(controller,
                        leaderBoardID: leaderBoardID, withSelectedPlayers: players, withScore: score,
                        message: message, context: challengeID)
                }
            }
    }

}