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
    Animation *leftAnimation;
    Animation *rightAnimation;
    Animation *upAnimation;
    Animation *downAnimation;
    Animation *currentAnimation;
    
    SpriteSheet *_spriteSheetPlayer;
    
    NSString *_spriteSheetImageName;
    
    float acceleration;
    float velocity;
    float angleOfMovement;
    
    CGPoint _location;
}

@property (nonatomic, retain, setter = setSpriteSheetPlayer:) SpriteSheet *spriteSheetPlayer;
@property (nonatomic, retain, setter = setSpriteSheetImageName:) NSString *spriteSheetImageName;
@property (nonatomic, assign) CGPoint location;

- (void)updateWithDelta:(float)aDelta  scene:(GameScene *)aScene;
- (id)initWithSpriteSheetImageNamed:(NSString *)fileName;

- (void)render;

@end
