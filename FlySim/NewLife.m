//
//  Life.m
//  FlySim
//
//  Created by Riccardo Rizzo on 28/01/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

#import "NewLife.h"

@implementation NewLife

-(id) init {
    return [self initWithPosition:CGPointMake(0.0, 0.0)];
}

-(id) initWithPosition:(CGPoint) start_point{
    if(self = [super init]) {
        _life = [[SKSpriteNode alloc] initWithImageNamed:@"rocket_1.png"];
        _life.xScale = 0.1;
        _life.yScale = 0.1;
        _life.zRotation = M_PI/2;
        _life.zPosition = 101;
        _life.position = start_point;
        _life.name = @"life";
        _life.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:((0.5*_life.size.height))];
        _life.physicsBody.restitution=0.8;
        _life.physicsBody.dynamic = false;
        _life.physicsBody.categoryBitMask = 0x1 << 2;
        _life.physicsBody.contactTestBitMask = 0x1 << 0;
        _life.physicsBody.collisionBitMask = 0;
        _life.alpha = 0.6;
        NSString *lifePath = [[NSBundle mainBundle] pathForResource:@"astro" ofType:@"sks"];
        SKEmitterNode *astro = [NSKeyedUnarchiver unarchiveObjectWithFile:lifePath];
        
        SKEmitterNode* rockettrail = astro;
        
        //the y-position needs to be slightly behind the spaceship
        rockettrail.position = CGPointMake(0.0, 0.0);
        
        //scaling the particlesystem
        rockettrail.xScale = 8.0;
        rockettrail.yScale = 8.7;
        // rockettrail.zPosition = 2;
        
        [_life addChild:rockettrail];
    }
    return self;
}

@end
