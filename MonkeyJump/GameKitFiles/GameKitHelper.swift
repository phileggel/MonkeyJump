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
class GameKitHelper {

    // MARK: - class constants
    static let presentAuthentificationViewController = "present_authentification_view_controller"
    
    // MARK: - public properties
    var delegate: GameKitHelperProtocol?
    private(set) var authentificationViewController: UIViewController?
    
    // This property holds the last known error
    // that occured while using the Game Center API's
    private(set) var lastError: NSError?
    
    // This property holds Game Center achievements
    private(set) var achievements: NSMutableDictionary?
    
    // Singleton Pattern
    let sharedInstance = GameKitHelper()
    
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
    
    // It is possible to use setLastError because
    // GameKitHelper is not declared as @objc for the moment
    private func setLastError(error: NSError?) {
        lastError = error?.copy() as? NSError
        if let lastError = lastError {
            print("GameKitHelper ERROR: \(lastError.userInfo.description)")
        }
    }
}


