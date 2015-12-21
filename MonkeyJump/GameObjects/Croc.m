//
//  Croc.m
//  MonkeyJump
//
//  Created by Kauserali on 18/11/13.
//  Copyright (c) 2013 Raywenderlich. All rights reserved.
//

#import "Croc.h"

@implementation Croc

- (id)initWithTexture:(SKTexture *)texture color:(UIColor *)color size:(CGSize)size
{
    self = [super initWithTexture:texture color:color size:size];
    if (self) {
        self.gameElementType = kCroc;
        [self setWalkAnim:[self loadPlistForAnimationName:@"walkAnim" andClassName:NSStringFromClass([self class])]];
    }
    return self;
}
@end
