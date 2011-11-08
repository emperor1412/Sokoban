//
//  GameScene.h
//  SLQTSOR
//
//  Created by Mike Daley on 29/08/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "AbstractScene.h"
#import "GameController.h"
#import "TiledMap.h"


#define kMapWidth 8
#define kMapHeight 12


@class Image;
@class ImageRenderManager;
@class SpriteSheet;
@class PackedSpriteSheet;
@class Animation;
@class Player;



@interface GameScene : AbstractScene {

	ImageRenderManager *sharedImageRenderManager;	
    GameController *sharedGameController;
    
    Image *joypad;
    Player *mainCharacter;    
    TiledMap *tiledMap;
    
    CGRect glViewBounds;    
    
    int joypadTouchHash;
    CGPoint joypadCenter;
    CGSize joypadRectSize;
    CGRect joypadBounds;    
    BOOL isJoypadTouchMoving;
    BOOL blockers[kMapWidth][kMapHeight];
    
    CGRect characterCollisionBounds;
    CGRect rockCollisionBounds[10];
    CGRect rockMovementBounds[10];
    
    int finishCondition[kMapWidth][kMapHeight];
//    BOOL **finishCondition;
    
@public
    NSMutableArray *rocks;
    
}

- (BOOL)isBlocked:(float)x y:(float)y;
- (void)updatePlayerLocationWithDelta:(float)aDelta;

- (void)setUpMapWithFileName:(NSString *)fileName fileExtension:(NSString *)extension;

@end
