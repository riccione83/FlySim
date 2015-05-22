//
//  GameScene.m
//  FlySim
//
//  Created by Riccardo Rizzo on 22/10/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "GameScene.h"
//#import "Rocket.h"
#import "WelcomeScreen.h"
#import "Enemy.h"
@import AVFoundation;

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

static const int backgroundLayer = 0;
static const int gameLayer = 1;
static const int otherLayer = 101;
int maxNumberOfStar = 10;

static const uint32_t shipCategory =  0x1 << 0;
static const uint32_t missileCategory =  0x1 << 1;
static const uint32_t enemyCategory =  0x1 << 2;
static const uint32_t lifeCategory = 0x1 << 3;
static const uint32_t pointCategory = 0x1 << 4;
static const uint32_t enemyMissileCategory = 0x1 << 5;
static const uint32_t superEnemyCategory = 0x1 << 6;
static const uint32_t lowEnemyCategory =  0x1 << 7;

//*** Const for health bar
//const int MaxHP = 100;
const float HealthBarWidth = 100.0f;
const float HealthBarHeight = 10.0f;

@interface GameScene() {

    JCJoystick *joystick;
    JCButton *normalButton;
    JCButton *turboButton;
    JCImageJoystick *imageJoystick;
    SKColor *_skyColor;
   // Rocket *rocket;
    AVAudioPlayer *_backgroundAudioPlayer;
    SKSpriteNode *rocket;
    SKEmitterNode *rockettrail;
    int _playerHP;
    SKNode *_playerHealthBar;
    NSTimeInterval lastSpawnTimeInterval;
    NSTimeInterval lastUpdateTimeInterval;

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
    
     SKTexture *groundTexture = [SKTexture textureWithImageNamed:@"space.jpeg"];
     groundTexture.filteringMode = SKTextureFilteringNearest;
     
     SKAction *moveGroudSprite = [SKAction moveByX:-groundTexture.size.width*2 y:0 duration:0.02 * groundTexture.size.width*2];
     SKAction *resetGroundTexture = [SKAction moveByX:groundTexture.size.width*2 y:0 duration:0];
     SKAction *moveGroudSpriteForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroudSprite,resetGroundTexture]]];
     
     for(int i=0; i< 2+ self.frame.size.width / (groundTexture.size.width * 2); i++) {
         SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
         [sprite setScale:2];
         sprite.position = CGPointMake(i * (sprite.size.width-1), 80);
         [sprite runAction:moveGroudSpriteForever];
         sprite.zPosition = backgroundLayer;
         [self addChild:sprite];
     }
    
 /*
    SKNode *dummy = [SKNode node];
    dummy.position = CGPointMake(0, groundTexture.size.height);
    dummy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, groundTexture.size.height*2)];
    dummy.physicsBody.dynamic = NO;
    [self addChild:dummy];
  */
}

-(void)showPlanet
{
    //Create Groud
    planetShowed = true;
    NSString *planetName;
    float rand = skRand(0, 11);
    float scale = skRand(1, 2);
    float yPosition = skRand(80, (self.size.height/3)*2);
    
    if(rand>=0 && rand<1)
        planetName = @"planet_1.png";
    else if(rand>=1 && rand<2)
        planetName = @"planet_2.png";
    else if(rand>=2 && rand<3)
        planetName = @"planet_3.png";
    else if(rand>=3 && rand<4)
        planetName = @"planet_4.png";
    else if(rand>=4 && rand<5)
        planetName = @"planet_5.png";
    else if(rand>=5 && rand<6)
        planetName = @"planet_6.png";
    else if(rand>=6 && rand<7)
        planetName = @"planet_7.png";
    else if(rand>=7 && rand<8)
        planetName = @"planet_8.png";
    else if(rand>=8 && rand<9)
        planetName = @"rock_1.png";
    else if(rand>=9 && rand<10)
        planetName = @"rock_2.png";
    else if(rand>=10 && rand<11)
        planetName = @"rock_3.png";
    
    float rot = skRand(0, 2);
    SKAction *oneRevolution;
    
    if(rot<=1)
        oneRevolution = [SKAction rotateByAngle:-M_PI*rot duration: 8.0];
    else
        oneRevolution = [SKAction rotateByAngle:M_PI*rot duration: 8.0];
    SKAction *repeat = [SKAction repeatActionForever:oneRevolution];
    
    SKTexture *planet = [SKTexture textureWithImageNamed:planetName];
    planet.filteringMode = SKTextureFilteringNearest;
    
    SKAction *moveGroudSprite = [SKAction moveByX:-(self.size.width+(planet.size.width*scale)+200) y:0 duration:15];
    SKAction *removeNode = [SKAction removeFromParent];
    SKAction *planetAction = [SKAction  sequence:@[moveGroudSprite, removeNode]];

    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:planet];
    [sprite setScale:scale];
    sprite.position = CGPointMake(self.size.width+planet.size.width, yPosition);
    sprite.zPosition = backgroundLayer;
    sprite.alpha = 1;
    sprite.name = @"planet";
    [self addChild:sprite];
    [sprite runAction:planetAction];
    if(rand>=8)
        [sprite runAction:repeat];
        
    NSLog(@"Planet: %f Rocket:%f",sprite.zPosition,rocket.zPosition);
    timerPlanet = nil;
    float timing = skRand(16, 35);
    timerPlanet = [NSTimer scheduledTimerWithTimeInterval:timing target:self selector:@selector(showPlanet) userInfo:nil repeats:NO];
}

-(void)savePoint {
    if(score>MAX_POINT) {
    FileSupport *file = [[FileSupport alloc] init];
    NSMutableArray *point = [[NSMutableArray alloc] init];
    NSNumber *num = [NSNumber numberWithFloat:score];
    [point insertObject:num atIndex:0];
    [file writeObjectToFile:point fileToWrite:@"FlySimPoint"];
    }
}

- (void)startBackgroundMusic
{
    NSError *err;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SpaceGame" ofType:@"caf"];
    
    NSURL *file = [NSURL fileURLWithPath:path];
    if(!_backgroundAudioPlayer)
    {
        
    _backgroundAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:&err];
    if (err) {
        NSLog(@"error in audio play %@",[err userInfo]);
        return;
    }
    [_backgroundAudioPlayer prepareToPlay];
    
    // this will play the music infinitely
    _backgroundAudioPlayer.numberOfLoops = -1;
    [_backgroundAudioPlayer setVolume:1.0];
    [_backgroundAudioPlayer play];
    }
}

-(void)addJoystick {
    
    //JCImageJoystic
    imageJoystick = [[JCImageJoystick alloc]initWithJoystickImage:(@"redStick.png") baseImage:@"stickbase.png"];
    [imageJoystick setPosition:CGPointMake(imageJoystick.size.width+50, 100)];
    
    [imageJoystick setScale:3.0];
    [imageJoystick setAlpha:0.5];
    imageJoystick.zPosition=otherLayer;
    [self addChild:imageJoystick];
    
    //JCButton
    
    normalButton = [[JCButton alloc] initWithButtonRadius:60 color:[SKColor blueColor] pressedColor:[SKColor clearColor] isTurbo:NO];
    [normalButton setPosition:CGPointMake(CGRectGetMaxX(self.frame)-normalButton.frame.size.width,100)];
    [normalButton setAlpha:0.3];
    normalButton.zPosition = otherLayer;
    [self addChild:normalButton];
}

-(void)addRocket {
    NSString *firePath = [[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"];
    SKEmitterNode *fire = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    
    SKTexture *rocketTexture1 = [SKTexture textureWithImageNamed:@"rocket_1.png"];
    rocketTexture1.filteringMode = SKTextureFilteringNearest;
    
    rocket = [SKSpriteNode spriteNodeWithTexture:rocketTexture1];
    [rocket setScale:0.2];
    //rocket.position = point;
    //Attivare movimento
    
    rocket.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(rocket.size.height)*(rocket.yScale*2)];
    rocket.physicsBody.dynamic = YES;
    rocket.physicsBody.categoryBitMask = shipCategory;
    rocket.physicsBody.contactTestBitMask = enemyCategory | lifeCategory | pointCategory;
    rocket.physicsBody.collisionBitMask = 0;
    rocket.name = @"ship";
    
    rockettrail = fire;
    
    //the y-position needs to be slightly behind the spaceship
    rockettrail.position = CGPointMake(-390, 0.0);
    
    rockettrail.emissionAngle =  DEG2RAD(180.0f);
    
    //scaling the particlesystem
    rockettrail.xScale = 8.0;
    rockettrail.yScale = 8.7;
     rockettrail.zPosition = 2;
    //rockettrail.targetNode = self.scene;
    [rocket addChild:rockettrail];
    rocket.position = CGPointMake(50+(self.frame.size.width / 4), CGRectGetMidY(self.frame));
    rocket.zPosition = gameLayer;
    [self addChild:rocket];
}

-(void)addNewLife:(CGPoint) point {
    NewLife *life = [[NewLife alloc] initWithPosition:point];

    life.life.physicsBody.dynamic = NO;
    life.life.physicsBody.categoryBitMask = lifeCategory;
    life.life.physicsBody.contactTestBitMask = shipCategory;
    life.life.physicsBody.collisionBitMask = 0;

    [self addChild:life.life];
}

-(void)didMoveToView:(SKView *)view {
    
    FileSupport *pointFile = [[FileSupport alloc] init];
    pointFile.fileName = @"FlySimPoint";
    NSMutableArray *pointArray = [pointFile  readObjectFromFile:@"FlySimPoint"];
    if(pointArray==nil)
        MAX_POINT = 0;
    else
        MAX_POINT = [[pointArray objectAtIndex:0] floatValue];

    
    if(_WelcomeScreen) {
        
        enemy_array = [[NSMutableDictionary alloc] init];
        LEVEL = 1;
        SpeedLevel = 5;
        numberOfStar=1;
        MAX_NUM_OF_STAR_PER_LEVEL = 100;
        enemyRateo = 0.80;  //0.95
        numberOfStar=0;
        Life = 5;
        ufo_point_cnt = 0;
        lifeArray = [[NSMutableArray alloc] init];
    
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);  //-5.0 per cadere
        self.physicsWorld.contactDelegate = self;
        
        //Create SkyColor
        _skyColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.9 alpha:1.0];
        [self setBackgroundColor:_skyColor];
        [self initalizingScrollingBackground];
        [self startBackgroundMusic];
        [self addRocket];
    
        scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        scoreLabel.text = @"Score: 0";
        scoreLabel.fontSize = 48;
        scoreLabel.zPosition = otherLayer;  //
        scoreLabel.position = CGPointMake(CGRectGetMaxX(self.frame)-(scoreLabel.frame.size.width/2)-20,
                                      CGRectGetMaxY(self.frame)-scoreLabel.fontSize);
        [scoreLabel setScale:1];
        [self addChild:scoreLabel];
        
    /*    SKLabelNode * pauseLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        pauseLabel.text = @"Pause";
        pauseLabel.fontSize = 48;
        pauseLabel.zPosition = otherLayer;  //
        pauseLabel.position = CGPointMake((CGRectGetMaxX(self.frame)/2)-(pauseLabel.frame.size.width/2)-20,
                                          CGRectGetMaxY(self.frame)-pauseLabel.fontSize);
        [pauseLabel setScale:1];
        [self addChild:pauseLabel];
*/
    
        [self checkLife];
        [self addJoystick];

        float timing = skRand(15, 16);
        timerPlanet = [NSTimer scheduledTimerWithTimeInterval:timing target:self selector:@selector(showPlanet) userInfo:nil repeats:NO];
        timerGenerator = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(generateNewStar) userInfo:nil repeats:NO];
        
     //   [self addSuperEnemy];
        
    }
    else
    {
        WecomeScreen *mainScene = [[WecomeScreen alloc] initWithSize:self.size];
        SKTransition *transition = [SKTransition flipVerticalWithDuration:0.5];
        [self.view presentScene:mainScene transition:transition];
        _WelcomeScreen = true;
    }
}

- (void)checkButtons
{
    if (normalButton.wasPressed) {
        [self fire];
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
    }
    
    if([type containsString:@"ufo"]) {
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
    }
    [self addChild:explosion];
    explosion.zPosition = gameLayer;
    return explosion;
}

-(SKSpriteNode *)newEnemyMissile
{
    SKTexture *rocketTexture1 = [SKTexture textureWithImageNamed:@"spark.png"];
    rocketTexture1.filteringMode = SKTextureFilteringNearest;
    SKSpriteNode *missile = [SKSpriteNode spriteNodeWithTexture:rocketTexture1];
    
    missile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(missile.size.height/2)];
    missile.physicsBody.categoryBitMask = enemyMissileCategory;
    missile.physicsBody.dynamic = YES;
    missile.physicsBody.contactTestBitMask =  shipCategory | missileCategory;
    missile.physicsBody.collisionBitMask = 0;
    missile.name = @"enemy_laser";
    missile.zPosition = gameLayer;
    NSString *firePath = [[NSBundle mainBundle] pathForResource:@"Enemy" ofType:@"sks"];
    SKEmitterNode *fire = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    
    fire.emissionAngle =  DEG2RAD(0.0f);
    
    [missile addChild:fire];
    
    //add this node to parent node
    //    [self addChild:explosion];
    return missile;
}


// ATTENZIONE CONTROLLA QUESTO
-(SKSpriteNode *)newMissile
{
    
    SKTexture *rocketTexture1 = [SKTexture textureWithImageNamed:@"spark.png"];
    rocketTexture1.filteringMode = SKTextureFilteringNearest;
    SKSpriteNode *missile = [SKSpriteNode spriteNodeWithTexture:rocketTexture1];
    
    missile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(missile.size.height/2)];
    missile.physicsBody.categoryBitMask = missileCategory;
    missile.physicsBody.dynamic = YES;
    missile.physicsBody.contactTestBitMask =  enemyCategory | pointCategory | lifeCategory;
    missile.physicsBody.collisionBitMask = 0;
    missile.name = @"missile";
    missile.zPosition = gameLayer;
    NSString *firePath = [[NSBundle mainBundle] pathForResource:@"Projectile" ofType:@"sks"];
    SKEmitterNode *fire = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    
    fire.emissionAngle =  DEG2RAD(180.0f);
    
    [missile addChild:fire];

            //add this node to parent node
    //    [self addChild:explosion];
    return missile;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    //UITouch *touch = [touches anyObject];
   // CGPoint touchLocation = [touch locationInNode:self.scene];
   // NSLog(@"Touch :%lu",[touches count]);
}

-(void)fire {
    // 1 - Choose one of the touches to work with
    CGPoint location = rocket.position;
    
    // 2 - Set up initial location of projectile
    SKSpriteNode *projectile = [self newMissile];
    projectile.position = rocket.position;
    
    // 3- Determine offset of location to projectile
    CGPoint offset = rwSub(location, projectile.position);
    
    // 4 - Bail out if you are shooting down or backwards
    //if (offset.x <= 0) return;
    offset = CGPointMake(10, 0);
    // 5 - OK to add now - we've double checked position
    [self addChild:projectile];
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = rwNormalize(offset);
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // 8 - Add the shoot amount to the current position
    CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    // 9 - Create the actions
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction *laserFireSoundAction = [SKAction playSoundFileNamed:@"laser_ship.caf" waitForCompletion:NO];
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    SKAction *removeNode = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[laserFireSoundAction,actionMove, actionMoveDone,removeNode]]];
}

-(void)enemyFire {
    if(superEnemy!=nil && imageJoystick!=nil) {
    // 1 - Choose one of the touches to work with
        CGPoint location = rocket.position;
    
    // 2 - Set up initial location of projectile
    SKSpriteNode *projectile = [self newEnemyMissile];
    projectile.name = @"enemy_laser";
    projectile.position = superEnemy.enemy.position;
    
    // 3- Determine offset of location to projectile
    CGPoint offset = rwSub(location, projectile.position);
    
    // 4 - Bail out if you are shooting down or backwards
    //if (offset.x <= 0) return;
    offset = CGPointMake(-10, 0);
    // 5 - OK to add now - we've double checked position
    [self addChild:projectile];
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = rwNormalize(offset);
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // 8 - Add the shoot amount to the current position
    CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    // 9 - Create the actions
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction *laserFireSoundAction = [SKAction playSoundFileNamed:@"laser_ship.caf" waitForCompletion:NO];
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    SKAction *removeNode = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[laserFireSoundAction,actionMove, actionMoveDone,removeNode]]];
    
    timerEnemyShoot= nil;
    float timing = skRand(0.5, 1);
    if(enemyCanFire)
        timerEnemyShoot = [NSTimer scheduledTimerWithTimeInterval:timing target:self selector:@selector(enemyFire) userInfo:nil repeats:NO];
    }
}


-(void)enemyFireNode:(NSTimer *)params {
    
    SKSpriteNode *node = (SKSpriteNode*)[params userInfo];
    
    if(node.parent) {
    
        // 1 - Choose one of the touches to work with
        CGPoint location = rocket.position;
        
        // 2 - Set up initial location of projectile
        SKSpriteNode *projectile = [self newEnemyMissile];
        projectile.name = @"enemy_laser";
        projectile.position = node.position;
        
        // 3- Determine offset of location to projectile
        CGPoint offset = rwSub(location, projectile.position);
        
        // 4 - Bail out if you are shooting down or backwards
        //if (offset.x <= 0) return;
        offset = CGPointMake(-10, 0);
        // 5 - OK to add now - we've double checked position
        [self addChild:projectile];
        
        // 6 - Get the direction of where to shoot
        CGPoint direction = rwNormalize(offset);
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        CGPoint shootAmount = rwMult(direction, 1000);
        
        // 8 - Add the shoot amount to the current position
        CGPoint realDest = rwAdd(shootAmount, projectile.position);
        
        // 9 - Create the actions
        float velocity = 480.0/1.0;
        float realMoveDuration = self.size.width / velocity;
        SKAction *laserFireSoundAction = [SKAction playSoundFileNamed:@"laser_ship.caf" waitForCompletion:NO];
        SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
        SKAction * actionMoveDone = [SKAction removeFromParent];
        SKAction *removeNode = [SKAction removeFromParent];
        [projectile runAction:[SKAction sequence:@[laserFireSoundAction,actionMove, actionMoveDone,removeNode]]];
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
        gameOverLabel.zPosition = otherLayer;
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
        
        [self addSuperEnemy];
     //   self.gameOver = YES;
        //return;
    }
    
    [scoreLabel setText:[NSString stringWithFormat:@"Score: %ld", (long)score]];
    [self savePoint];
}

- (void)addStar
{
    SKSpriteNode *star = [[SKSpriteNode alloc] initWithImageNamed:@"rock_3.png"];
    star.xScale = 0.5;
    star.yScale = 0.5;
    star.zPosition = gameLayer;
    star.position = CGPointMake(self.size.width, skRand(0, self.size.height-20));
    star.name = @"star";
    star.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(star.size.width/2)*star.yScale];
    star.physicsBody.dynamic = false;
    star.physicsBody.categoryBitMask = lowEnemyCategory;
    star.physicsBody.contactTestBitMask =  shipCategory | missileCategory;
    star.physicsBody.collisionBitMask = 0;
    
    SKAction *actionMoveStar = [SKAction moveByX:-1*(self.size.width+star.size.width) y:0 duration:SpeedLevel];
    SKAction *removeNode = [SKAction removeFromParent];
    
    SKAction *sequence = [SKAction sequence:@[actionMoveStar, removeNode]];
    [star runAction:sequence];
    
    float rot = skRand(0, 2);
    SKAction *oneRevolution;
    
    if(rot<=1)
        oneRevolution = [SKAction rotateByAngle:-M_PI*rot duration: 8.0];
    else
        oneRevolution = [SKAction rotateByAngle:M_PI*rot duration: 8.0];
    
    SKAction *repeat = [SKAction repeatActionForever:oneRevolution];
    [star runAction:repeat];
    
    /* If you want rebounding stars instead of explosions.       *
     * You need to remove collision detection in order to do so  *
     *                                                           *
     //star.physicsBody.usesPreciseCollisionDetection = YES;     */
    
    numberOfStar++;
    StarGenerated++;
    [self levelUp];
    [self addChild:star];
}


-(void)followShip:(SKSpriteNode*) star {
    // Imagine shooting an arrow to a point
    CGMutablePathRef path = CGPathCreateMutable();
    
    // This will move an invisible path marker to a starting point
    // In my case, the node is a child node of a sprite, so it is the local coords and not the screen coords
    CGPathMoveToPoint(path, NULL, star.position.x-10,star.position.y);
    
    // The 3-8th parameters are x/y coords. The arrow iwll first hit x:100 and y:50.
    // It will then raise up a bit as it keeps going and finally drop to the target at x:300 y:0
    if(star.position.y>= rocket.position.y) {
        CGPathAddCurveToPoint(path, NULL,
                          star.position.x-20, star.position.y,
                          rocket.position.x, rocket.position.y-(star.size.height*star.yScale),
                          -(star.size.width+10),rocket.position.y);  //
    }
    else
    {
        CGPathAddCurveToPoint(path, NULL,
                              star.position.x-20, star.position.y,
                              rocket.position.x, rocket.position.y+(star.size.height*star.yScale),
                              -(star.size.width+10),rocket.position.y);  //
    }
    float deltaX = (star.position.x - rocket.position.x);
    deltaX = (deltaX)/self.size.width;
    
    // Create an action based on this curve. oritentToPath will make the arrows tip point up and down in the correct spots.
    // Be careful, it is based off of each sprite having the correct default state. (i.e.: arrows and characters are vertical by default)
  
    
    SKAction *followCurve = [SKAction followPath:path asOffset:NO orientToPath:NO duration:SpeedLevel*deltaX];
    
  //  SKAction *removeNode = [SKAction removeFromParent];
    
  //  SKAction *sequence = [SKAction sequence:@[followCurve, removeNode]];
    
   
    [star removeAllActions];
    //[star runAction:sequence];
    [star runAction:followCurve];
}


-(void)newText:(NSString *) test start_to:(CGPoint) start_point {
    
    SKLabelNode *label;
    label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.text =  test;
    label.fontSize = 20;
    label.zPosition = otherLayer;
    label.position = start_point;
    [label setScale:1];
    [self addChild:label];

    
    
    // Imagine shooting an arrow to a point
    CGMutablePathRef path = CGPathCreateMutable();
    
    // This will move an invisible path marker to a starting point
    // In my case, the node is a child node of a sprite, so it is the local coords and not the screen coords
    CGPathMoveToPoint(path, NULL, start_point.x,start_point.y);
    
    // The 3-8th parameters are x/y coords. The arrow iwll first hit x:100 and y:50.
    // It will then raise up a bit as it keeps going and finally drop to the target at x:300 y:
    CGPathAddCurveToPoint(path, NULL,
                              start_point.x,start_point.y,
                              self.size.width/2, self.size.height/2,  //Center of screen
                              self.size.width/2,self.size.height);  //

    
    // Create an action based on this curve. oritentToPath will make the arrows tip point up and down in the correct spots.
    // Be careful, it is based off of each sprite having the correct default state. (i.e.: arrows and characters are vertical by default)
    
    SKAction *remove = [SKAction removeFromParent];
    SKAction *followCurve = [SKAction followPath:path asOffset:NO orientToPath:NO duration:1.5];
    SKAction *actions = [SKAction sequence:@[followCurve,remove]];
    
    //  SKAction *removeNode = [SKAction removeFromParent];
    
    //  SKAction *sequence = [SKAction sequence:@[followCurve, removeNode]];
    
    
    [label removeAllActions];
    //[star runAction:sequence];
    [label runAction:actions];
}


-(void)setShipForCollision {
   // rocket.physicsBody.categoryBitMask = 4294967295;
   // rocket.physicsBody.contactTestBitMask = 0;
   // rocket.physicsBody.collisionBitMask = 0;
}

-(void)unsetShioForCollision {
   // rocket.physicsBody.categoryBitMask = shipCategory;
   // rocket.physicsBody.contactTestBitMask = enemyCategory | lifeCategory | pointCategory;
   // rocket.physicsBody.collisionBitMask = 0;
}

-(void)addSuperEnemy {
    [self shake:5];
    stopStar = true;
    Enemy *ufo = [[Enemy alloc] initSuperEnemy:10*LEVEL];
    ufo.name = [NSString stringWithFormat:@"ufo %0.f s",numberOfUfo];
    [enemy_array setObject:ufo forKey:ufo.name];
    ufo.enemy.name = [NSString stringWithFormat:@"ufo %0.f s",numberOfUfo];
    //ufo.enemy.position = CGPointMake(self.size.width, skRand(0, self.size.height-20));
    numberOfUfo++;
    ufo.enemy.zPosition = gameLayer;
    [self setShipForCollision];
    ufo.enemy.position = CGPointMake(self.size.width, self.size.width/2);
    enemyCanFire = true;
    ufo.numberOfHit = 10*LEVEL;
    ufo.healthBar.zPosition = gameLayer;
    [self addChild:ufo.healthBar];
    [self addChild:ufo.enemy];
    
    SKAction *actionMoveEnemyX = [SKAction moveToX:(self.size.width/3)*2 duration:4];
    SKAction *actionMoveEnemyY = [SKAction moveToY:rocket.position.y duration:4];
    [ufo.enemy runAction:[SKAction sequence:@[actionMoveEnemyX,actionMoveEnemyY]]];
    superEnemy = ufo;
    [self enemyFire];
}

- (void)addUfo
{
    Enemy *ufo = [[Enemy alloc] initWithPosition:CGPointMake(self.size.width, skRand(0, self.size.height-20))];
    ufo.name = [NSString stringWithFormat:@"ufo %0.f",numberOfUfo];
    [enemy_array setObject:ufo forKey:ufo.name];
    ufo.enemy.name = [NSString stringWithFormat:@"ufo %0.f",numberOfUfo];
    numberOfUfo++;
    ufo.enemy.zPosition = gameLayer;
    ufo.enemy.position = CGPointMake(self.size.width, skRand(0, self.size.height-20));
    ufo.healthBar.zPosition = gameLayer;
    [self followShip:ufo.enemy];
    [self addChild:ufo.healthBar];
    [self addChild:ufo.enemy];
    [NSTimer scheduledTimerWithTimeInterval:skRand(0.5, 2) target:self selector:@selector(enemyShoot:) userInfo:ufo.enemy repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:skRand(0.5, 2) target:self selector:@selector(enemyShoot:) userInfo:ufo.enemy repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:skRand(0.5, 2) target:self selector:@selector(enemyShoot:) userInfo:ufo.enemy repeats:NO];
}


-(void) enemyShoot:(NSTimer*) params {
    [self enemyFireNode:params];
}

-(void)didSimulatePhysics
{
    [[self children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKNode *node = (SKNode *)obj;
        if ([node.name containsString:@"ufo"]) {
            if (node.position.x < 0) {
                Enemy *en = [enemy_array objectForKey:node.name];
                [en.healthBar removeFromParent];
                [enemy_array removeObjectForKey:node.name];
                [node removeFromParent];
                numberOfUfo--;
            }
        }
        else if ([node.name containsString:@"missile"]) {
            if (node.position.x > self.frame.size.width) {
                [node removeFromParent];
                numberOfWeapons--;
            }
        }
        else if ([node.name containsString:@"star"]) {
            if (node.position.x < 0) {
                [node removeFromParent];
                numberOfStar--;
            }
        }
    }];
    
    if(numberOfUfo<=0 && numberOfStar<=0) {
        stopStar = false;
     //   [self generateNewStar];
    }
}

-(SKEmitterNode*) newBubble {
        SKEmitterNode *explosion = [[SKEmitterNode alloc] init];
        //TODO: set the right properties for your particle system!
        [explosion setParticleTexture:[SKTexture textureWithImageNamed:@"bokeh.png"]];
        [explosion setParticleColor:[UIColor whiteColor]];
        [explosion setNumParticlesToEmit:50];
        [explosion setParticleBirthRate:100];
        [explosion setParticleLifetime:2];
        [explosion setEmissionAngleRange:360];
        [explosion setParticleSpeed:100];
        [explosion setParticleSpeedRange:50];
        [explosion setXAcceleration:0];
        [explosion setYAcceleration:0];
        [explosion setParticleAlpha:0.5];
        [explosion setParticleAlphaRange:0.2];
        [explosion setParticleAlphaSpeed:-0.5];
        [explosion setParticleScale:0.40];
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
       // [self addChild:explosion];
    
        return explosion;
}


-(void)blinkNode:(SKSpriteNode*)node {
        SKAction *blink = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.1],
                                               [SKAction fadeInWithDuration:0.1]]];
        SKAction *blinkForTime = [SKAction repeatAction:blink count:2];
        [node runAction:blinkForTime];
}

//-----------------------THIS WILL BE BETTER----------------------------------
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    BOOL canDestroyed = false;
    //insantiate new explosion on contact
    //set the position of contact
    // ex.position = contact.bodyB.node.position;
    SKEmitterNode *ex;
    
    SKPhysicsBody *shipBody, *otherBody;
    
    if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        shipBody = contact.bodyA;
        otherBody = contact.bodyB;
    }
    else
    {
        shipBody = contact.bodyB;
        otherBody = contact.bodyA;
    }
    
    if ((shipBody.categoryBitMask & shipCategory) != 0)
    {
        if((otherBody.categoryBitMask & lowEnemyCategory) != 0)   //Collision with little asteroids
        {
            hitWithAsteroids++;
            if(hitWithAsteroids>=5)
            {
                hitWithAsteroids=0;
                [self deleteLife];
                [self shake:2];
                numberOfStar--;
            }
            SKEmitterNode *fire = [self newBubble];
            fire.position = rocket.position;
            fire.xScale = 3.0;
            fire.yScale = 3.0;
            [self shake:2];
            [self addChild:fire];
            [otherBody.node removeFromParent];
        }
        else if((otherBody.categoryBitMask & lifeCategory) != 0)
        {
            // Ship contach with a new life
            NSLog(@"Ship -> Life");
            SKAction *explosion_ufo = [SKAction playSoundFileNamed:@"powerup.caf" waitForCompletion:NO];
            [self runAction:explosion_ufo];
            [self addLife];
            [self checkLife];
            [self newText:@"+1 Life!" start_to:otherBody.node.position];
            [otherBody.node removeFromParent];
            SKEmitterNode *fire = [self newBubble];
            fire.position = rocket.position;
            [self addChild:fire];
        }
        else if((otherBody.categoryBitMask & superEnemyCategory) != 0)
        {
            Life = 1;
            [self deleteLife];
        }
        else if((otherBody.categoryBitMask & enemyCategory) != 0)
        {
            NSLog(@"Ship -> Enemy");
            SKAction *explosion_ufo ;
            ex = [self newExplosion:@"ufo"];
            Enemy *obj_ufo = [enemy_array objectForKey:otherBody.node.name];
            [self deleteLife];
            [self shake:2];
            explosion_ufo = [SKAction playSoundFileNamed:@"explosion_large.caf" waitForCompletion:NO];
            [enemy_array removeObjectForKey:otherBody.node.name];
            [obj_ufo.healthBar removeFromParent];
            [self runAction:explosion_ufo];
            ex.position = otherBody.node.position;
            [otherBody.node removeFromParent];
        }
        else if((otherBody.categoryBitMask & enemyMissileCategory) != 0)
        {
            NSLog(@"Ship -> Enemy Missile");
            [otherBody.node removeFromParent];
            canDestroyed = true;
            [self deleteLife];
            [self shake:2];
            SKAction *explosion_ufo = [SKAction playSoundFileNamed:@"explosion_large.caf" waitForCompletion:NO];
            [self runAction:explosion_ufo];

        }
       /* else if((otherBody.categoryBitMask & pointCategory) != 0)  //Ship get a point
        {
            NSLog(@"Ship -> Point");
            canDestroyed = true;
            numberOfStar--;
            score++;
            SKAction *explosion_ufo = [SKAction playSoundFileNamed:@"powerup.caf" waitForCompletion:NO];
            [self runAction:explosion_ufo];
            SKEmitterNode *fire = [self newBubble];
            fire.position = rocket.position;
            [self addChild:fire];
            [otherBody.node removeFromParent];
        }
        */
    }
    
    
    if ((shipBody.categoryBitMask & missileCategory) != 0)
    {
        if((otherBody.categoryBitMask & lifeCategory) != 0)
        {  // Ship contach with a new life
            NSLog(@"Missile -> Life");
        }
        else if((otherBody.categoryBitMask & lowEnemyCategory) != 0)
        {
            NSLog(@"Missile -> Enemy Missile");
            SKAction *explosion_ufo ;
            ex = [self newExplosion:@"ufo"];
            ex.position = otherBody.node.position;
            hitMissileAsteroid++;
            if(hitMissileAsteroid>=8)
            {
                hitMissileAsteroid=0;
                [otherBody.node removeFromParent];
                [shipBody.node removeFromParent];
                explosion_ufo = [SKAction playSoundFileNamed:@"explosion_large.caf" waitForCompletion:NO];
                [self runAction:explosion_ufo];
            }

        }
        else if((otherBody.categoryBitMask & superEnemyCategory) != 0)
        {
            NSLog(@"Missile -> Enemy");
            SKAction *explosion_ufo;
            [shipBody.node removeFromParent];
            Enemy *obj_ufo = [enemy_array objectForKey:otherBody.node.name];
            if(stopStar) {
                [self blinkNode:obj_ufo.enemy];
            }
            if([obj_ufo hit])
            {
                if(obj_ufo.superEnemy) {
                    stopStar = false;
                    enemyCanFire = false;
                    superEnemy = nil;
                    score += 10;
                    [self addNewLife:otherBody.node.position];
                    [self newText:@"Great! +10 point" start_to:otherBody.node.position];
                }
                else {
                    ufo_point_cnt++;
                    if(ufo_point_cnt>=5) {
                        [self newText:@"+1 Point" start_to:otherBody.node.position];
                        ufo_point_cnt = 0;
                    }
                }
                canDestroyed = true;
                explosion_ufo = [SKAction playSoundFileNamed:@"explosion_small.caf" waitForCompletion:NO];
                ex = [self newExplosion: @"ufo"];
                ex.position = otherBody.node.position;
                [self runAction:explosion_ufo];
                ex.position = otherBody.node.position;
                [enemy_array removeObjectForKey:otherBody.node.name];
                [obj_ufo.healthBar removeFromParent];
                [otherBody.node removeFromParent];
            }
        }
        else if((otherBody.categoryBitMask & enemyCategory) != 0)
        {
            NSLog(@"Missile -> Enemy");
            SKAction *explosion_ufo;
            [shipBody.node removeFromParent];
            Enemy *obj_ufo = [enemy_array objectForKey:otherBody.node.name];
            if(stopStar) {
                [self blinkNode:obj_ufo.enemy];
            }
            if([obj_ufo hit])
            {
                if(obj_ufo.superEnemy) {
                    stopStar = false;
                    enemyCanFire = false;
                    superEnemy = nil;
                    score += 10;
                    [self addNewLife:otherBody.node.position];
                    [self newText:@"Great! +10 point" start_to:otherBody.node.position];
                }
                else {
                    [self newText:@"+1 Point" start_to:otherBody.node.position];
                    score++;
                }
                canDestroyed = true;
                explosion_ufo = [SKAction playSoundFileNamed:@"explosion_small.caf" waitForCompletion:NO];
                ex = [self newExplosion: @"ufo"];
                ex.position = otherBody.node.position;
                [self runAction:explosion_ufo];
                ex.position = otherBody.node.position;
                [enemy_array removeObjectForKey:otherBody.node.name];
                [obj_ufo.healthBar removeFromParent];
                [otherBody.node removeFromParent];
            }

        }
        else if((otherBody.categoryBitMask & enemyMissileCategory) != 0)
        {
            NSLog(@"Missile -> Enemy Missile");
            SKAction *explosion_ufo ;
            ex = [self newExplosion:@"ufo"];
 
            explosion_ufo = [SKAction playSoundFileNamed:@"explosion_large.caf" waitForCompletion:NO];
            [self runAction:explosion_ufo];
            ex.position = otherBody.node.position;
            [otherBody.node removeFromParent];
            [shipBody.node removeFromParent];
        }
        else if((otherBody.categoryBitMask & pointCategory) != 0)
        {
            canDestroyed = true;
            numberOfStar--;
            NSLog(@"Missile -> Point");
            SKEmitterNode *ex = [self newExplosion: @"star"];
            ex.position = otherBody.node.position;
            [shipBody.node removeFromParent];                          //Remove the missile
            [otherBody.node removeFromParent];                          //Remove the astronaut
            SKAction *explosion_ufo = [SKAction playSoundFileNamed:@"shake.caf" waitForCompletion:NO];
            [self runAction:explosion_ufo];
        }
    }
}

-(void)addLife {
    if(Life<5)
        Life++;
}

-(void)deleteLife {
    
    SKNode *object = [lifeArray objectAtIndex:(Life-1)];
    SKEmitterNode *ex = [self newExplosion: @"point"];
    
    //set the position of contact
    ex.position = object.position;
    
    [object removeFromParent];
    Life--;
    [self checkLife];
    if(Life<=0)
    {
        [_backgroundAudioPlayer stop];
        _backgroundAudioPlayer = nil;
        WecomeScreen *mainScene = [[WecomeScreen alloc] initWithSize:self.size];
        mainScene.GameOver = true;
        SKTransition *transition = [SKTransition flipVerticalWithDuration:0.5];
        [self.view presentScene:mainScene transition:transition];
    }
}

-(void)checkLife {
    SKTexture *life_text = [SKTexture textureWithImageNamed:@"rocket_1.png"];
    life_text.filteringMode = SKTextureFilteringNearest;
    
    for(int i=1;i<6;i++) {
    SKNode *temp;
    temp = [self childNodeWithName:[NSString stringWithFormat:@"life%d",i] ];
    if(temp != nil)
        [temp removeFromParent];
    }
    
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
    life1.zPosition=otherLayer;
    life1.name = @"life1";


    [life2 setScale:0.05];
    life2.position = CGPointMake(x_master-(d_x+10),
                                 y_master+d_y);
    life2.zRotation = M_PI/2;
    life2.zPosition=otherLayer;
    life2.name = @"life2";

  
    [life3 setScale:0.05];
    life3.position = CGPointMake(x_master-(d_x+40),
                                 y_master+d_y);
    life3.zRotation = M_PI/2;
    life3.zPosition=otherLayer;
    life3.name = @"life3";
    
 
    [life4 setScale:0.05];
    life4.position = CGPointMake(x_master-(d_x+70),
                                 y_master+d_y);
    life4.zRotation = M_PI/2;
    life4.zPosition=otherLayer;
    life4.name = @"life4";
    
 
    [life5 setScale:0.05];
    life5.position = CGPointMake(x_master-(d_x+100),
                                 y_master+d_y);
    life5.zRotation = M_PI/2;
    life5.zPosition=otherLayer;
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

-(void)shake:(NSInteger)times {
    //animate quake, shake the scene
    SKAction* moveX_1 = [SKAction moveBy:CGVectorMake(-7, 0) duration:0.05];
    SKAction* moveX_2 = [SKAction moveBy:CGVectorMake(-10, 0) duration:0.05];
    SKAction* moveX_3 = [SKAction moveBy:CGVectorMake(7, 0) duration:0.05];
    SKAction* moveX_4 = [SKAction moveBy:CGVectorMake(10, 0) duration:0.05];
    
    SKAction* moveY_1 = [SKAction moveBy:CGVectorMake(-0, -7) duration:0.05];
    SKAction* moveY_2 = [SKAction moveBy:CGVectorMake(0, -10) duration:0.05];
    SKAction* moveY_3 = [SKAction moveBy:CGVectorMake(0, 7) duration:0.05];
    SKAction* moveY_4 = [SKAction moveBy:CGVectorMake(0, 10) duration:0.05];
    
    SKAction* trembleX = [SKAction sequence:@[moveX_1, moveX_4, moveX_2, moveX_3]];
    SKAction* trembleY = [SKAction sequence:@[moveY_1, moveY_4, moveY_2, moveY_3]];
    
    for (SKNode *child in self.children) {
        [child runAction:trembleX];
        [child runAction:trembleY];
    }
}



-(void)generateNewStar {
    float type = skRand(0, 1);
    if(maxNumberOfStar==0) maxNumberOfStar=10;
    
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
    if(numberOfStar>=(maxNumberOfStar+1))
    {
        numOfTryLoadStar++;
        if(numOfTryLoadStar>=5)
        {
            numOfTryLoadStar=0;
            numberOfStar = 0;
            NSLog(@"Unlock star generator");
        }
    }
    
    timerGenerator = nil;
    float timing = skRand(0.2, 2);
    timerGenerator = [NSTimer scheduledTimerWithTimeInterval:timing target:self selector:@selector(generateNewStar) userInfo:nil repeats:NO];
}

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

-(void) drawHealthBar:(SKNode *)node withName:(NSString *)name andHealthPoints:(int)hp andMaxHP:(int)MaxHP
{
    [node removeAllChildren];
    
    //MaxHP = maxHPG;
    
    float widthOfHealth = (HealthBarWidth - 2.0f)*hp/MaxHP;
    
    UIColor *clearColor = [UIColor clearColor];
    UIColor *fillColor = [UIColor colorWithRed:113.0f/255.0f green:202.0f/255.0f blue:53.0f/255.0f alpha:1.0f];
    UIColor *endColor = [UIColor colorWithRed:202.0f/255.0f green:113.0f/255.0f blue:53.0f/255.0f alpha:1.0f];
  //  UIColor *borderColor = [UIColor colorWithRed:35.0f/255.0f green:28.0f/255.0f blue:40.0f/255.0f alpha:1.0f];
    UIColor *borderColor = [UIColor whiteColor];
    
    //create the outline for the health bar
    CGSize outlineRectSize = CGSizeMake(HealthBarWidth-1.0f, HealthBarHeight-1.0);
    UIGraphicsBeginImageContextWithOptions(outlineRectSize, NO, 0.0);
    CGContextRef healthBarContext = UIGraphicsGetCurrentContext();
    
    //Drawing the outline for the health bar
    CGRect spriteOutlineRect = CGRectMake(0.0, 0.0, HealthBarWidth-1.0f, HealthBarHeight-1.0f);
    CGContextSetStrokeColorWithColor(healthBarContext, borderColor.CGColor);
    CGContextSetLineWidth(healthBarContext, 1.0);
    CGContextAddRect(healthBarContext, spriteOutlineRect);
    CGContextStrokePath(healthBarContext);
    
    //Fill the health bar with a filled rectangle
    CGRect spriteFillRect = CGRectMake(0.5, 0.5, outlineRectSize.width-1.0, outlineRectSize.height-1.0);
    spriteFillRect.size.width = widthOfHealth;
    
    CGContextSetFillColorWithColor(healthBarContext, fillColor.CGColor);
    
    CGContextSetStrokeColorWithColor(healthBarContext, clearColor.CGColor);
    CGContextSetLineWidth(healthBarContext, 1.0);
    CGContextFillRect(healthBarContext, spriteFillRect);
    
    //Generate a sprite image of the two pieces for display
    UIImage *spriteImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef spriteCGImageRef = [spriteImage CGImage];
    SKTexture *spriteTexture = [SKTexture textureWithCGImage:spriteCGImageRef];
    spriteTexture.filteringMode = SKTextureFilteringLinear; //This is the default anyway
    SKSpriteNode *frameSprite = [SKSpriteNode spriteNodeWithTexture:spriteTexture size:outlineRectSize];
    frameSprite.position = CGPointZero;
    frameSprite.name = name;
    frameSprite.anchorPoint = CGPointMake(0.0, 0.5);
    
    [node addChild:frameSprite];
}

-(void)update:(CFTimeInterval)currentTime {
    
    /* Called before each frame is rendered */
    CFTimeInterval timeSinceLast = currentTime - lastUpdateTimeInterval;
    lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        lastUpdateTimeInterval = currentTime;
    }
    
    if(oldy < imageJoystick.y)
    {
        SKAction *actionMoveUp = [SKAction moveByX:0 y:5 duration:.2];
        [rocket runAction:actionMoveUp];
    }
    else if(oldy > imageJoystick.y)
    {
        SKAction *actionMoveDown = [SKAction moveByX:0 y:-5 duration:.2];
        [rocket runAction:actionMoveDown];

    }
    
    if(oldx < imageJoystick.x)
    {
        SKAction *actionMoveFw = [SKAction moveByX:5 y:0 duration:.2];
        [rocket runAction:actionMoveFw];
    }
    else if(oldx > imageJoystick.x)
    {
        SKAction *actionMoveRew = [SKAction moveByX:-5 y:0 duration:.2];
        [rocket runAction:actionMoveRew];
        
    }
    
    if(rocket.position.x<0) //|| rocket.rocket.position.x>self.frame.size.width)
    {
        rocket.position = CGPointMake(0,rocket.position.y);
    }
    if(rocket.position.x>self.frame.size.width)
    {
        rocket.position = CGPointMake(self.frame.size.width,rocket.position.y);
    }
    
    if(rocket.position.y<0) //|| rocket.rocket.position.x>self.frame.size.width)
    {
        rocket.position = CGPointMake(rocket.position.x,0);
    }
    if(rocket.position.y>self.frame.size.height)
    {
        rocket.position = CGPointMake(rocket.position.x,self.frame.size.height);
    }
    oldx = imageJoystick.x;
    oldy = imageJoystick.y;
    
    [self checkButtons];
    [self didSimulatePhysics];
  //  [self drawHealthBar:_playerHealthBar withName:@"playerHealth" andHealthPoints:_playerHP];
    
    //***** Ufo search the ship ********
    [[self children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKNode *node = (SKNode *)obj;
        if ([node.name containsString:@"ufo"]) {
            Enemy *mm = [enemy_array objectForKey:node.name];
            [self drawHealthBar:mm.healthBar withName:mm.name andHealthPoints:mm.enemyHP andMaxHP:mm.MaxHP];
            if(!mm.superEnemy)
            {
                mm.healthBar.position = CGPointMake(mm.enemy.position.x - HealthBarWidth/2.0f + 0.5f, mm.enemy.position.y - (mm.enemy.size.height/2.0f - 15.0f + 100.0f) * mm.enemy.yScale);
                lastSpawnTimeInterval += timeSinceLast;
                if (lastSpawnTimeInterval > 1) {
                    lastSpawnTimeInterval = 0;
                    if(node.position.x>rocket.position.x)
                    {
                        [self followShip:(SKSpriteNode*)node];
                        NSLog(@"Follow node: %f",rocket.zPosition);
                    }
                }
            }
            else
            {
                if(stopStar)
                {
                    SKAction *actionMoveEnemy = [SKAction moveToY:rocket.position.y duration:0.7];
                    [mm.enemy runAction:actionMoveEnemy];
                }
                mm.healthBar.position = CGPointMake(mm.enemy.position.x - HealthBarWidth/2.0f + 0.5f, mm.enemy.position.y - (mm.enemy.size.height/2.0f - 15.0f + 200.0f) * mm.enemy.yScale);
                
            }
        }
       /* if ([node.name containsString:@"star"]) {
            NSLog(@"Star");
        }*/
    }];

   // _cannonHP = MAX(0, _cannonHP - 10);
}

@end
