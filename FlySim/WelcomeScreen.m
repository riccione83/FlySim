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
   
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    GameScene *mainScene = [[GameScene alloc] initWithSize:self.size];
    mainScene.WelcomeScreen = true;
    SKTransition *transition = [SKTransition flipVerticalWithDuration:0.5];
    [self.view presentScene:mainScene transition:transition];

}


-(void)update:(CFTimeInterval)currentTime {
    NSLog(@"Updated");
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
