//
//  GameOverViewController.m
//  MonkeyJump
//
//  Created by Kauserali on 17/11/13.
//  Copyright (c) 2013 Raywenderlich. All rights reserved.
//

#import "GameOverViewController.h"

#define kChallengeButtonTag 1
#define kMainMenuButtonTag 2
#define kShareButtonTag 3

@interface GameOverViewController()
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;
@end

@implementation GameOverViewController {
    int _score;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_scoreLabel setText:[NSString stringWithFormat:@"YOUR SCORE: %d", _score]];
}

- (void)setScore:(int)score
{
    _score = score;
    [_scoreLabel setText:[NSString stringWithFormat:@"YOUR SCORE: %d", score]];
}

- (IBAction)buttonPressed:(id)sender
{
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case kChallengeButtonTag:
            NSLog(@"Challenge friends button pressed");
            break;
        case kMainMenuButtonTag:
            [self.navigationController popToRootViewControllerAnimated:NO];
            break;
        case kShareButtonTag:
            NSLog(@"Share button pressed");
            break;
    }
}

@end
