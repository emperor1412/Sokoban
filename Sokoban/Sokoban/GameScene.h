//
//  GameScene.h
//  SLQTSOR
//
//  Created by Mike Daley on 29/08/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "AbstractScene.h"

@class Image;
@class ImageRenderManager;
@class SpriteSheet;
@class PackedSpriteSheet;
@class Animation;

@interface GameScene : AbstractScene {

	ImageRenderManager *sharedImageRenderManager;	
	SpriteSheet *spriteSheetCharacter;
	Animation *playerAnim;	
    Image *tile;
    Image *tile1;
}

@end
