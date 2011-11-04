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
#import "Rock.h"
#import "Primitives.h"





@implementation GameScene


#pragma mark - dealloc
- (void)dealloc {
    [joypad release];
    [mainCharacter release];
    [rocks release];
    [tiledMap release];
	[super dealloc];
}



#pragma mark - init
- (id)init {
	self = [super init];
	if (self != nil) {
        rocks = [[NSMutableArray alloc] init];

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
        NSLog(@"layer's count = %d",[tiledMap.layers count]);

        int collisionLayerIndex = [tiledMap layerIndexWithName:@"Collision"];
        Layer *collisionLayer = [tiledMap.layers objectAtIndex:collisionLayerIndex];
        int width = collisionLayer.layerWidth;
        int height = collisionLayer.layerHeight;
        
        NSLog(@"width = %d  -   height = %d", width, height);
                    
        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {                
                int tileID = [collisionLayer tileIDAtTile:CGPointMake(x, y)];
                printf("x = %d  -   y = %d  -   tileID = %d", x, y, tileID);                
                if (tileID == 159) {  //  index of the rock in the tileset spritesheet picture , index is called ID, what a strange
                    blockers[x][y] = YES;
                }
                printf("   -   %s\n", blockers[x][y] ? "YES" : "NO");
            }
        }
        
        NSDictionary *objects = [[[tiledMap objectGroups] objectForKey:@"Rocks"] objectForKey:@"Objects"];
        DLog(@"objects : %@",objects);
        for (NSString *key in [objects allKeys]) {
            NSDictionary *rockModel = [[objects objectForKey:key] objectForKey:@"Attributes"];
            int xTileCoord = [[rockModel objectForKey:@"x"] intValue];
            int yTileCoord = [[rockModel objectForKey:@"y"] intValue];
            Image *rockImage = [[[Image alloc] initWithImageNamed:@"rock.png" filter:GL_LINEAR] autorelease];
            Rock *rock = [[[Rock alloc] initWithImage:rockImage] autorelease];
            rock.location = CGPointMake(xTileCoord + kTile_Width/2 - 8, yTileCoord + kTile_Height/2 - 8);
            [rocks addObject:rock];
            
        }
        
        NSLog(@"tileSet's last object : %@",[tiledMap.tileSets lastObject]);

	}
	return self;
}




#pragma mark - update logic and redering
- (void)updateSceneWithDelta:(float)aDelta {	
    
    [mainCharacter updateWithDelta:aDelta scene:self];  
//    DLog(@"position : %@",NSStringFromCGPoint(mainCharacter.location));
}

- (void)renderScene {
	        
    [tiledMap renderLayer:0 mapx:0 mapy:0 width:kMapWidth height:kMapHeight useBlending:NO];        
//    [tiledMap renderLayer:1 mapx:0 mapy:0 width:9 height:12 useBlending:YES];        
    [mainCharacter render];
    
    for (Rock *rock in rocks) {
        [rock render];
    }
    
    [joypad renderCenteredAtPoint:joypadCenter];    

//    drawRect([Player collisionBoundsForAngle:angleToMove]);
    
	// Ask the image render manager to render all images in its render queue
	[sharedImageRenderManager renderImages];
    drawRect([mainCharacter collisionBounds]);
    for (Rock *rock in rocks) {
        drawRect([rock movementBounds]);
    }
}




#pragma mark - tile map functions
- (BOOL)isBlocked:(float)x y:(float)y {
	// If we are asked for blocking information that is beyond the map border then by default
	// return yes.  When the player is moving near the edge of the map coordinates may be passed
	// that are beyond these bounds
	if (x < 0 || y < 0 || x > kMapWidth || y > kMapHeight) {
		return YES;
	}
	
	// Return the blocked status of the specified tile
    return blockers[(int)x][(int)y];
}



#pragma mark - touch handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    for (UITouch *touch in touches) {
        CGPoint originalLocation = [touch locationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalLocation];
        
        if (CGRectContainsPoint(joypadBounds, touchLocation)) {
            joypadTouchHash = [touch hash];
            isJoypadTouchMoving = YES;
            
            float dx = (float)touchLocation.x - (float)joypadCenter.x;
            float dy = (float)touchLocation.y - (float)joypadCenter.y;
			
			// Calculate the distance from the center of the joypad to the players touch.
			// Manhatten Distance
			float distance = fabs(touchLocation.x - joypadCenter.x) + fabs(touchLocation.y - joypadCenter.y);
			float directionOfTravel = atan2(dy, dx);                    
            
            //            printf("distance = %f   -    angle = %f\n", distance, RADIANS_TO_DEGREES(directionOfTravel));
            
            mainCharacter.acceleration = CLAMP(distance/4, 0, 10);
            mainCharacter.angleOfMovement = directionOfTravel;
        }        
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    // Loop through all the touches
	for (UITouch *touch in touches) {
        
		if ([touch hash] == joypadTouchHash && isJoypadTouchMoving) {
			
			CGPoint originalTouchLocation = [touch locationInView:aView];
//			NSLog(@"originTouch = %@",NSStringFromCGPoint(originalTouchLocation));

			CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation];
//            NSLog(@"convertedTouch = %@",NSStringFromCGPoint(touchLocation));
			
            float dx = (float)touchLocation.x - (float)joypadCenter.x;
            float dy = (float)touchLocation.y - (float)joypadCenter.y;
			
			// Calculate the distance from the center of the joypad to the players touch.
			// Manhatten Distance
			float distance = fabs(touchLocation.x - joypadCenter.x) + fabs(touchLocation.y - joypadCenter.y);
			float directionOfTravel = atan2(dy, dx);                    
            
//            printf("distance = %f   -    angle = %f\n", distance, RADIANS_TO_DEGREES(directionOfTravel));
            
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
