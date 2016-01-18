//
//  GameMenuViewController.swift
//  MonkeyJump
//
//  Created by philippe eggel on 21/12/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import GameKit

class GameMenuViewController: UIViewController {

    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBarHidden = true
        
        if !MonkeyAudio.sharedInstance.backgroundMusicPlaying {
            MonkeyAudio.sharedInstance.playBackgroundMusic("background_track.aiff")
        }
    }

    
    // MARK: - User IBAction
    @IBAction func newGameButtonPressed(sender: UIButton) {
        navigationController?.pushViewController(storyboard!.instantiateViewControllerWithIdentifier("GameViewController"), animated: true)
    }

    @IBAction func gameCenterButtonPressed(sender: UIButton) {
        GameKitHelper.sharedInstance.presentGameCenterViewControllerFromViewController(self)
    }
    
    @IBAction func challengesReceivedButtonPressed(sender: UIButton) {
        let challengeViewController = ChallengesPickerViewController(nibName: "ChallengesPickerViewController", bundle: nil)
        
        challengeViewController.challengeCanceledBlock = {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        challengeViewController.challengeSelectedBlock = { (challenge: GKScoreChallenge) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            
            let gameViewController = self.storyboard?.instantiateViewControllerWithIdentifier(GameViewController.storyboardID) as! GameViewController
            if challenge.score!.context != 0 {
                HttpClient.sharedInstance.getGameTrackRecordDetailsForKey(challenge.score!.context, completionHandler: { (response, error) -> () in
                    if error == nil {
                        gameViewController.gameTrackRecord = response
                        self.navigationController?.pushViewController(gameViewController, animated: true)
                    }
                    else {
                        self.navigationController?.pushViewController(gameViewController, animated: true)
                    }
                })
                
            } else {
                self.navigationController?.pushViewController(gameViewController, animated: true)
            }
        }
        
        let nc = UINavigationController(rootViewController: challengeViewController)
        presentViewController(nc, animated: true, completion: nil)
    }
}
