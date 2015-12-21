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
    func onAchievementsLoaded(achievements: NSDictionary)
}

extension GameKitHelperProtocol {
    // Use extension to declare a default func behavior instead
    // of making it optional
    func onAchievementsLoaded(achievements: NSDictionary) {}
}


// MARK: -
class GameKitHelper: NSObject {

    // MARK: - class constants
    static let presentAuthenticationViewController = "present_authentication_view_controller"
    static let sharedInstance = GameKitHelper() // Singleton Pattern
    
    // MARK: - public properties
    var delegate: GameKitHelperProtocol?
    private(set) var authentificationViewController: UIViewController? {
        didSet {
            if let _ = authentificationViewController {
                NSNotificationCenter.defaultCenter().postNotificationName(GameKitHelper.presentAuthenticationViewController, object: nil)
            }
        }
    }
    
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
    private(set) var achievements: NSMutableDictionary?

    
    // MARK: - private properties
    private var gameCenterFeaturesEnabled: Bool = false
    
    
    // MARK: - public methods
    func authenticateLocalPlayer() {
        
        let localPlayer = GKLocalPlayer()
        localPlayer.authenticateHandler = { [weak self] (viewController, error) -> Void in
            
            self?.setLastError(error)
            if let _ = viewController {
                
                self?.authentificationViewController = viewController
            
            } else if GKLocalPlayer.localPlayer().authenticated {
                
                self?.gameCenterFeaturesEnabled = true
                
            } else {
                
                self?.gameCenterFeaturesEnabled = false
                
            }
            
        }

    }

    func showGameCenterViewController(controller: UIViewController) {
        
        //1 create GameCenterViewController instance
        let gameCenterViewController = GKGameCenterViewController()
        
        //2 set gameCenterDelegate
        gameCenterViewController.gameCenterDelegate = self
        
        //3 view state, we can also show leaderboards, achievements or challenges
        gameCenterViewController.viewState = .Default
        
        //4 present the GameCenterViewController
        controller.presentViewController(gameCenterViewController, animated: true, completion: nil)
        
    }
    
}

// MARK: - GKGameCenterControllerDelegate
extension GameKitHelper: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

