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



- (id)init {
    // Forward to the "designated" initialization method
    return [self initWithPoint:CGPointMake(0.0, 0.0) mainFrame:CGRectMake(0, 0, 100, 100)];
}

-(id)initWithPoint:(CGPoint) point mainFrame:(CGRect) _mainFrame{
   self = [super init];
    if (self) {
    
        mainFrame = _mainFrame;
        
    SKTexture *rocketTexture1 = [SKTexture textureWithImageNamed:@"rocket_1.png"];
    rocketTexture1.filteringMode = SKTextureFilteringNearest;
    
        _rocket = [SKSpriteNode spriteNodeWithTexture:rocketTexture1];
        [_rocket setScale:0.2];
        _rocket.position = point;
        //Attivare movimento
    
        _rocket.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_rocket.size.height/2];
        _rocket.physicsBody.categoryBitMask = shipCategory;
        _rocket.physicsBody.dynamic = YES;
        _rocket.physicsBody.contactTestBitMask = obstacleCategory;
        _rocket.physicsBody.collisionBitMask = 0;
        _rocket.name = @"ship";
        
        _rockettrail = [self newFireEmitter];
        
        //the y-position needs to be slightly behind the spaceship
        _rockettrail.position = CGPointMake(-390, 0.0);
        
        _rockettrail.emissionAngle =  DEG2RAD(170.0f);
        
        //scaling the particlesystem
        _rockettrail.xScale = 10.0;
        _rockettrail.yScale = 10.7;
        
        //changing the targetnode from spaceship to scene so that it gets influenced by movement
        //rockettrail.targetNode = _mainFrameScene.scene;
        
        [_rocket addChild:_rockettrail];

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
    [_rocket runAction:actionMoveUp];
}


-(void)moveDown{
    actionMoveDown = [SKAction moveByX:0 y:-30 duration:.2];
    [_rocket runAction:actionMoveDown];
}

-(void)ImpulseUp {
     [_rocket.physicsBody applyImpulse:CGVectorMake(0, 80)];
}

-(void)rocketUp {
    SKTexture *rocketTexture1 = [SKTexture textureWithImageNamed:@"rocket_1.png"];
    rocketTexture1.filteringMode = SKTextureFilteringNearest;
    SKTexture *rocketTexture2 = [SKTexture textureWithImageNamed:@"rocket_up.png"];
    rocketTexture2.filteringMode = SKTextureFilteringNearest;
    
    SKAction *up = [SKAction repeatActionForever:[SKAction animateWithTextures:@[rocketTexture1,rocketTexture2] timePerFrame:0.2]];
    
    [_rocket runAction:up];
}
@end
