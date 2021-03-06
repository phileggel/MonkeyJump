//
//  GameOverViewController.swift
//  MonkeyJump
//
//  This controller present the GameOverScreen.
//  Buttons provide interactions to share score, challenge friends and go back to main menu
//
//  Created by philippe eggel on 22/12/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import UIKit
import GameKit

class GameOverViewController: UIViewController {

    // MARK: - class constants
    private static let challengeButtonTag = 1
    private static let mainMenuButtonTag = 2
    private static let shareButtonTag = 3
    static let storyboardID = "GameOverViewController"
    
    // MARK: - public properties
    @IBOutlet weak var scoreLabel: UILabel!

    
    // MARK: - private properties
    private var gameTrackRecord: GameTrackRecord!
    private var score: Int64!
    
    func setScore(score: Int64, gameTrackRecord: GameTrackRecord) {
        self.score = score
        self.gameTrackRecord = gameTrackRecord
        
        if let scoreLabel = scoreLabel {
            scoreLabel.text = "YOUR SCORE: \(score)"
        }
    }
    
    private var spinner: UIActivityIndicatorView!
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "YOUR SCORE: \(score)"
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
       
        switch sender.tag {
        case GameOverViewController.challengeButtonTag:
            challengeFriends()
        case GameOverViewController.mainMenuButtonTag:
            navigationController?.popToRootViewControllerAnimated(false)
        case GameOverViewController.shareButtonTag:
            GameKitHelper.sharedInstance.presentShareScoreControllerFromViewController(self, score: score,
                leaderBoardID: AppConstant.highScoreLeaderBoardID)
        default:
            fatalError("buttonPressed event not available")
        }
    }
    
    func challengeFriends() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.frame.origin = CGPoint(
            x: view.frame.size.width / 2 - spinner.frame.size.width / 2,
            y: view.frame.size.height / 2 - spinner.frame.size.height / 2)
        
        view.addSubview(spinner)
        spinner.startAnimating()
        
        let gameKitHelper = GameKitHelper.sharedInstance
        gameKitHelper.delegate = self
        gameKitHelper.findScoresOfFriendsToChallenge(AppConstant.highScoreLeaderBoardID)
    }
}

extension GameOverViewController: GameKitHelperProtocol {
    func onScoreOfFriendsToChallengeListReceived(scores: [GKScore]) {
        
        spinner.stopAnimating()
        var players: [GKPlayer] = []
        for gkScore in scores {
            if gkScore.value < score {
                players.append(gkScore.player)
            }
        }
        
        MonkeyGameKitHelper.presentChallengeComposeControllerFromViewController(self,
            leaderBoardID: AppConstant.highScoreLeaderBoardID, withSelectedPlayers: players, withScore: score,
            message: "Beat this!", gameTrackRecord: gameTrackRecord)
        
    }

}