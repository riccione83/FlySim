//
//  GameScene.h
//  FlySim
//

//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "FileSupport.h"
#import "JCJoystick.h"
#import "JCImageJoystick.h"
#import "JCButton.h"

@interface GameScene : SKScene <SKPhysicsContactDelegate> {
    CFTimeInterval _dt;
    CFTimeInterval _lastUpdateTime;
    float maxNumberOfStar;
    float numberOfStar;
    float numberOfUfo;
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
    float numberOfWeapons;
    float MAX_POINT;
    NSInteger oldx,oldy;
    
}

@property (nonatomic) BOOL WelcomeScreen;

@end
