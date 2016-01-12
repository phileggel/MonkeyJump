//
//  GameScene.swift
//  MonkeyJump
//
//  This is a main MonkeyJump's SpriteKit Game View
//  Game actions and interactions are provided here as well
//  as the drawing elements
//
//  Original GameScene from RayWenderlich Tutorial 
//  Translated to swift by philippe eggel on 21/12/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import SpriteKit

protocol GameSceneProtocol {
    func gameOverWithScore(score: Int64)
}
    
// MARK: -
class GameScene: SKScene {
    
    // MARK: - class constants
    private static let backgroundScrollSpeed: CGFloat = 170
    private static let monkeySpeed: CGFloat = 20
    
    private static let snakeEnemyType = 0
    private static let crocEnemyType = 1
    private static let hedgeHogEnemyType = 2
    
    
    // MARK: - public properties
    var gameSceneDelegate: GameSceneProtocol?
    
    
    // MARK: - private properties
    private var background1, background2: SKSpriteNode
    private var distanceLabel, livesLabel: SKLabelNode
    private var monkey: Monkey
    private var jumpSound: SKAction
    
    private var jumping = false
    private var isInvincible = false
    private var previousTime: NSTimeInterval = 0
    private var distance: CGFloat = 0
    private var nextSpawn: Double = 0
    private var difficultyMeasure: CGFloat = 1
    
    
    override init(size: CGSize) {
        
        jumpSound = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
        
        background1 = SKSpriteNode(imageNamed: "bg_repeat")
        background1.size = CGSize(width: background1.size.width, height: size.height)
        background1.position = CGPoint(x: background1.size.width / 2, y: size.height / 2)
        background1.zPosition = -1
        
        background2 = SKSpriteNode(imageNamed: "bg_repeat")
        background2.size = CGSize(width: background2.size.width, height: size.height)
        background2.position = CGPoint(x: background2.size.width + background2.size.width / 2, y: size.height / 2)
        background2.zPosition = -1
        
        monkey = Monkey.shareInstance
        monkey.position = CGPoint(x: 0.125 * size.width, y: 0.260 * size.height)
        
        distanceLabel = SKLabelNode(fontNamed: "Arial")
        distanceLabel.fontSize = 15
        distanceLabel.position = CGPoint(x: 50, y: size.height - 30)
        distanceLabel.fontColor = SKColor.whiteColor()
        distanceLabel.text = "Distance: 0"
        
        livesLabel = SKLabelNode(fontNamed: "Arial")
        livesLabel.fontSize = 15
        livesLabel.position = CGPoint(x: size.width - 50, y: size.height - 30)
        livesLabel.fontColor = SKColor.whiteColor()
        livesLabel.text = "Lives: \(monkey.lives)"

        super.init(size: size)
        
        addChild(background1)
        addChild(background2)
        addChild(monkey)
        addChild(distanceLabel)
        addChild(livesLabel)
        
        monkey.state = .Walking
        
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        if monkey.state == .Dead {
            return
        }
        
        if previousTime == 0 {
            previousTime = currentTime
        }
        
        let deltaTime = CGFloat(currentTime - previousTime)
        previousTime = currentTime
        let xOffset = GameScene.backgroundScrollSpeed * -1 * deltaTime
        
        if background1.position.x < (background1.size.width / 2) * -1 {
            background1.position = CGPoint(
                x: background2.position.x + background2.size.width / 2 + background1.size.width / 2,
                y: background1.position.y)
        }
        
        if background2.position.x < (background2.size.width / 2) * -1 {
            background2.position = CGPoint(
                x: background1.position.x + background1.size.width / 2 + background2.size.width / 2,
                y: background2.position.y)
        }
        
        background1.position = CGPoint(x: background1.position.x + xOffset, y: background1.position.y)
        background2.position = CGPoint(x: background2.position.x + xOffset, y: background2.position.y)
        
        distance += GameScene.monkeySpeed * deltaTime
        distanceLabel.text = "Distance: \(Int(distance))"
        
        let curTime = NSDate().timeIntervalSince1970
        if curTime > nextSpawn {
            let enemyType =  Int(arc4random_uniform(3))
            
            var enemySprite: SKSpriteNode
            switch enemyType {
            case GameScene.snakeEnemyType:
                enemySprite = Snake(imageNamed: "enemy_snake_crawl1.png")
                enemySprite.runAction(SKAction.repeatActionForever((enemySprite as! Snake).crawlAnim))
            case GameScene.crocEnemyType:
                enemySprite = Croc(imageNamed: "enemy_croc_walk1.png")
                enemySprite.runAction(SKAction.repeatActionForever((enemySprite as! Croc).walkAnim))
            case GameScene.hedgeHogEnemyType:
                enemySprite = HedgeHog(imageNamed: "enemy_hedgehog_walk1.png")
                enemySprite.runAction(SKAction.repeatActionForever((enemySprite as! HedgeHog).walkAnim))
            default:
                fatalError("ElementType not available")
            }
            
            enemySprite.position = CGPoint(x: scene!.size.width + enemySprite.size.width / 2, y: scene!.size.height * 0.22)
            enemySprite.runAction(SKAction.moveBy(CGVector(dx: -size.width - enemySprite.size.width, dy: 0), duration: 3)) {
                enemySprite.removeFromParent()
            }
            addChild(enemySprite)
            
            //permissible value between 4 & 1.8 1--->2.22
            let randomInterval = 4 / difficultyMeasure
            nextSpawn = curTime + Double(randomInterval)
            
            if difficultyMeasure < 2.22 {
                difficultyMeasure += 0.122
            }
        }
        
        if !isInvincible {
            
            for sprite in children {
                
                if sprite is Monkey {
                    
                    continue
                
                } else if sprite is Snake || sprite is Croc || sprite is HedgeHog {
                    
                    let insetAmtX: CGFloat = 10
                    let insetAmtY: CGFloat = 10
                    let enemyRect = CGRectInset(sprite.frame, insetAmtX, insetAmtY)
                    
                    if CGRectIntersectsRect(monkey.frame, enemyRect) {
                        
                        isInvincible = true
                        monkey.lives -= 1
                        livesLabel.text = "Lives: \(monkey.lives)"
                        
                        if monkey.lives <= 0 {
                            
                            monkey.position = CGPoint(x: scene!.size.width * 0.125, y: scene!.size.height * 0.271)
                            monkey.state = .Dead
                            userInteractionEnabled = false
                            
                            performSelector("monkeyDead", withObject: nil, afterDelay: 0.5)
                            return
                        
                        }
                    
                        runAction(SKAction.playSoundFileNamed("hurt.mp3", waitForCompletion: false))
                        
                        let fadeout = SKAction.fadeOutWithDuration(0.187)
                        let fadeint = fadeout.reversedAction()
                        let blinkAnimation = SKAction.sequence([fadeout, fadeint])
                        let repeatBlink = SKAction.repeatAction(blinkAnimation, count: 4)
                        
                        monkey.runAction(repeatBlink, completion: { [weak self] () -> Void in
                            self?.isInvincible = false
                            self?.monkey.state = .Walking
                        })
                        
                        break
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !jumping {
            
            jumping = true
            runAction(jumpSound)
            monkey.state = .Jumping
            
            let jumpUpAction = SKAction.moveByX(0, y: 120, duration: 0.6)
            let reverse = jumpUpAction.reversedAction()
            let action = SKAction.sequence([jumpUpAction, reverse])
            
            monkey.runAction(action, completion: { [weak self] () -> Void in
                self?.jumping = false
                self?.monkey.state = .Walking
            })
            
        }
    }
    
    
    func monkeyDead() {
        
        GameKitHelper.sharedInstance.submitScore(Int64(distance), leaderBoardID: AppConstant.highScoreLeaderBoardID)
        MonkeyGameKitHelper.reportAchievementsForDistance(Int64(distance))
        gameSceneDelegate?.gameOverWithScore(Int64(distance))

    }

}