//
//  GameMenuViewController.m
//  MonkeyJump
//
//  Created by Kauserali on 17/11/13.
//  Copyright (c) 2013 Raywenderlich. All rights reserved.
//

#import "GameMenuViewController.h"
#import "SKTAudio.h"

@implementation GameMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    if (![[SKTAudio sharedInstance] isBackgroundMusicPlaying]) {
        [[SKTAudio sharedInstance] playBackgroundMusic:@"background_track.aiff"];
    }
}

- (IBAction)newGameButtonPressed:(id)sender
{
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"GameViewController"] animated:YES];
}

- (IBAction)gameCenterButtonPressed:(id)sender
{
    NSLog(@"Game center button pressed");
}
@end
