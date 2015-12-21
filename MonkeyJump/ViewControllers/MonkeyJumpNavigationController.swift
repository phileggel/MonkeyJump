//
//  MonkeyJumpNavigationController.swift
//  MonkeyJump
//
//  Created by philippe eggel on 21/12/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import UIKit

class MonkeyJumpNavigationController: UINavigationController {

    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAuthenticationViewController", name: GameKitHelper.presentAuthenticationViewController, object: nil)
        
        GameKitHelper.sharedInstance.authenticateLocalPlayer()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func showAuthenticationViewController() {
        let gameKitHelper = GameKitHelper.sharedInstance
        
        topViewController?.presentViewController(gameKitHelper.authentificationViewController!, animated: true, completion: nil)
    }
}
