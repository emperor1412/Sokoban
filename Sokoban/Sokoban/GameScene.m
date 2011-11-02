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
#import "AppDelegate.h"

@implementation GameScene


#pragma mark - dealloc
- (void)dealloc {

	[spriteSheetCharacter release];
	[playerAnim release];
    [tile release];    
    [tile1 release];
    [tile2 release];
    [joypad release];
	[super dealloc];
}



#pragma mark - init
- (id) init
{
	self = [super init];
	if (self != nil) {
        float delay = 0.2f;
        glViewBounds = ((AppDelegate *)[UIApplication sharedApplication].delegate).glView.bounds;
        
		sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
        sharedGameController = [GameController sharedGameController];
            
        characterSpriteSize = CGSizeMake(40, 40);
        spriteSheetCharacter = [[SpriteSheet spriteSheetForImageNamed:@"player_spritesheet.png"
                                                           spriteSize:characterSpriteSize
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
        tile.point = CGPointMake(50, 300);
        
        tile1 = [[Image alloc] initWithImageNamed:@"tile.png" filter:GL_LINEAR];
        tile2 = [[tile1 imageDuplicate] retain];
                
        joypad = [[Image alloc] initWithImageNamed:@"joypad.png" filter:GL_LINEAR];        
        joypadCenter = CGPointMake(50, 50);
		joypadRectSize = CGSizeMake(40, 40);
		joypadBounds = CGRectMake(joypadCenter.x - joypadRectSize.width, 
								  joypadCenter.y - joypadRectSize.height, 
								  joypadRectSize.width * 2, 
								  joypadRectSize.height * 2);
        
        playerLocation = CGPointMake(160, 240);
        
        joypadDistance = 0;
        directionOfTravel = 0;

	}
	return self;
}




#pragma mark - update logic and redering
- (void)updateSceneWithDelta:(float)aDelta {	

	[playerAnim updateWithDelta:aDelta];    
    
    playerLocation.x -= ((aDelta * (5 * joypadDistance)) * cosf(directionOfTravel));
    playerLocation.y -= ((aDelta * (5 * joypadDistance)) * sinf(directionOfTravel));
    
    if (playerLocation.x < characterSpriteSize.width/2) {
        playerLocation.x = characterSpriteSize.width/2;
    }
    if (playerLocation.x > 320 - characterSpriteSize.width/2) {
        playerLocation.x = 320 - characterSpriteSize.width/2;
    }    
    if (playerLocation.y < characterSpriteSize.height/2) {
        playerLocation.y = characterSpriteSize.height/2;
    }
    if (playerLocation.y > 480 - characterSpriteSize.height/2) {
        playerLocation.y = 480 - characterSpriteSize.height/2;
    }
    
    
    tile.point = CGPointMake(tile.point.x + 10*aDelta, tile.point.y - 10*aDelta);
    
}


- (void)renderScene {
	
    [playerAnim renderCenteredAtPoint:playerLocation];
//    [tile renderCenteredAtPoint:CGPointMake(50, 300)];
    [tile renderCentered];
    [tile1 renderCenteredAtPoint:CGPointMake(50, 340)];
    [tile2 renderCenteredAtPoint:CGPointMake(50, 380)];
	
    [joypad renderCenteredAtPoint:joypadCenter];
	// Ask the image render manager to render all images in its render queue
	[sharedImageRenderManager renderImages];
}




#pragma mark - touch handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    for (UITouch *touch in touches) {
        CGPoint originalLocation = [touch locationInView:aView];
        CGPoint location = [sharedGameController adjustTouchOrientationForTouch:originalLocation];
        
        if (CGRectContainsPoint(joypadBounds, location)) {
            joypadTouchHash = [touch hash];
            isJoypadTouchMoving = YES;
        }
        
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    // Loop through all the touches
	for (UITouch *touch in touches) {
        
		if ([touch hash] == joypadTouchHash && isJoypadTouchMoving) {
			

			CGPoint originalTouchLocation = [touch locationInView:aView];
			
			// As we have the game in landscape mode we need to switch the touches 
			// x and y coordinates
			CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation];
			
			// Calculate the angle of the touch from the center of the joypad
			float dx = (float)joypadCenter.x - (float)touchLocation.x;
			float dy = (float)joypadCenter.y - (float)touchLocation.y;
			
			// Calculate the distance from the center of the joypad to the players touch.
			// Manhatten Distance
			joypadDistance = fabs(touchLocation.x - joypadCenter.x) + fabs(touchLocation.y - joypadCenter.y);
			
			// Calculate the new position of the knight based on the direction of the joypad and how far from the
			// center the joypad has been moved
			directionOfTravel = atan2(dy, dx);
		}
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    // Loop through the touches checking to see if the joypad touch has finished
	for (UITouch *touch in touches) {
		// If the hash for the joypad has reported that its ended, then set the
		// state as necessary
		if ([touch hash] == joypadTouchHash) {
			isJoypadTouchMoving = NO;
			joypadTouchHash = 0;
			directionOfTravel = 0;
			joypadDistance = 0;
			return;
		}
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    
}



@end
