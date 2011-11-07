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

    @public
    CGPoint _location;
    

}

@property (nonatomic, retain, setter = setSpriteSheetPlayer:) SpriteSheet *spriteSheetPlayer;
@property (nonatomic, retain, setter = setSpriteSheetImageName:) NSString *spriteSheetImageName;
@property (nonatomic, assign) CGPoint location;

@property (nonatomic, setter = setAcceleration:) float acceleration;
@property (nonatomic) float velocity;
@property (nonatomic, setter = setAngleOfMovement:) float angleOfMovement;

@property (nonatomic, retain)   Animation *leftAnimation;
@property (nonatomic, retain)   Animation *rightAnimation;
@property (nonatomic, retain)   Animation *upAnimation;
@property (nonatomic, retain)   Animation *downAnimation;
@property (nonatomic, assign)   Animation *currentAnimation;


- (CGRect)movementBounds;
- (CGRect)collisionBounds;
- (void)updateWithDelta:(float)aDelta  scene:(GameScene *)aScene;
- (id)initWithSpriteSheetImageNamed:(NSString *)fileName;

- (void)render;

@end
