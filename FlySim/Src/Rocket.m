//
//  Rocket.m
//  FlySim
//
//  Created by Riccardo Rizzo on 25/10/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

#import "Rocket.h"

static const uint32_t shipCategory =  0x1 << 0;
static const uint32_t obstacleCategory =  0x1 << 1;

@implementation Rocket
@synthesize rocket;
@synthesize rockettrail;


- (id)init {
    // Forward to the "designated" initialization method
    return [self initWithPoint:CGPointMake(0.0, 0.0) mainFrame:CGRectMake(0, 0, 100, 100)];
}

-(id)initWithPoint:(CGPoint) point mainFrame:(CGRect) _mainFrame{
   self = [super init];
    if (self) {
    
        mainFrame = _mainFrame;
        
        NSString *firePath = [[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"];
        SKEmitterNode *fire = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
        
        SKTexture *rocketTexture1 = [SKTexture textureWithImageNamed:@"rocket_1.png"];
        rocketTexture1.filteringMode = SKTextureFilteringNearest;
    
        rocket = [SKSpriteNode spriteNodeWithTexture:rocketTexture1];
        [rocket setScale:0.2];
        rocket.position = point;
        //Attivare movimento
    
        rocket.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rocket.size.height];
        rocket.physicsBody.categoryBitMask = shipCategory;
        rocket.physicsBody.dynamic = YES;
        rocket.physicsBody.contactTestBitMask = obstacleCategory;
        rocket.physicsBody.collisionBitMask = 0;
        rocket.name = @"ship";
        
        rockettrail = fire;
        
        //the y-position needs to be slightly behind the spaceship
        rockettrail.position = CGPointMake(-390, 0.0);
        
        rockettrail.emissionAngle =  DEG2RAD(180.0f);
        
        //scaling the particlesystem
        rockettrail.xScale = 8.0;
        rockettrail.yScale = 8.7;
       // rockettrail.zPosition = 2;
        
        [rocket addChild:rockettrail];

    }
    return self;
}

//-----------------------EXERCISE 2----------------------------------
- (SKEmitterNode *) newFireEmitter
{
    NSString *firePath = [[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"];
    SKEmitterNode *fire = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    return fire;
}

-(void)moveUp{
     actionMoveUp = [SKAction moveByX:0 y:30 duration:.2];
    [rocket runAction:actionMoveUp];
}


-(void)moveDown{
    actionMoveDown = [SKAction moveByX:0 y:-30 duration:.2];
    [rocket runAction:actionMoveDown];
}

-(void)ImpulseUp {
     [rocket.physicsBody applyImpulse:CGVectorMake(0, 80)];
}

-(void)rocketUp {
    SKTexture *rocketTexture1 = [SKTexture textureWithImageNamed:@"rocket_1.png"];
    rocketTexture1.filteringMode = SKTextureFilteringNearest;
    SKTexture *rocketTexture2 = [SKTexture textureWithImageNamed:@"rocket_up.png"];
    rocketTexture2.filteringMode = SKTextureFilteringNearest;
    
    SKAction *up = [SKAction repeatActionForever:[SKAction animateWithTextures:@[rocketTexture1,rocketTexture2] timePerFrame:0.2]];
    
    [rocket runAction:up];
}
@end
