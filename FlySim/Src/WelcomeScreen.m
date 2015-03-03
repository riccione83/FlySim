//
//  WecomeScreen.m
//  FlySim
//
//  Created by Riccardo Rizzo on 28/10/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "WelcomeScreen.h"
#import "GameScene.h"
#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

@interface WecomeScreen() {
}
@end

@implementation WecomeScreen


-(id)initWithSize:(CGSize)size {
    
    if(self = [super initWithSize:size]) {

    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view {
    FileSupport *pointFile = [[FileSupport alloc] init];
    
    pointFile.fileName = @"FlySimPoint";
    
    NSMutableArray *pointArray = [pointFile  readObjectFromFile:@"FlySimPoint"];
    if(pointArray==nil)
        MAX_POINT = 0;
    else
        MAX_POINT = [[pointArray objectAtIndex:0] floatValue];
    
    SKTexture *groundTexture = [SKTexture textureWithImageNamed:@"space.jpeg"];
    groundTexture.filteringMode = SKTextureFilteringNearest;
    
    SKAction *moveGroudSprite = [SKAction moveByX:-groundTexture.size.width*2 y:0 duration:0.02 * groundTexture.size.width*2];
    SKAction *resetGroundTexture = [SKAction moveByX:groundTexture.size.width*2 y:0 duration:0];
    SKAction *moveGroudSpriteForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroudSprite,resetGroundTexture]]];
    
    for(int i=0; i< 2+ self.frame.size.width / (groundTexture.size.width * 2); i++) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
        [sprite setScale:2];
        sprite.position = CGPointMake(i * sprite.size.width, 80);
        [sprite runAction:moveGroudSpriteForever];
        sprite.zPosition = 0;
        [self addChild:sprite];
    }
    
    
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    if(!_GameOver)
        gameOverLabel.text = @"WELCOME - TAP TO START";
    else {
        gameOverLabel.text = @"GAMEOVER - TAP TO RESTART";
        _GameOver = false;
    }
    gameOverLabel.fontSize = 30;
    gameOverLabel.zPosition = 4;
    gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame));
    
    [gameOverLabel setScale:1];
   
    [self addChild:gameOverLabel];
   
    [self addShip];
    NSTimer *timerGenerator = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(addShip) userInfo:nil repeats:YES];
    
    
    SKNode *nerdText = [SKNode node];
    SKLabelNode *a = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    a.fontSize = 20;
    a.fontColor = [SKColor yellowColor];
    SKLabelNode *b = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    b.fontSize = 20;
    b.fontColor = [SKColor yellowColor];
    SKLabelNode *c = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    c.fontSize = 20;
    c.fontColor = [SKColor yellowColor];

    
    NSString *st1 = @"Instruction";
    NSString *st2 = @"Move the ship around the galaxy";
    NSString *st3 = @"Save the astronauts and destroy all aliens!";
    b.position = CGPointMake(b.position.x, b.position.y - 30);
    c.position = CGPointMake(c.position.x, c.position.y - 60);
    a.text = st1;
    b.text = st2;
    c.text = st3;
    [nerdText addChild:a];
    [nerdText addChild:b];
    [nerdText addChild:c];
    nerdText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-gameOverLabel.frame.size.height*2);
    [self addChild:nerdText];
    
    
    
    SKNode *maxPoint = [SKNode node];
    SKLabelNode *point = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    point.fontSize = 26;
    point.fontColor = [SKColor yellowColor];
    point.text = [NSString stringWithFormat:@"Max Score: %0.f",MAX_POINT];
    [maxPoint addChild:point];
    maxPoint.position = CGPointMake(CGRectGetMidX(self.frame), 450.0);
    [self addChild:maxPoint];


}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    GameScene *mainScene = [[GameScene alloc] initWithSize:self.size];
    mainScene.scaleMode = self.scaleMode;
    mainScene.WelcomeScreen = true;
    SKTransition *transition = [SKTransition flipVerticalWithDuration:0.5];
    [self.view presentScene:mainScene transition:transition];

}


-(void)update:(CFTimeInterval)currentTime {
  //  NSLog(@"Updated");
}

- (void)addShip
{
    NSString *firePath = [[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"];
    SKEmitterNode *fire = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    
    SKSpriteNode *star = [[SKSpriteNode alloc] initWithImageNamed:@"rocket_1.png"];
    star.xScale = 0.1;
    star.yScale = 0.1;
    star.position = CGPointMake(0, (self.frame.size.height/4));
    
    SKEmitterNode *rockettrail = fire;
    //the y-position needs to be slightly behind the spaceship
    rockettrail.position = CGPointMake(-390, 0.0);
    
    rockettrail.emissionAngle =  DEG2RAD(180.0f);
    
    //scaling the particlesystem
    rockettrail.xScale = 7.0;
    rockettrail.yScale = 7.0;
   // rockettrail.zPosition = 2;
    
    [star addChild:rockettrail];

    
    SKAction *actionMoveStar = [SKAction moveByX:(self.size.width+star.size.width) y:0 duration:3];
    SKAction *removeNode = [SKAction removeFromParent];
    SKAction *sequence = [SKAction sequence:@[actionMoveStar, removeNode]];
    [star runAction:sequence];
    
    [self addChild:star];
}

@end
