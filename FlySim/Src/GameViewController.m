//
//  GameViewController.m
//  FlySim
//
//  Created by Riccardo Rizzo on 22/10/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "WelcomeScreen.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameViewController

-(void)viewWillLayoutSubviews {

    [super viewWillLayoutSubviews];

    // Configure the view.
    SKView * skView = (SKView *)self.view;

   if(!skView.scene) {
    // skView.showsFPS = YES;
    // skView.showsNodeCount = YES;
    // skView.showsPhysics = YES;
    // skView.ignoresSiblingOrder = YES;
 
     // Create and configure the scene.
     //GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"]; 
    //GameScene *scene = [GameScene sceneWithSize:skView.bounds.size];
    //scene.scaleMode = SKSceneScaleModeResizeFill;
       GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
       scene.scaleMode =SKSceneScaleModeAspectFit; //SKSceneScaleModeAspectFill;
    
    NSLog(@"width: %f", scene.size.width);
    NSLog(@"Height: %f", scene.size.height);
 
     // Present the scene.
     [skView presentScene:scene];
  }
}

/*- (void)viewDidLoad
{
    [super viewDidLoad];

   // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
    //scene.size = self.view.frame.size;
    //scene.size = skView.bounds.size;
    scene.scaleMode = SKSceneScaleModeAspectFill; //SKSceneScaleModeFill;
    
    // Present the scene.
    [skView presentScene:scene];

   }
 */

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
   /* if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }*/
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
