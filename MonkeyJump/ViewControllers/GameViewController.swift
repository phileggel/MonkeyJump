//
//  GameViewController.swift
//  MonkeyJump
//
//  Created by philippe eggel on 22/12/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import SpriteKit

class GameViewController: UIViewController {

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let skView = (view as! SKView)
        
        if skView.scene == nil {
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            
            let scene = GameScene(size: skView.bounds.size)
            scene.gameSceneDelegate = self
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }

    }
}

extension GameViewController: GameSceneProtocol {
    
    func gameOverWithScore(score: Int64) {
        let gameOverViewController = storyboard!.instantiateViewControllerWithIdentifier(GameOverViewController.storyboardID) as! GameOverViewController
        gameOverViewController.score = score
        navigationController?.pushViewController(gameOverViewController, animated: false)
    }
    
}