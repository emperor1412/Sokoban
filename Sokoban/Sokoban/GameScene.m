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




@interface GameScene(Private)    
BoundingBoxTileQuad getTileCoordsForBoundingRect(CGRect aRect, CGSize aTileSize);
@end



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
//        mainCharacter.location = CGPointMake(180, 220);
        mainCharacter.velocity = 0.5;
        mainCharacter.acceleration = 0.0;
        mainCharacter.angleOfMovement = 0.0;
        
        tiledMap = nil;
        
//        finishCondition = malloc(sizeof(BOOL) * kMapWidth * kMapHeight);

//        [self setUpMapWithFileName:@"SokobanMap" fileExtension:@"tmx"];
	}
	return self;
}

- (void)setUpMapWithFileName:(NSString *)fileName fileExtension:(NSString *)extension {
    
    [tiledMap release];         // release old level
    
    tiledMap = [[TiledMap alloc] initWithFileName:fileName fileExtension:extension];
    NSLog(@"layer's count = %d",[tiledMap.layers count]);
    
    
    int collisionLayerIndex = [tiledMap layerIndexWithName:@"Collision"];
    Layer *collisionLayer = [tiledMap.layers objectAtIndex:collisionLayerIndex];
    int width = collisionLayer.layerWidth;
    int height = collisionLayer.layerHeight;
    
    NSLog(@"width = %d  -   height = %d", width, height);
//    memset(blockers, 0, width * height);
    
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {        
            
            int tileID = [collisionLayer tileIDAtTile:CGPointMake(x, y)];
            printf("x = %d  -   y = %d  -   tileID = %d", x, y, tileID);                
            if (tileID == kTileIDBlock) {  
                blockers[x][y] = YES;
            }
            else {
                blockers[x][y] = NO;
            }

            printf("   -   %s\n", blockers[x][y] ? "YES" : "NO");
        }
    }
    
    
    int finishConditionLayerIndex = [tiledMap layerIndexWithName:@"Finish Condition"];
    Layer *finishConditionLayer = [tiledMap.layers objectAtIndex:finishConditionLayerIndex];
    width = finishConditionLayer.layerWidth;
    height = finishConditionLayer.layerHeight;
//    memset(finishCondition, 0, width * height);
    
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            
            int tileID = [finishConditionLayer tileIDAtTile:CGPointMake(x, y)];
            if (tileID == kTileIDFinishPoint) {
                finishCondition[x][y] = 2;
            }
            else {
                finishCondition[x][y] = 1;
            }
            
            
            if (tileID == kTileIDStartPoint) {
                mainCharacter.location = CGPointMake(kTile_Width*x + 20, kTile_Height*y + 20);
            }
            NSLog(@"x = %d  -  y = %d   :  %@   -   tileID : %d",x, y, (finishCondition[x][y] ? @"YES" : @"NO"), tileID);
        }
    }
    
    
    NSDictionary *objects = [[[tiledMap objectGroups] objectForKey:@"Rocks"] objectForKey:@"Objects"];
    DLog(@"objects : %@",objects);
    [rocks removeAllObjects];
    for (NSString *key in [objects allKeys]) {
        
        NSDictionary *rockModel = [[objects objectForKey:key] objectForKey:@"Attributes"];
        int xTileCoord = [[rockModel objectForKey:@"x"] intValue];
        int yTileCoord = [[rockModel objectForKey:@"y"] intValue];
        
        NSLog(@"xTile = %d      -       yTile = %d", xTileCoord, yTileCoord);
        
        Image *rockImage = [[[Image alloc] initWithImageNamed:@"rock.png" filter:GL_LINEAR] autorelease];
        Rock *rock = [[[Rock alloc] initWithImage:rockImage] autorelease];
        rock.location = CGPointMake(xTileCoord + 20, 480 - yTileCoord + 20);
        [rocks addObject:rock];            
    }
}


#pragma mark - update logic and redering
- (void)updateSceneWithDelta:(float)aDelta {	
    
    
    [self updatePlayerLocationWithDelta:aDelta];
    //    [mainCharacter updateWithDelta:aDelta scene:self];  
    //    DLog(@"position : %@",NSStringFromCGPoint(mainCharacter.location));
}

- (void)updatePlayerLocationWithDelta:(float)aDelta {
    if (mainCharacter.acceleration == 0 /*&& elapsedTime <= 0*/ ) {
        mainCharacter.currentAnimation.state = kAnimationState_Stopped;
        mainCharacter.currentAnimation.currentFrame = 0;
        mainCharacter.velocity = 0.5;
        
        int xTile, yTile, count = 0;
        for (Rock *rock in rocks) {
            xTile = rock.location.x  / kTile_Width;
            yTile = rock.location.y  / kTile_Height;
            //        NSLog(@"xTile : %d  -   yTile : %d", xTile, yTile);
            if (finishCondition[xTile][yTile] == 2) {
                ++count;
            }
            //        NSLog(@"xTile : %d  -   yTile : %d      -   count = %d", xTile, yTile, count);
        }
        
        if (count == [rocks count]) {
            NSLog(@"Finish Game");
            [((AppDelegate *)[UIApplication sharedApplication].delegate).glViewController stopAnimation];
//            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"You Win"
//                                                             message:@""
//                                                            delegate:nil
//                                                   cancelButtonTitle:@"OK"
//                                                   otherButtonTitles:nil] autorelease];
//            [alert performSelector:@selector(show) withObject:nil afterDelay:0.5];
            [sharedGameController winGameAction];
            return;
        }

    }
    else {
        
        CGPoint oldPosition = mainCharacter.location;        
        float angleToMove = 0.0;
        
        if (mainCharacter.angleOfMovement >= -3*M_PI_4 && mainCharacter.angleOfMovement < -M_PI_4) {
			mainCharacter.currentAnimation = mainCharacter.downAnimation;
            angleToMove = M_PI_2;
            
		} else if (mainCharacter.angleOfMovement >= M_PI_4 && mainCharacter.angleOfMovement < 3*M_PI_4) {
            angleToMove = 3*M_PI_2;
			mainCharacter.currentAnimation = mainCharacter.upAnimation;
            
		} else if (mainCharacter.angleOfMovement >= -M_PI_4 && mainCharacter.angleOfMovement < M_PI_4) {
            angleToMove = M_PI;
			mainCharacter.currentAnimation = mainCharacter.rightAnimation;
            
		} else  {
            angleToMove = 0.0;
			mainCharacter.currentAnimation = mainCharacter.leftAnimation;
		}
        
        mainCharacter.currentAnimation.state = kAnimationState_Running;
        [mainCharacter.currentAnimation updateWithDelta:aDelta];
        
//        float diff = ((aDelta * (mainCharacter.velocity * mainCharacter.acceleration)) * cosf(angleToMove));
        float xDiff = 1.0 * cosf(angleToMove);  // constant velocity, remove this line to have versatile velocity
        //        printf("velo = %f   -   accel = %f  -   angle = %f  -   diff-x = %f  -    ", mainCharacter.velocity, mainCharacter.acceleration, angleToMove, diff);
        mainCharacter->_location.x -= xDiff;
        
        CGRect movementBounds = [mainCharacter movementBounds];
        BoundingBoxTileQuad bbtq = getTileCoordsForBoundingRect(movementBounds, CGSizeMake(kTile_Width, kTile_Height));
        // check collision with bounding box
        if ([self isBlocked:bbtq.x1 y:bbtq.y1] ||
            [self isBlocked:bbtq.x2 y:bbtq.y2] || 
            [self isBlocked:bbtq.x3 y:bbtq.y3] ||
            [self isBlocked:bbtq.x4 y:bbtq.y4]) {
            mainCharacter->_location.x = oldPosition.x;
            return;
        }
        
//        diff = ((aDelta * (mainCharacter.velocity * mainCharacter.acceleration)) * sinf( angleToMove));
        float yDiff = 1.0 * sinf(angleToMove);        // constant velocity, remove this line to have versatile velocity
        //        printf("diff-y = %f\n",diff);
        
        mainCharacter->_location.y -= yDiff;
        
        movementBounds = [mainCharacter movementBounds];
        bbtq = getTileCoordsForBoundingRect(movementBounds, CGSizeMake(kTile_Width, kTile_Height));
        // check collision with bounding box
        if ([self isBlocked:bbtq.x1 y:bbtq.y1] ||
            [self isBlocked:bbtq.x2 y:bbtq.y2] || 
            [self isBlocked:bbtq.x3 y:bbtq.y3] ||
            [self isBlocked:bbtq.x4 y:bbtq.y4]) {
            mainCharacter->_location.y = oldPosition.y;
            return;
        }    
        
        characterCollisionBounds = [mainCharacter collisionBoundsForAngle:angleToMove];
        int i = 0;
        // check collision with rocks
        for (Rock *rock in rocks) {
            rockCollisionBounds[i] = [rock collisionBounds];
            if (CGRectIntersectsRect(characterCollisionBounds, rockCollisionBounds[i])) {
//                NSLog(@"Collision");
                if (CGRectContainsRect(rockCollisionBounds[i], characterCollisionBounds)) {   // the character collides with one of the rocks
//                    NSLog(@"Move the rock");
                    CGPoint oldRockPosition = rock.location;
                    
                    rock->_location.x -= xDiff;
                    bbtq = getTileCoordsForBoundingRect([rock movementBounds], CGSizeMake(kTile_Width, kTile_Height));                    
                    // check collision with bounding box
                    if ([self isBlocked:bbtq.x1 y:bbtq.y1] ||
                        [self isBlocked:bbtq.x2 y:bbtq.y2] || 
                        [self isBlocked:bbtq.x3 y:bbtq.y3] ||
                        [self isBlocked:bbtq.x4 y:bbtq.y4]) {
                        mainCharacter->_location.x = oldPosition.x;
                        rock->_location.x = oldRockPosition.x;
                        return;
                    }
                    
                    rock->_location.y -= yDiff;
                    bbtq = getTileCoordsForBoundingRect([rock movementBounds], CGSizeMake(kTile_Width, kTile_Height));
                    // check collision with bounding box
                    if ([self isBlocked:bbtq.x1 y:bbtq.y1] ||
                        [self isBlocked:bbtq.x2 y:bbtq.y2] || 
                        [self isBlocked:bbtq.x3 y:bbtq.y3] ||
                        [self isBlocked:bbtq.x4 y:bbtq.y4]) {
                        mainCharacter->_location.y = oldPosition.y;
                        rock->_location.y = oldRockPosition.y;
                        return;
                    }
                    
                    for (Rock *rock1 in rocks) {   // check if the rock collide with other rocks
                        if (rock1 != rock && CGRectIntersectsRect([rock1 collisionBounds], [rock collisionBounds])) {  // if collide, restore the position of rock and character with the old one
                            mainCharacter->_location.x = oldPosition.x;
                            rock->_location.x = oldRockPosition.x;
                            mainCharacter->_location.y = oldPosition.y;
                            rock->_location.y = oldRockPosition.y;
                            break;
                        }
                    }
                }
                else {
                    mainCharacter->_location.x = oldPosition.x;
                    mainCharacter->_location.y = oldPosition.y;                    
                }
                break;
            }
            ++i;
        }
        
        
        
//        mainCharacter.velocity += mainCharacter.acceleration;
//        mainCharacter.velocity = CLAMP(mainCharacter.velocity, 0.5, 15);
    }
    
}

- (void)renderScene {
	        
    [tiledMap renderLayer:0 mapx:0 mapy:0 width:kMapWidth height:kMapHeight useBlending:NO];        
    [mainCharacter render];
    
    for (Rock *rock in rocks) {
        [rock render];
    }
    
    [joypad renderCenteredAtPoint:joypadCenter];    
    
	// Ask the image render manager to render all images in its render queue
	[sharedImageRenderManager renderImages];
//    drawRect([mainCharacter movementBounds]);
//    drawRect(characterCollisionBounds);
//    for (int i = 0; i < 2; ++i) {
//        drawRect(rockCollisionBounds[i]);
//    }
}




#pragma mark - other methods
BoundingBoxTileQuad getTileCoordsForBoundingRect(CGRect aRect, CGSize aTileSize) {
    
    BoundingBoxTileQuad bbtq;
    
    // Bottom left
    bbtq.x1 = (int)(aRect.origin.x / aTileSize.width);
    bbtq.y1 = (int)(aRect.origin.y / aTileSize.height);
    
    // Bottom right
    bbtq.x2 = (int)((aRect.origin.x + aRect.size.width) / aTileSize.width);
    bbtq.y2 = bbtq.y1;
    
    // Top right
    bbtq.x3 = bbtq.x2;
    bbtq.y3 = (int)((aRect.origin.y + aRect.size.height) / aTileSize.height);
    
    // Top left
    bbtq.x4 = bbtq.x1;
    bbtq.y4 = bbtq.y3;
    
    return bbtq;
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
            
            // printf("distance = %f   -    angle = %f\n", distance, RADIANS_TO_DEGREES(directionOfTravel));
            
            mainCharacter.acceleration = CLAMP(distance/4, 0, 10);
            mainCharacter.angleOfMovement = directionOfTravel;
//            elapsedTime = 0.4;

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
            
//            mainCharacter.acceleration = 0.0;
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
