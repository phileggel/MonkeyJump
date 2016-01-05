//
//  GameKitHelper.swift
//  MonkeyJump
//
//  This is a generic GameKit helper class.
//  It is not tied to the Monkey Game Model, and then can be used with any other game models.
//
//  It provides some useful methods to interact with GameKit framework.
//  It also provides a protocol wrapper for callback Methods
//  and use notification to notify the authentication controller availability.
//
//  Created by philippe eggel on 21/12/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import UIKit
import GameKit

// MARK: -
protocol GameKitHelperProtocol {
    // Optional protocol only available with @objc
    func onAchievementsLoaded(achievements: [String: GKAchievement])
    func onAchievementsReported(achievement: GKAchievement)
    func onScoreSubmitted(success: Bool)
    func onScoreOfFriendsToChallengeListReceived(scores: [GKScore])
}

extension GameKitHelperProtocol {
    // Use extension to declare a default func behavior instead
    // of making it optional
    func onAchievementsLoaded(achievements: [String: GKAchievement]) {}
    func onAchievementsReported(achievement: GKAchievement) {}
    func onScoreSubmitted(success: Bool) {}
    func onScoreOfFriendsToChallengeListReceived(scores: [GKScore]) {}
}


// MARK: -
class GameKitHelper: NSObject {

    // MARK: - class constants
    static let presentAuthenticationViewController = "present_authentication_view_controller"
    static let sharedInstance = GameKitHelper() // Singleton Pattern
    
    // MARK: - public properties
    var delegate: GameKitHelperProtocol?
    var includeLocalPlayerScore: Bool = false
    
    // This property holds the authenticationViewController provided by the Game Center API's
    private(set) var authenticationViewController: UIViewController?
    
    // This property holds the last known error that occured while using the Game Center API's
    private(set) var lastError: NSError?
    
    // It is possible to use setLastError because
    // GameKitHelper is not declared as @objc for the moment
    // TODO: modify this implementation to make it more readable
    private func setLastError(error: NSError?) {
        lastError = error?.copy() as? NSError
        if let lastError = lastError {
            print("GameKitHelper ERROR: \(lastError.userInfo.description)")
        }
    }
    
    // This property holds Game Center achievements
    private(set) var achievements: [String: GKAchievement]?

    
    // MARK: - private properties
    private var gameCenterFeaturesEnabled: Bool = false
    
    
    // MARK: - main methods
    
    /// Authenticate the local player
    func authenticateLocalPlayer() {
        
        let localPlayer = GKLocalPlayer()
        localPlayer.authenticateHandler = { [weak self] (controller, error) -> Void in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.setLastError(error)
            
            if let _ = controller {
                strongSelf.authenticationViewController = controller
                strongSelf.notifyAskForAuthentication()
            }
            else if GKLocalPlayer.localPlayer().authenticated {
                strongSelf.gameCenterFeaturesEnabled = true
                strongSelf.loadAchievements()
            }
            else {
                strongSelf.gameCenterFeaturesEnabled = false
            }
            
        }

    }
    
    private func notifyAskForAuthentication() {
        if let _ = authenticationViewController {
            NSNotificationCenter.defaultCenter().postNotificationName(GameKitHelper.presentAuthenticationViewController, object: nil)
        }
    }
    
    private func loadAchievements() {
        guard gameCenterFeaturesEnabled else {
            print("Player not authenticated!")
            return
        }
        
        GKAchievement.loadAchievementsWithCompletionHandler { [weak self] (loadedAchievements, error) -> Void in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.setLastError(error)
            
            // populates achievements
            strongSelf.achievements = [:]
            if let loadedAchievements = loadedAchievements {
                for achievement in loadedAchievements {
                    if let identifier = achievement.identifier {
                        achievement.showsCompletionBanner = true
                        strongSelf.achievements![identifier] = achievement
                    }
                }
            }
            
            strongSelf.delegate?.onAchievementsLoaded(strongSelf.achievements!)
        }
    }
    
    /// Show Game Center
    func presentGameCenterViewControllerFromViewController(controller: UIViewController) {
        
        //1 Create GameCenterViewController instance
        let gameCenterViewController = GKGameCenterViewController()
        
        //2 Set gameCenterDelegate
        gameCenterViewController.gameCenterDelegate = self
        
        //3 View state, we can also show leaderboards, achievements or challenges
        gameCenterViewController.viewState = .Default
        
        //4 Present the GameCenterViewController
        controller.presentViewController(gameCenterViewController, animated: true, completion: nil)
        
    }
    
    /// Scores
    func submitScore(score: Int64, leaderBoardID: String) {
        guard gameCenterFeaturesEnabled else {
            print("Player not authenticated!")
            return
        }
        
        //2 Create a GKScore object
        let gkScore = GKScore(leaderboardIdentifier: leaderBoardID)
        
        //3 Set the score value
        gkScore.value = score
        gkScore.context = 0
        
        //4 Send the score to Game Center
        GKScore.reportScores([gkScore]) { [weak self] (error) -> Void in
            
            self?.setLastError(error)
            let success = (error == nil)
            
            self?.delegate?.onScoreSubmitted(success)
        }
    }
    
    /// Report Achievements
    func reportAchievementsWithID(identifier: String, percentComplete percent: Double) {
        guard gameCenterFeaturesEnabled else {
            print("Player not authenticated!")
            return
        }
        
        if let achievement = getAchievementByID(identifier) where achievement.percentComplete < percent  {
            
            achievement.percentComplete = percent
            
            GKAchievement.reportAchievements([achievement], withCompletionHandler: { [weak self] (error) -> Void in
                self?.setLastError(error)
                self?.delegate?.onAchievementsReported(achievement)
            })
        }
    }
    
    private func getAchievementByID(identifier: String) -> GKAchievement? {
        guard let _ = achievements else {
            return nil
        }
        
        var foundAchievememt: GKAchievement
        if let achievement = achievements![identifier] {
            foundAchievememt = achievement
        }
        else {
            foundAchievememt = GKAchievement(identifier: identifier)
            foundAchievememt.showsCompletionBanner = true
            achievements![identifier] = foundAchievememt
        }
        
        return foundAchievememt
    }
    
    
    /// Share Score on Social Networks
    func presentShareScoreControllerFromViewController(controller: UIViewController, score: Int64, leaderBoardID: String) {
        
        let gkScore = GKScore(leaderboardIdentifier: leaderBoardID)
        gkScore.value = score
        
        let shareScoreViewController = UIActivityViewController(activityItems: [gkScore], applicationActivities: nil)
        
        // use of another method than tutorial because the previous tutorial shorter method was deprecated
        // the activityViewController is a highlevel interface which provide the ability to share items
        // but also to interact with other installed applications
        // In the later case we may receive modified datas through the returnedItems array
        // 
        // activityViewController is weak to prevent owning cycle. The owner will be the current controller
        // if it is dismiss, the activityViewController should be dismissed by its parent
        shareScoreViewController.completionWithItemsHandler = { [weak shareScoreViewController]
            (activityType, completed, returnedItems, error) -> Void in
            
            if completed {
                shareScoreViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        controller.presentViewController(shareScoreViewController, animated: true, completion: nil)
    }
 
    
    /// Challenge Score Features
    func findScoresOfFriendsToChallenge(leaderBoardID: String) {
        
        let leaderBoard = GKLeaderboard()
        leaderBoard.identifier = leaderBoardID
        leaderBoard.playerScope = .FriendsOnly
        leaderBoard.range = NSRange(location: 1, length: 100)
        
        leaderBoard.loadScoresWithCompletionHandler { [weak self] (scores, error) -> Void in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.setLastError(error)
            guard let scores = scores where error == nil else {
                return
            }
                
            var friendsScores: [GKScore]
            if !strongSelf.includeLocalPlayerScore {
                friendsScores = scores.filter({ (score) -> Bool in
                    score.player.playerID != GKLocalPlayer.localPlayer().playerID
                })
            }
            else {
                friendsScores = scores
            }
                
            strongSelf.delegate?.onScoreOfFriendsToChallengeListReceived(friendsScores)
            
        }
    }
    
    func presentChallengeComposeControllerFromViewController(controller:UIViewController, leaderBoardID: String,
        withSelectedPlayers players: [GKPlayer], withScore score: Int64, message: String)
    {
        let gkScore = GKScore(leaderboardIdentifier: leaderBoardID)
        gkScore.value = score
        
        let challengeComposeController = gkScore.challengeComposeControllerWithMessage(message, players: players) {
            (composeController, didIssueChallenge, sentPlayerIDs) -> Void in
            composeController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        controller.presentViewController(challengeComposeController, animated: true, completion: nil)
        
    }
}

// MARK: - GKGameCenterControllerDelegate
extension GameKitHelper: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}