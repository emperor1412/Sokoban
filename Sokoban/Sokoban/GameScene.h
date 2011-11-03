//
//  GameScene.h
//  SLQTSOR
//
//  Created by Mike Daley on 29/08/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "AbstractScene.h"
#import "GameController.h"


@class Image;
@class ImageRenderManager;
@class SpriteSheet;
@class PackedSpriteSheet;
@class Animation;
@class Player;

@interface GameScene : AbstractScene {

	ImageRenderManager *sharedImageRenderManager;	
    GameController *sharedGameController;
    
	SpriteSheet *spriteSheetCharacter;
    CGSize characterSpriteSize;
	Animation *playerAnim;	
    Image *tile;
    Image *tile1;
    Image *tile2;
    Image *joypad;
    
    CGPoint playerLocation;
    
    CGRect glViewBounds;
    
    int joypadTouchHash;
    CGPoint joypadCenter;
    CGSize joypadRectSize;
    CGRect joypadBounds;
    float joypadDistance;
    float directionOfTravel;
    
    BOOL isJoypadTouchMoving;
    
    Player *mainCharacter;
}

@end
