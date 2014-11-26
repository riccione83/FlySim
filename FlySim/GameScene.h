//
//  GameScene.h
//  FlySim
//

//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate> {
    CFTimeInterval _dt;
    CFTimeInterval _lastUpdateTime;
    float maxNumberOfStar;
    float numberOfStar;
    BOOL stopStar;
    NSTimer *timerGenerator;
    float LEVEL;
    float SpeedLevel;
    NSInteger MAX_NUM_OF_STAR_PER_LEVEL;
    NSInteger StarGenerated;
    float enemyRateo;
    SKLabelNode *scoreLabel;
    NSInteger score;
    NSInteger Life;
    NSMutableArray *lifeArray;
   // BOOL WelcomeScreen;
}

@property (nonatomic) BOOL WelcomeScreen;

@end
