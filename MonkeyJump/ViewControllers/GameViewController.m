//
//  ViewController.m
//  MonkeyJump
//
//  Created by Kauserali on 17/11/13.
//  Copyright (c) 2013 Raywenderlich. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "GameOverViewController.h"

@interface GameViewController()<GameSceneProtocol>

@end

@implementation GameViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        skView.ignoresSiblingOrder = YES;
        
        GameScene * scene = [GameScene sceneWithSize:skView.bounds.size];
        scene.gameSceneDelegate = self;
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        [skView presentScene:scene];
    }
}

#pragma mark GameScene delegate

- (void)gameOverWithScore:(int)score
{
    GameOverViewController *gameOverViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameOverViewController"];
    [gameOverViewController setScore:score];
    [self.navigationController pushViewController:gameOverViewController animated:NO];
}
@end
