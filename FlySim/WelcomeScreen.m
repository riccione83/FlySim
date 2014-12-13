//
//  WecomeScreen.m
//  FlySim
//
//  Created by Riccardo Rizzo on 28/10/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "WelcomeScreen.h"
#import "GameScene.h"

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
    
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    if(!_GameOver)
        gameOverLabel.text = @"WELCOME - TAP TO START";
    else {
        gameOverLabel.text = @"GAMEOVER - TAP TO RESTART";
        _GameOver = false;
    }
    gameOverLabel.fontSize = 48;
    gameOverLabel.zPosition = 4;
    gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame));
    
    [gameOverLabel setScale:1];
   
    [self addChild:gameOverLabel];
   
    [self addShip];
    NSTimer *timerGenerator = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(addShip) userInfo:nil repeats:YES];
   
    
    SKNode *nerdText = [SKNode node];
    SKLabelNode *a = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    a.fontSize = 26;
    a.fontColor = [SKColor yellowColor];
    SKLabelNode *b = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    b.fontSize = 26;
    b.fontColor = [SKColor yellowColor];
    SKLabelNode *c = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    c.fontSize = 26;
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
    nerdText.position = CGPointMake(CGRectGetMidX(self.frame), 250.0);
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
    mainScene.WelcomeScreen = true;
    SKTransition *transition = [SKTransition flipVerticalWithDuration:0.5];
    [self.view presentScene:mainScene transition:transition];

}


-(void)update:(CFTimeInterval)currentTime {
  //  NSLog(@"Updated");
}

- (void)addShip
{
    SKSpriteNode *star = [[SKSpriteNode alloc] initWithImageNamed:@"rocket_1.png"];
    star.xScale = 0.1;
    star.yScale = 0.1;
    star.position = CGPointMake(0, (self.size.width/2)-200);
    
    SKAction *actionMoveStar = [SKAction moveByX:(self.size.width+star.size.width) y:0 duration:3];
    SKAction *removeNode = [SKAction removeFromParent];
    
    SKAction *sequence = [SKAction sequence:@[actionMoveStar, removeNode]];
    [star runAction:sequence];
    
    [self addChild:star];
}

@end
