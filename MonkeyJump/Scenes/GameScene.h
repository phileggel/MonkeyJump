//
//  MyScene.h
//  MonkeyJump
//

//  Copyright (c) 2013 Raywenderlich. All rights reserved.
//

@import SpriteKit;

@protocol GameSceneProtocol <NSObject>
- (void)gameOverWithScore:(int)score;
@end

@interface GameScene : SKScene
@property (nonatomic, assign) id<GameSceneProtocol> gameSceneDelegate;
@end
