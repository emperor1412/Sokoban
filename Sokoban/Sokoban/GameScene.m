//
//  GameScene.m
//  SLQTSOR
//
//  Created by Mike Daley on 29/08/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "GameScene.h"
#import "Image.h"
#import "ImageRenderManager.h"
#import "SpriteSheet.h"
#import "PackedSpriteSheet.h"
#import "Animation.h"

@implementation GameScene

- (void)dealloc {

	[spriteSheetCharacter release];
	[playerAnim release];
    [tile release];    
    [tile1 release];
	[super dealloc];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
        float delay = 0.2f;
        
		sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
            
        spriteSheetCharacter = [[SpriteSheet spriteSheetForImageNamed:@"player_spritesheet.png"
                                                 spriteSize:CGSizeMake(40, 40)
                                                    spacing:0
                                                     margin:0
                                                imageFilter:GL_LINEAR] retain];
                
        playerAnim = [[Animation alloc] init];
        [playerAnim addFrameWithImage:[spriteSheetCharacter spriteImageAtCoords:CGPointMake(0, 2)] delay:delay];
        [playerAnim addFrameWithImage:[spriteSheetCharacter spriteImageAtCoords:CGPointMake(1, 2)] delay:delay];
        [playerAnim addFrameWithImage:[spriteSheetCharacter spriteImageAtCoords:CGPointMake(2, 2)] delay:delay];
        [playerAnim addFrameWithImage:[spriteSheetCharacter spriteImageAtCoords:CGPointMake(3, 2)] delay:delay];        
		playerAnim.type = kAnimationType_Repeating;
        playerAnim.state = kAnimationState_Running;
        
        tile = [[Image alloc] initWithImageNamed:@"tile.png" filter:GL_LINEAR];
        
        tile1 = [[tile imageDuplicate] retain];

	}
	return self;
}



- (void)updateSceneWithDelta:(float)aDelta {	

	[playerAnim updateWithDelta:aDelta];
    
}


- (void)renderScene {
	
    [playerAnim renderCenteredAtPoint:CGPointMake(100, 200)];
//    [tile renderCenteredAtPoint:CGPointMake(50, 100)];
    [tile1 renderCenteredAtPoint:CGPointMake(90, 200)];
	
	// Ask the image render manager to render all images in its render queue
	[sharedImageRenderManager renderImages];
}


@end
