//
//  Rocket.h
//  FlySim
//
//  Created by Riccardo Rizzo on 25/10/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@interface Rocket : NSObject {
    CGRect mainFrame;
    SKAction *actionMoveUp;
    SKAction *actionMoveDown;
}


-(id)initWithPoint:(CGPoint) point mainFrame:(CGRect) _mainFrame;
-(void)ImpulseUp;
-(void)moveUp;
-(void)moveDown;

@property (nonatomic,retain) SKSpriteNode *rocket;
@property (nonatomic,retain) GameScene *mainFrameScene;
@property (nonatomic,retain) SKEmitterNode *rockettrail;
@end
