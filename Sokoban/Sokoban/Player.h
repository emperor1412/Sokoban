//
//  Player.h
//  Sokoban
//
//  Created by Le Huy Hoang on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Animation.h"
#import "SpriteSheet.h"
#import "GameScene.h"


@interface Player : NSObject {
    
    SpriteSheet *_spriteSheetPlayer;    
    NSString *_spriteSheetImageName;
        
    CGPoint _location;
}

@property (nonatomic, retain, setter = setSpriteSheetPlayer:) SpriteSheet *spriteSheetPlayer;
@property (nonatomic, retain, setter = setSpriteSheetImageName:) NSString *spriteSheetImageName;
@property (nonatomic, assign) CGPoint location;

@property (nonatomic, setter = setAcceleration:) float acceleration;
@property (nonatomic) float velocity;
@property (nonatomic, setter = setAngleOfMovement:) float angleOfMovement;


- (CGRect)movementBounds;
- (CGRect)collisionBounds;
- (void)updateWithDelta:(float)aDelta  scene:(GameScene *)aScene;
- (id)initWithSpriteSheetImageNamed:(NSString *)fileName;

- (void)render;

@end
