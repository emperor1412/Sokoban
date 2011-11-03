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
#import "Player.h"


@interface GameScene (Private) 


@end




@implementation GameScene


#pragma mark - dealloc
- (void)dealloc {
    [joypad release];
    [mainCharacter release];
	[super dealloc];
}



#pragma mark - init
- (id) init
{
	self = [super init];
	if (self != nil) {

        glViewBounds = ((AppDelegate *)[UIApplication sharedApplication].delegate).glView.bounds;
        
		sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
        sharedGameController = [GameController sharedGameController];                    
                
        joypad = [[Image alloc] initWithImageNamed:@"joypad.png" filter:GL_LINEAR];        
        joypadCenter = CGPointMake(50, 50);
		joypadRectSize = CGSizeMake(40, 40);
		joypadBounds = CGRectMake(joypadCenter.x - joypadRectSize.width, 
								  joypadCenter.y - joypadRectSize.height, 
								  joypadRectSize.width * 2, 
								  joypadRectSize.height * 2);
            
        mainCharacter = [[Player alloc] init];
        mainCharacter.location = CGPointMake(160, 240);
        
        tiledMap = [[TiledMap alloc] initWithFileName:@"SokobanMap" fileExtension:@"tmx"];


	}
	return self;
}




#pragma mark - update logic and redering
- (void)updateSceneWithDelta:(float)aDelta {	
    
    [mainCharacter updateWithDelta:aDelta scene:self];
    
}


- (void)renderScene {

	
    [joypad renderCenteredAtPoint:joypadCenter];    
    
//    [tiledMap renderLayer:0 mapx:1 mapy:1 width:8 height:6 useBlending:NO];
    [tiledMap renderLayer:1 mapx:0 mapy:0 width:9 height:7 useBlending:YES];

    
    
    [mainCharacter render];
    

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
			NSLog(@"originTouch = %@",NSStringFromCGPoint(originalTouchLocation));
			// As we have the game in landscape mode we need to switch the touches 
			// x and y coordinates
			CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation];
            NSLog(@"convertedTouch = %@",NSStringFromCGPoint(touchLocation));
			
			// Calculate the angle of the touch from the center of the joypad
//			float dx = (float)joypadCenter.x - (float)touchLocation.x;
//			float dy = (float)joypadCenter.y - (float)touchLocation.y;
            float dx = (float)touchLocation.x - (float)joypadCenter.x;
            float dy = (float)touchLocation.y - (float)joypadCenter.y;
			
			// Calculate the distance from the center of the joypad to the players touch.
			// Manhatten Distance
			float distance = fabs(touchLocation.x - joypadCenter.x) + fabs(touchLocation.y - joypadCenter.y);
			float directionOfTravel = atan2(dy, dx);                    
            
            printf("distance = %f   -    angle = %f\n", distance, RADIANS_TO_DEGREES(directionOfTravel));
            
            mainCharacter.acceleration = CLAMP(distance/4, 0, 10);
            mainCharacter.angleOfMovement = directionOfTravel;
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
            
            mainCharacter.acceleration = 0.0;
            mainCharacter.angleOfMovement = 0.0;
			return;
		}
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    
}



@end
