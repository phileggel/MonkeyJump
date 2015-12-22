//
//  Monkey.m
//  MonkeyJump
//
//  Created by Kauserali on 18/11/13.
//  Copyright (c) 2013 Raywenderlich. All rights reserved.
//

#import "Monkey.h"

#define kWalkAnimationKey @"walkAnimation"
#define kJumpAnimationKey @"jumpAnimation"

@implementation Monkey {
    SKAction *_walkAnimation, *_jumpAnimation;
}

+(instancetype)monkey {
    Monkey *monkey = [Monkey spriteNodeWithImageNamed:@"monkey_run1.png"];
    return monkey;
}

- (id)initWithTexture:(SKTexture *)texture color:(UIColor *)color size:(CGSize)size
{
    self = [super initWithTexture:texture color:color size:size];
    if (self) {
        self.gameElementType = kMonkey;
        self.lives = 3;
        [self initAnimations];
    }
    return self;
}

- (void)initAnimations
{
    _walkAnimation = [self loadPlistForAnimationName:@"walkAnim" andClassName:NSStringFromClass([self class])];
    _jumpAnimation = [self loadPlistForAnimationName:@"jumpAnim" andClassName:NSStringFromClass([self class])];
}

- (void)setState:(enum MonkeyState)state
{
    if (_state == state) {
        return;
    }
    _state = state;
    SKAction *action = nil;
    NSString *key;
    if (state == kWalking) {
        if ([self actionForKey:kJumpAnimationKey]) {
            [self removeActionForKey:kJumpAnimationKey];
        }
        action = [SKAction repeatActionForever:_walkAnimation];
        key = kWalkAnimationKey;
    } else if(state == kJumping) {
        if ([self actionForKey:kWalkAnimationKey]) {
            [self removeActionForKey:kWalkAnimationKey];
        }
        action = _jumpAnimation;
        key = kJumpAnimationKey;
    } else if(state == kDead) {
        [self removeAllActions];
        SKTextureAtlas *gameAtlas = [SKTextureAtlas atlasNamed:@"characteranimations"];
        [self setTexture:[gameAtlas textureNamed:@"monkey_dead.png"]];
    }
    if (action != nil) {
        [self runAction:action withKey:key];
    }
}
@end
