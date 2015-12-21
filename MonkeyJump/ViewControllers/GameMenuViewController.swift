//
//  GameMenuViewController.swift
//  MonkeyJump
//
//  Created by philippe eggel on 21/12/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import UIKit

class GameMenuViewController: UIViewController {

    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBarHidden = true
        
        if !SKTAudio.sharedInstance().isBackgroundMusicPlaying() {
            SKTAudio.sharedInstance().playBackgroundMusic("background_track.aiff")
        }

    }

    
    // MARK: - User IBAction
    @IBAction func newGameButtonPressed(sender: UIButton) {
        navigationController?.pushViewController(storyboard!.instantiateViewControllerWithIdentifier("GameViewController"), animated: true)
    }

    @IBAction func gameCenterButtonPressed(sender: UIButton) {
        print("Game center button pressed")
    }
}
