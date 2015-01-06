//
//  Enemy.h
//  FlySim
//
//  Created by Riccardo Rizzo on 26/12/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Enemy : NSObject{
 //   int numberOfHit;
   // int MaxHP;
}

-(id) initWithPosition:(CGPoint) start_point;
-(id) initSuperEnemy:(int) number_of_hits;
-(BOOL)hit;

@property (nonatomic,retain) SKSpriteNode *enemy;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) SKNode *healthBar;
@property (nonatomic) bool superEnemy;
@property (nonatomic) int numberOfHit;
@property (nonatomic) int enemyHP;
@property (nonatomic) int MaxHP;

@end
