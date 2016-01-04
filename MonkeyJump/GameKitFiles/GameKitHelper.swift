//
//  GameKitHelper.swift
//  MonkeyJump
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
}

extension GameKitHelperProtocol {
    // Use extension to declare a default func behavior instead
    // of making it optional
    func onAchievementsLoaded(achievements: [String: GKAchievement]) {}
    func onScoreSubmitted(success: Bool) {}
}


// MARK: -
class GameKitHelper: NSObject {

    // MARK: - class constants
    static let presentAuthenticationViewController = "present_authentication_view_controller"
    static let sharedInstance = GameKitHelper() // Singleton Pattern
    
    // MARK: - public properties
    var delegate: GameKitHelperProtocol?
    private(set) var authenticationViewController: UIViewController?
    
    // This property holds the last known error
    // that occured while using the Game Center API's
    private(set) var lastError: NSError?
    
    // It is possible to use setLastError because
    // GameKitHelper is not declared as @objc for the moment
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
    func showGameCenterViewController(controller: UIViewController) {
        
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
    
}

// MARK: - GKGameCenterControllerDelegate
extension GameKitHelper: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}