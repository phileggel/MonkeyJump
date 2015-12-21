//
//  MyScene.m
//  MonkeyJump
//
//  Created by Kauserali on 17/11/13.
//  Copyright (c) 2013 Raywenderlich. All rights reserved.
//

#import "GameScene.h"
#import "Monkey.h"
#import "Snake.h"
#import "HedgeHog.h"
#import "Croc.h"

#define kBackgroundScrollSpeed 170
#define kMonkeySpeed 20

#define kSnakeEnemyType 0
#define kCrocEnemyType 1
#define kHedgeHogEnemyType 2

@implementation GameScene {
    SKSpriteNode *_background1, *_background2;
    CFTimeInterval _previousTime;
    Monkey *_monkey;
    BOOL _jumping, _isInvincible;
    SKAction *_jumpSound;
    CGFloat _distance;
    double _nextSpawn;
    CGFloat _difficultyMeasure;
    
    SKLabelNode *_distanceLabel, *_livesLabel;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        _jumpSound = [SKAction playSoundFileNamed:@"jump.wav" waitForCompletion:NO];
        _difficultyMeasure = 1;
        
        _background1 = [SKSpriteNode spriteNodeWithImageNamed:@"bg_repeat"];
        _background1.size = CGSizeMake(_background1.size.width, size.height);
        _background1.position = CGPointMake(_background1.size.width/2, size.height/2);
        [self addChild:_background1];
        
        _background2 = [SKSpriteNode spriteNodeWithImageNamed:@"bg_repeat"];
        _background2.size = CGSizeMake(_background2.size.width, size.height);
        _background2.position = CGPointMake(_background2.size.width + _background2.size.width/2, size.height/2);
        [self addChild:_background2];
        
        _monkey = [Monkey monkey];
        _monkey.position = CGPointMake(0.125 * size.width, 0.260 * size.height);
        
        [self addChild:_monkey];
        
        [_monkey setState:kWalking];
        
        _distanceLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        _distanceLabel.fontSize = 15.0f;
        _distanceLabel.position = CGPointMake(50, size.height - 30);
        _distanceLabel.fontColor = [SKColor whiteColor];
        _distanceLabel.text = @"Distance:0";
        [self addChild:_distanceLabel];

        _livesLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        _livesLabel.fontSize = 15.0f;
        _livesLabel.position = CGPointMake(size.width - 50, size.height - 30);
        _livesLabel.fontColor = [SKColor whiteColor];
        _livesLabel.text = [NSString stringWithFormat:@"Lives:%d", _monkey.lives];
        [self addChild:_livesLabel];
        
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

-(void)update:(CFTimeInterval)currentTime
{
    if (_monkey.state == kDead) {
        NSLog(@"Monkey dead");
        return;
    }
    if (_previousTime == 0) {
        _previousTime = currentTime;
    }
    CFTimeInterval deltaTime = currentTime - _previousTime;
    _previousTime = currentTime;
    CGFloat xOffset = kBackgroundScrollSpeed * (-1) * deltaTime;
    
    if (_background1.position.x < (_background1.size.width/2 * -1)) {
        _background1.position = CGPointMake((_background2.position.x + _background2.size.width/2) + _background1.size.width/2, _background1.position.y);
    }
    if (_background2.position.x < (_background2.size.width/2 * -1)) {
        _background2.position = CGPointMake((_background1.position.x + _background1.size.width/2) + _background2.size.width/2, _background2.position.y);
    }
    _background1.position = CGPointMake(_background1.position.x + xOffset, _background1.position.y);
    _background2.position = CGPointMake(_background2.position.x + xOffset, _background2.position.y);
    
    _distance += kMonkeySpeed * deltaTime;
    [_distanceLabel setText:[NSString stringWithFormat:@"Distance:%d", (int)_distance]];
    
    double curTime = [[NSDate date] timeIntervalSince1970];
    if (curTime > _nextSpawn) {
        int enemyType = arc4random() % 3;
        
        SKSpriteNode *enemySprite;
        
        if (enemyType == kSnakeEnemyType) {
            enemySprite = [Snake spriteNodeWithImageNamed:@"enemy_snake_crawl1.png"];
            [enemySprite runAction:[SKAction repeatActionForever:((Snake*)enemySprite).crawlAnim]];
        } else if(enemyType == kCrocEnemyType) {
            enemySprite = [Croc spriteNodeWithImageNamed:@"enemy_croc_walk1.png"];
            [enemySprite runAction:[SKAction repeatActionForever:((Croc*)enemySprite).walkAnim]];
        } else if(enemyType == kHedgeHogEnemyType) {
            enemySprite = [HedgeHog spriteNodeWithImageNamed:@"enemy_hedgehog_walk1.png"];
            [enemySprite runAction:[SKAction repeatActionForever:((HedgeHog*)enemySprite).walkAnim]];
        }
        enemySprite.position = CGPointMake(self.scene.size.width + enemySprite.size.width/2, 0.22 * self.scene.size.height);
        
        [enemySprite runAction:[SKAction moveBy:CGVectorMake(-self.size.width - enemySprite.size.width, 0) duration:3] completion:^(){
            [enemySprite removeFromParent];
        }];
        [self addChild:enemySprite];
        
        float randomInterval = 4/_difficultyMeasure; //permissible value between 4 & 1.8 1--->2.22
        _nextSpawn = curTime + randomInterval;
        
        if (_difficultyMeasure < 2.22) {
            _difficultyMeasure = _difficultyMeasure + 0.122;
        }
    }
    
    if (!_isInvincible) {
        for (SKSpriteNode *sprite in self.children) {
            if ([sprite isKindOfClass:[Monkey class]])
                continue;
            else if ([sprite isKindOfClass:[Snake class]] || [sprite isKindOfClass:[Croc class]] || [sprite isKindOfClass:[HedgeHog class]]){
                float insetAmtX = 10;
                float insetAmtY = 10;
                CGRect enemyRect = CGRectInset(sprite.frame, insetAmtX, insetAmtY);
                if (CGRectIntersectsRect(_monkey.frame, enemyRect)) {
                    _isInvincible = YES;
                    _monkey.lives -= 1;
                    
                    [_livesLabel setText:[NSString stringWithFormat:@"Lives:%d", _monkey.lives]];
                    if (_monkey.lives <= 0) {
                        _monkey.position = CGPointMake(0.125 * self.scene.size.width, 0.271 * self.scene.size.height);
                        [_monkey setState:kDead];
                        self.userInteractionEnabled = NO;
                        
                        [self performSelector:@selector(monkeyDead) withObject:nil afterDelay:0.5];
                        return;
                    }
                    
                    [self runAction:[SKAction playSoundFileNamed:@"hurt.mp3" waitForCompletion:NO]];
                    
                    SKAction *fadeout = [SKAction fadeOutWithDuration:0.187f];
                    SKAction *fadeIn = [fadeout reversedAction];
                    SKAction *blinkAnimation = [SKAction sequence:@[fadeout, fadeIn]];
                    SKAction *repeatBlink = [SKAction repeatAction:blinkAnimation count:4];
                    [_monkey runAction:repeatBlink completion:^(){
                        _isInvincible = NO;
                        [_monkey setState:kWalking];
                    }];
                    
                    break;
                }
            }
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_jumping) {
        _jumping = YES;
        [self runAction:_jumpSound];
        [_monkey setState:kJumping];
        
        SKAction *jumpUpAction = [SKAction moveByX:0 y:120 duration:0.6];
        SKAction *reverse = [jumpUpAction reversedAction];
        SKAction *action = [SKAction sequence:@[jumpUpAction, reverse]];
        [_monkey runAction:action completion:^(){
            _jumping = NO;
            [_monkey setState:kWalking];
        }];
    }
}

- (void)monkeyDead
{
    [self.gameSceneDelegate gameOverWithScore:_distance];
}
@end
