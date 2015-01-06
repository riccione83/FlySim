//
//  Enemy.m
//  FlySim
//
//  Created by Riccardo Rizzo on 26/12/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "Enemy.h"

@implementation Enemy 

@synthesize numberOfHit;
//@synthesize enemyHP;

-(id) init {
    return [self initWithPosition:CGPointMake(0.0, 0.0)];
}

-(id) initWithPosition:(CGPoint) start_point{
    if(self = [super init]) {
    _healthBar = [SKNode node];
    numberOfHit = 2;
    _MaxHP = numberOfHit*100;
    _enemyHP = numberOfHit * 100;
   float rnd = skRand(0, 1);  //0,1
    //float rnd = 1;
    NSString *ufoName;
    
    if(rnd<=0.5)
        ufoName = @"enemy_1.png";
    else if (rnd > 0.5)
        ufoName = @"enemy_2.png";
        _enemy = [[SKSpriteNode alloc] initWithImageNamed:ufoName];
        _enemy.xScale = 0.2;
        _enemy.yScale = 0.2;
        _superEnemy = false;
        _enemy.position = start_point;
        _enemy.name = @"ufo";
        _enemy.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(0.5*_enemy.size.height)];
        _enemy.physicsBody.restitution=0.8;
        _enemy.physicsBody.dynamic = false;
        
    }
    return self;
}

-(id) initSuperEnemy:(int) number_of_hits{
    if(self = [super init]) {
        
        _healthBar = [SKNode node];
        numberOfHit = number_of_hits;
        _MaxHP = numberOfHit*100;
        _enemyHP = numberOfHit * 100;
        numberOfHit = number_of_hits;
        NSString *ufoName = @"enemy_3.png";
        _enemy = [[SKSpriteNode alloc] initWithImageNamed:ufoName];
        _enemy.xScale = 0.3;
        _enemy.yScale = 0.3;
        _superEnemy = true;
       // _enemy.position = start_point;
        _enemy.name = @"ufo";
        _enemy.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(0.5*_enemy.size.height)*_enemy.yScale];
        _enemy.physicsBody.restitution=0.8;
        _enemy.physicsBody.dynamic = false;
    }
    return self;
}

static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}
static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}

-(BOOL)hit{
    numberOfHit--;
    _enemyHP = numberOfHit * 100;
    NSLog(@"Hit ufo - Hit to destroy: %d Powerbar: %d",numberOfHit,_enemyHP);
    if(numberOfHit<=0)
        return true;
    else return false;
}

@end
