//
//  Monkey.h
//  MonkeyJump
//
//  Created by Kauserali on 18/11/13.
//  Copyright (c) 2013 Raywenderlich. All rights reserved.
//

#import "GameElement.h"

NS_ENUM(NSUInteger, MonkeyState) {
    kIdle,
    kWalking,
    kJumping,
    kDead
};

@interface Monkey : GameElement

@property (nonatomic) int lives;
@property (nonatomic, readwrite) enum MonkeyState state;

+ (id)monkey;
@end
