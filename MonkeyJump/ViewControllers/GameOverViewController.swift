//
//  GameOverViewController.swift
//  MonkeyJump
//
//  Created by philippe eggel on 22/12/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {

    // MARK: - class constants
    private static let challengeButtonTag = 1
    private static let mainMenuButtonTag = 2
    private static let shareButtonTag = 3
    static let storyboardID = "GameOverViewController"
    
    // MARK: - public properties
    @IBOutlet weak var scoreLabel: UILabel!

    
    // MARK: - private properties
    var score = 0 {
        willSet {
            scoreLabel.text = "YOUR SCORE: \(score)"
        }
    }
    
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "YOUR SCORE: \(score)"
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
       
        switch sender.tag {
        case GameOverViewController.challengeButtonTag:
            print("Challenge friends button pressed")
        case GameOverViewController.mainMenuButtonTag:
            navigationController?.popToRootViewControllerAnimated(false)
        case GameOverViewController.shareButtonTag:
            print("Share button pressed")
        default:
            fatalError("buttonPressed event not available")
        }
    }
    
}