//
//  GameElement.h
//  MonkeyJump
//
//  Created by Kauserali on 18/11/13.
//  Copyright (c) 2013 Raywenderlich. All rights reserved.
//

NS_ENUM(NSUInteger, GameElementType) {
    kMonkey,
    kSnake,
    kCroc,
    kHedgeHog
};

@import SpriteKit;

@interface GameElement : SKSpriteNode
@property (nonatomic, readwrite) enum GameElementType gameElementType;
- (SKAction*)loadPlistForAnimationName:(NSString*)animationName andClassName:(NSString*)className;
@end
