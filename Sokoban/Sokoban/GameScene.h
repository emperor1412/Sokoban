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

    Image *myImage;
	Image *myImage1;
	Image *myImage2;
    Image *aRobotFrame;
    SpriteSheet *robotSpriteSheet;
	
	SpriteSheet *spriteSheet;
	PackedSpriteSheet *packedSpriteSheet;
	Animation *ghostAnim;
	Animation *playerAnim;
	
    Animation *robotAnim;
    
	float scaleAmount;
}

@end
