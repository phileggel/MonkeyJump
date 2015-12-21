//
//  GameElement.m
//  MonkeyJump
//
//  Created by Kauserali on 18/11/13.
//  Copyright (c) 2013 Raywenderlich. All rights reserved.
//

#import "GameElement.h"

@implementation GameElement

- (SKAction*)loadPlistForAnimationName:(NSString*)animationName andClassName:(NSString*)className
{
    NSString *fullFileName = [NSString stringWithFormat:@"%@.plist",className];
    NSString *plistPath;
    
    // 1: Get the Path to the plist file
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES)[0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle]
                     pathForResource:className ofType:@"plist"];
    }
    
    // 2: Read in the plist file
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3: If the plistDictionary was null, the file was not found.
    if (plistDictionary == nil) {
        NSLog(@"Error reading plist: %@.plist", className);
        return nil; // No Plist Dictionary or file found
    }
    
    // 4: Get just the mini-dictionary for this animation
    NSDictionary *animationSettings = plistDictionary[animationName];
    if (animationSettings == nil) {
        NSLog(@"Could not locate AnimationWithName:%@",animationName);
        return nil;
    }
    
    // 5: Get the delay value for the animation
    float animationDelay = [animationSettings[@"delay"] floatValue];
    
    // 6: Add the frames to the animation
    NSString *animationFramePrefix = animationSettings[@"filenamePrefix"];
    NSString *animationFrames = animationSettings[@"animationFrames"];
    NSArray *animationFrameNumbers = [animationFrames componentsSeparatedByString:@","];
    
    NSMutableArray *textures;
    
    NSString *atlasName = @"characteranimations";
    
    if (IS_RETINA) {
        atlasName = [NSString stringWithFormat:@"%@@2x", atlasName];
    }
    if (IS_IPHONE_6P) {
        atlasName = [NSString stringWithFormat:@"%@@3x", atlasName];
    }
    
    SKTextureAtlas *gameAtlas = [SKTextureAtlas atlasNamed:atlasName];
    for (NSString *frameNumber in animationFrameNumbers) {
        if (!textures) {
            textures = [NSMutableArray array];
        }
        NSString *frameName = [NSString stringWithFormat:@"%@%@", animationFramePrefix,frameNumber];
        [textures addObject:[gameAtlas textureNamed:frameName]];
    }
    return [SKAction animateWithTextures:textures timePerFrame:animationDelay];
}
@end
