//
//  GameScene.m
//  FlySim
//
//  Created by Riccardo Rizzo on 22/10/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "GameScene.h"
#import "Rocket.h"
#import "WelcomeScreen.h"



@interface GameScene() {
    SKColor *_skyColor;
    Rocket *rocket;
}
@end

@implementation GameScene


-(id)initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]) {

    }
    return self;
}

-(void)initalizingScrollingBackground
{
    //Create Groud
    
     SKTexture *groundTexture = [SKTexture textureWithImageNamed:@"ground.png"];
     groundTexture.filteringMode = SKTextureFilteringNearest;
     
     SKAction *moveGroudSprite = [SKAction moveByX:-groundTexture.size.width*2 y:0 duration:0.02 * groundTexture.size.width*2];
     SKAction *resetGroundTexture = [SKAction moveByX:groundTexture.size.width*2 y:0 duration:0];
     SKAction *moveGroudSpriteForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroudSprite,resetGroundTexture]]];
     
     for(int i=0; i< 2+ self.frame.size.width / (groundTexture.size.width * 2); i++) {
     SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
     [sprite setScale:2];
     sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height-40);
     [sprite runAction:moveGroudSpriteForever];
         sprite.zPosition = 0;
     [self addChild:sprite];
     }
    
    LEVEL = 1;
    SpeedLevel = 5;
    numberOfStar=1;
    MAX_NUM_OF_STAR_PER_LEVEL = 10;
    enemyRateo = 0.9;
 /*
    SKNode *dummy = [SKNode node];
    dummy.position = CGPointMake(0, groundTexture.size.height);
    dummy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, groundTexture.size.height*2)];
    dummy.physicsBody.dynamic = NO;
    [self addChild:dummy];
  */
}


-(void)didMoveToView:(SKView *)view {

    if(_WelcomeScreen) {
    maxNumberOfStar = 10;
    numberOfStar=0;
    Life = 5;
    lifeArray = [[NSMutableArray alloc] init];
    
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);  //-5.0 per cadere
    
    //Create SkyColor
    _skyColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.9 alpha:1.0];
    [self setBackgroundColor:_skyColor];
    [self initalizingScrollingBackground];

    rocket = [[Rocket alloc] initWithPoint:CGPointMake(50+(self.frame.size.width / 4), CGRectGetMidY(self.frame)) mainFrame:self.frame];
    rocket.mainFrameScene = self;
    rocket.rockettrail.targetNode = self.scene;
    
    //[self runAction: [SKAction repeatActionForever:makeStars]];
    self.physicsWorld.contactDelegate = self;

    timerGenerator = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(generateNewStar) userInfo:nil repeats:NO];

    
    // Add score label
    
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    scoreLabel.text = @"Score: 0";
    scoreLabel.fontSize = 48;
    scoreLabel.zPosition = 4;
    scoreLabel.position = CGPointMake(CGRectGetMinX(self.frame)+(scoreLabel.frame.size.width/2)+20,
                                      CGRectGetMinY(self.frame)+20);
    
    [scoreLabel setScale:1];
    
    [self addChild:scoreLabel];
    
    rocket.rocket.zPosition = 4;
    [self addChild:rocket.rocket];
    [self checkLife];
    }
    else
    {
        WecomeScreen *mainScene = [[WecomeScreen alloc] initWithSize:self.size];
        SKTransition *transition = [SKTransition flipVerticalWithDuration:0.5];
        [self.view presentScene:mainScene transition:transition];
        _WelcomeScreen = true;
    }
}

- (float)convertFontSize:(float)fontSize
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return fontSize * 2;
    } else {
        return fontSize;
    }
}

-(SKEmitterNode *)newExplosion:(NSString*)type
{
    
    //instantiate explosion emitter
    SKEmitterNode *explosion = [[SKEmitterNode alloc] init];
    
    if([type isEqualToString:@"star"]) {
    //TODO: set the right properties for your particle system!
    [explosion setParticleTexture:[SKTexture textureWithImageNamed:@"spark.png"]];
    [explosion setParticleColor:[UIColor brownColor]];
    [explosion setNumParticlesToEmit:100];
    [explosion setParticleBirthRate:450];
    [explosion setParticleLifetime:2];
    [explosion setEmissionAngleRange:360];
    [explosion setParticleSpeed:100];
    [explosion setParticleSpeedRange:50];
    [explosion setXAcceleration:0];
    [explosion setYAcceleration:0];
    [explosion setParticleAlpha:0.8];
    [explosion setParticleAlphaRange:0.2];
    [explosion setParticleAlphaSpeed:-0.5];
    [explosion setParticleScale:0.75];
    [explosion setParticleScaleRange:0.4];
    [explosion setParticleScaleSpeed:-0.5];
    [explosion setParticleRotation:0];
    [explosion setParticleRotationRange:0];
    [explosion setParticleRotationSpeed:0];
    
    [explosion setParticleColorBlendFactor:1];
    [explosion setParticleColorBlendFactorRange:0];
    [explosion setParticleColorBlendFactorSpeed:0];
    [explosion setParticleBlendMode:SKBlendModeAdd];
    
    //add this node to parent node
    [self addChild:explosion];
    }
    
    if([type isEqualToString:@"ufo"]) {
        //TODO: set the right properties for your particle system!
        [explosion setParticleTexture:[SKTexture textureWithImageNamed:@"spark.png"]];
        [explosion setParticleColor:[UIColor blueColor]];
        [explosion setNumParticlesToEmit:100];
        [explosion setParticleBirthRate:450];
        [explosion setParticleLifetime:2];
        [explosion setEmissionAngleRange:360];
        [explosion setParticleSpeed:80];
        [explosion setParticleSpeedRange:50];
        [explosion setXAcceleration:0];
        [explosion setYAcceleration:0];
        [explosion setParticleAlpha:0.8];
        [explosion setParticleAlphaRange:0.2];
        [explosion setParticleAlphaSpeed:-0.5];
        [explosion setParticleScale:0.75];
        [explosion setParticleScaleRange:0.4];
        [explosion setParticleScaleSpeed:-0.5];
        [explosion setParticleRotation:0];
        [explosion setParticleRotationRange:0];
        [explosion setParticleRotationSpeed:0];
        
        [explosion setParticleColorBlendFactor:1];
        [explosion setParticleColorBlendFactorRange:0];
        [explosion setParticleColorBlendFactorSpeed:0];
        [explosion setParticleBlendMode:SKBlendModeAdd];
        
        //add this node to parent node
        [self addChild:explosion];
        
        return explosion;
    }
    
    
    if([type isEqualToString:@"point"]) {
        //TODO: set the right properties for your particle system!
        [explosion setParticleTexture:[SKTexture textureWithImageNamed:@"spark.png"]];
        [explosion setParticleColor:[UIColor greenColor]];
        [explosion setNumParticlesToEmit:80];
        [explosion setParticleBirthRate:100];
        [explosion setParticleLifetime:2];
        [explosion setEmissionAngleRange:360];
        [explosion setParticleSpeed:100];
        [explosion setParticleSpeedRange:50];
        [explosion setXAcceleration:0];
        [explosion setYAcceleration:0];
        [explosion setParticleAlpha:0.8];
        [explosion setParticleAlphaRange:0.2];
        [explosion setParticleAlphaSpeed:-0.5];
        [explosion setParticleScale:0.75];
        [explosion setParticleScaleRange:0.4];
        [explosion setParticleScaleSpeed:-0.5];
        [explosion setParticleRotation:0];
        [explosion setParticleRotationRange:0];
        [explosion setParticleRotationSpeed:0];
        
        [explosion setParticleColorBlendFactor:1];
        [explosion setParticleColorBlendFactorRange:0];
        [explosion setParticleColorBlendFactorSpeed:0];
        [explosion setParticleBlendMode:SKBlendModeAdd];
        
        //add this node to parent node
        [self addChild:explosion];
        
        return explosion;
    }

    return explosion;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    NSLog(@"Touch :%lu",[touches count]);
    
    if(touchLocation.y >rocket.rocket.position.y){
        if(rocket.rocket.position.y < (self.frame.size.width/2)+rocket.rocket.frame.size.width){
            
            [rocket moveUp];
            
        }
    }else{
        if(rocket.rocket.position.y > 50){
            [rocket moveDown];
        }
    }
}

static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}

-(void)levelUp {
    
    if(StarGenerated >= MAX_NUM_OF_STAR_PER_LEVEL)
    {
        LEVEL++;
        NSLog(@"Level: %f",LEVEL);
        enemyRateo -= 0.1;
        NSLog(@"Enemy rateo: %f",enemyRateo);
        if(enemyRateo<=0.1)
        {
            SpeedLevel = SpeedLevel-1;
            NSLog(@"Speed: %f",SpeedLevel);
            enemyRateo = 1;
        }
        StarGenerated = 0;
        // MAX_NUM_OF_STAR_PER_LEVEL = MAX_NUM_OF_STAR_PER_LEVEL + 10;
    
        
        SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        gameOverLabel.text = @"Level UP!";
        gameOverLabel.fontSize = 48;
        gameOverLabel.zPosition = 4;
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                             CGRectGetMidY(self.frame));
        
        [gameOverLabel setScale:0.1];
        
        [self addChild:gameOverLabel];
        SKAction *fadeIn = [SKAction scaleTo:3.0 duration:0.5];
        SKAction *wait = [SKAction waitForDuration: 2];
        //SKAction *fadeAway = [SKAction fadeOutWithDuration:0.5];
        SKAction *fadeAway = [SKAction scaleTo:0.0 duration:0.5];
        SKAction *removeNode = [SKAction removeFromParent];
        
        SKAction *sequence = [SKAction sequence:@[fadeIn, wait, fadeAway, removeNode]];
        [gameOverLabel runAction:sequence];
        
     //   self.gameOver = YES;
        return;
    }
    
    [scoreLabel setText:[NSString stringWithFormat:@"Score: %d", score]];
}

- (void)addStar
{
    SKSpriteNode *star = [[SKSpriteNode alloc] initWithImageNamed:@"Star.png"];
    star.xScale = 1.0;
    star.yScale = 1.0;
    star.position = CGPointMake(self.size.width, skRand(0, self.size.height-20));
    star.name = @"star";
    star.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:0.5*star.size.width];
    
    SKAction *actionMoveStar = [SKAction moveByX:-1*(self.size.width+star.size.width) y:0 duration:SpeedLevel];
    SKAction *removeNode = [SKAction removeFromParent];
    
    SKAction *sequence = [SKAction sequence:@[actionMoveStar, removeNode]];
    [star runAction:sequence];
    
    /* If you want rebounding stars instead of explosions.       *
     * You need to remove collision detection in order to do so  *
     *                                                           *
     //star.physicsBody.usesPreciseCollisionDetection = YES;     */
    
    numberOfStar++;
    StarGenerated++;
    [self levelUp];
       [self addChild:star];
}

- (void)addUfo
{
    SKSpriteNode *star = [[SKSpriteNode alloc] initWithImageNamed:@"ufo.png"];
    star.xScale = 0.05;
    star.yScale = 0.05;
    star.position = CGPointMake(self.size.width, skRand(0, self.size.height-20));
    star.name = @"ufo";
    star.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:0.5*star.size.width];
    
    SKAction *actionMoveStar = [SKAction moveByX:-1*(self.size.width+star.size.width) y:0 duration:SpeedLevel];
    SKAction *removeNode = [SKAction removeFromParent];
    
    SKAction *sequence = [SKAction sequence:@[actionMoveStar, removeNode]];
    
    [star runAction:sequence];
    
    /* If you want rebounding stars instead of explosions.       *
     * You need to remove collision detection in order to do so  *
     *                                                           *
     //star.physicsBody.usesPreciseCollisionDetection = YES;     */
    
    //numberOfStar++;
    [self addChild:star];
}

-(void)didSimulatePhysics
{
    [self enumerateChildNodesWithName:@"star" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0 || node.position.x < 0) {
            [node removeFromParent];
            numberOfStar--;
        }
        
    }];
}

//-----------------------EXERCISE 1----------------------------------
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    //insantiate new explosion on contact
    SKEmitterNode *ex = [self newExplosion: contact.bodyB.node.name];
    
    //set the position of contact
    ex.position = contact.bodyB.node.position;
    
    if([contact.bodyB.node.name isEqualToString:@"star"]) {
        [contact.bodyB.node removeFromParent];
        numberOfStar--;
        score++;
        NSLog(@"Collision with star");
    }
    if([contact.bodyB.node.name isEqualToString:@"ufo"]) {
        [contact.bodyB.node removeFromParent];
        NSLog(@"Collision with UFO");
        [self deleteLife];
    }
}

-(void)deleteLife {
    
    SKNode *object = [lifeArray objectAtIndex:(Life-1)];
    SKEmitterNode *ex = [self newExplosion: @"point"];
    
    //set the position of contact
    ex.position = object.position;
    
    [object removeFromParent];
    Life--;
    if(Life<=0)
    {
        WecomeScreen *mainScene = [[WecomeScreen alloc] initWithSize:self.size];
        mainScene.GameOver = true;
        SKTransition *transition = [SKTransition flipVerticalWithDuration:0.5];
        [self.view presentScene:mainScene transition:transition];
    }
}

-(void)checkLife {
    SKTexture *life_text = [SKTexture textureWithImageNamed:@"rocket_1.png"];
    life_text.filteringMode = SKTextureFilteringNearest;
    
    SKSpriteNode *life1 = [SKSpriteNode spriteNodeWithTexture:life_text];
    SKSpriteNode *life2 = [SKSpriteNode spriteNodeWithTexture:life_text];
    SKSpriteNode *life3 = [SKSpriteNode spriteNodeWithTexture:life_text];
    SKSpriteNode *life4 = [SKSpriteNode spriteNodeWithTexture:life_text];
    SKSpriteNode *life5 = [SKSpriteNode spriteNodeWithTexture:life_text];
    
    CGFloat x_master = CGRectGetMinX(self.frame)+160;
    CGFloat y_master = CGRectGetMaxY(self.frame)-150;
    CGFloat d_x = life1.frame.size.height*0.05;
    CGFloat d_y = 100;
    
    [life1 setScale:0.05];
    life1.position = CGPointMake(x_master-(d_x-20),
                                y_master+d_y);
    life1.zRotation = M_PI/2;
    life1.name = @"life1";


    [life2 setScale:0.05];
    life2.position = CGPointMake(x_master-(d_x+10),
                                 y_master+d_y);
    life2.zRotation = M_PI/2;
    life2.name = @"life2";

  
    [life3 setScale:0.05];
    life3.position = CGPointMake(x_master-(d_x+40),
                                 y_master+d_y);
    life3.zRotation = M_PI/2;
    life3.name = @"life3";
    
 
    [life4 setScale:0.05];
    life4.position = CGPointMake(x_master-(d_x+70),
                                 y_master+d_y);
    life4.zRotation = M_PI/2;
    life4.name = @"life4";
    
 
    [life5 setScale:0.05];
    life5.position = CGPointMake(x_master-(d_x+100),
                                 y_master+d_y);
    life5.zRotation = M_PI/2;
    life5.name = @"life5";
    
    
    for(int i =0; i<Life; i++)
    {
        switch (i) {
            case 0: [self addChild:life1]; [lifeArray addObject:life1]; break;
            case 1: [self addChild:life2]; [lifeArray addObject:life2]; break;
            case 2: [self addChild:life3]; [lifeArray addObject:life3]; break;
            case 3: [self addChild:life4]; [lifeArray addObject:life4]; break;
            case 4: [self addChild:life5]; [lifeArray addObject:life5]; break;
        }
    }
}

-(void)generateNewStar {
    float type = skRand(0, 1);
    
    if(numberOfStar<=maxNumberOfStar && !stopStar) {
        SKAction *makeStars;
        if(type>=0 && type<=enemyRateo) {
         makeStars = [SKAction sequence: @[
                                                    [SKAction performSelector:@selector(addStar) onTarget:self],
                                                    [SKAction waitForDuration:5 withRange:5]
                                                    ]];
        }
        else
        {
            makeStars = [SKAction sequence: @[
                                                        [SKAction performSelector:@selector(addUfo) onTarget:self],
                                                        [SKAction waitForDuration:5 withRange:5]
                                            ]];
        }
        
        [self runAction: makeStars];
    }
    else
        stopStar = true;
    
    
    if(numberOfStar==0)
    {
        stopStar=false;

    }
    
    
    timerGenerator = nil;
    float timing = skRand(0.2, 1);
    timerGenerator = [NSTimer scheduledTimerWithTimeInterval:timing target:self selector:@selector(generateNewStar) userInfo:nil repeats:NO];
   // NSLog(@"Timer: %f",timing);
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
  //  NSLog(@"%f - %f",numberOfStar,_dt);
}

@end
