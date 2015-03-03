//
//  Life.h
//  FlySim
//
//  Created by Riccardo Rizzo on 28/01/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface NewLife : NSObject {
    
}

-(id) initWithPosition:(CGPoint) start_point;
@property (nonatomic,retain) SKSpriteNode *life;

@end
