//
//  Snake.m
//  MonkeyJump
//
//  Created by Kauserali on 18/11/13.
//  Copyright (c) 2013 Raywenderlich. All rights reserved.
//

#import "Snake.h"

@implementation Snake

- (id)initWithTexture:(SKTexture *)texture color:(UIColor *)color size:(CGSize)size
{
    self = [super initWithTexture:texture color:color size:size];
    if (self) {
        self.gameElementType = kSnake;
        [self setCrawlAnim:[self loadPlistForAnimationName:@"crawlAnim" andClassName:NSStringFromClass([self class])]];
    }
    return self;
}
@end
