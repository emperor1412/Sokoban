//
//  Player.m
//  Sokoban
//
//  Created by Le Huy Hoang on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import "Rock.h"
#import "Primitives.h"


@interface Player(Private)
//- (void)updateLocationWithDelta:(float)aDelta scene:(GameScene*)aScene;
- (void)populateSpriteToAnimations;
- (void)setUpPlayer;
//BoundingBoxTileQuad getTileCoordsForBoundingRect(CGRect aRect, CGSize aTileSize);
@end


@interface Player() {
    
}

@end




@implementation Player
@synthesize spriteSheetPlayer = _spriteSheetPlayer;
@synthesize spriteSheetImageName = _spriteSheetImageName;
@synthesize location = _location;
@synthesize leftAnimation;
@synthesize rightAnimation;
@synthesize upAnimation;
@synthesize downAnimation;
@synthesize currentAnimation;
@synthesize acceleration = _acceleration, velocity = _velocity, angleOfMovement = _angleOfMovement;


#pragma mark - dealloc
- (void)dealloc {
    self.spriteSheetPlayer = nil;
    self.spriteSheetImageName = nil;
    
    self.leftAnimation = nil;
    self.rightAnimation = nil;
    self.upAnimation = nil;
    self.downAnimation = nil;
    self.currentAnimation = nil;
}




#pragma mark - init
- (id)initWithSpriteSheetImageNamed:(NSString *)fileName {
    self = [super init];
    if (self) {
        self.spriteSheetImageName = fileName;
        [self setUpPlayer];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.spriteSheetImageName = @"player_spritesheet.png";
        [self setUpPlayer];
    }
    return self;
}




#pragma mark - player update logic and rendering
- (void)updateWithDelta:(float)aDelta scene:(GameScene *)aScene {
//    [self updateLocationWithDelta:aDelta scene:aScene];
}

- (void)render {
    [currentAnimation renderCenteredAtPoint:_location];
}




#pragma mark - get bounds
- (CGRect)movementBounds {
    return CGRectMake(_location.x - 15, _location.y - 18, 30, 34);
}

- (CGRect)collisionBoundsForAngle:(float)angle {
//    NSLog(@"angle : %d      -      location : %@", (int)RADIANS_TO_DEGREES(angle), NSStringFromCGPoint(_location));
    float width = 24;
    float height = 30;            
    int xFactor = -12;
    int yFactor = -16;
    
    int degree = (int)RADIANS_TO_DEGREES(angle);
    
    if (degree == 0) {
//        xFactor = -12;
//        yFactor = -15;
        width = 1;
    }
    else if (degree == 90) {
//        xFactor = -12;
        yFactor = -17;
        height = 1;
    }
    else if (degree == 180) {
        xFactor = 12;
//        yFactor = -15;
        width = 1;        
    }
    else {
//        xFactor = -12;
        yFactor = 16;
        height = 1;
    }
    

    return CGRectMake(_location.x + xFactor, _location.y + yFactor, width, height);
}




#pragma mark - setter
- (void)setSpriteSheetPlayer:(SpriteSheet *)spriteSheetPlayer {
    if (spriteSheetPlayer != _spriteSheetPlayer) {
        [_spriteSheetPlayer release];
        _spriteSheetPlayer = [spriteSheetPlayer retain];
        
        [self populateSpriteToAnimations];
    }
}

- (void)setSpriteSheetImageName:(NSString *)spriteSheetImageName {
    if (spriteSheetImageName != _spriteSheetImageName) {
        [_spriteSheetImageName release];
        _spriteSheetImageName = [spriteSheetImageName retain];
        
        self.spriteSheetPlayer = [SpriteSheet spriteSheetForImageNamed:_spriteSheetImageName
                                                            spriteSize:CGSizeMake(40, 40)
                                                               spacing:0.0
                                                                margin:0.0
                                                           imageFilter:GL_LINEAR];
        
    }
}

- (void)setAcceleration:(float)acceleration {
    _acceleration = acceleration;
}

- (void)setAngleOfMovement:(float)angleOfMovement {
    
    /*
    float angleToMove = 0.0;
    if (angleOfMovement >= -3*M_PI_4 && angleOfMovement < -M_PI_4) {     
        angleToMove = M_PI_2;
        
    } else if (angleOfMovement >= M_PI_4 && angleOfMovement < 3*M_PI_4) {
        angleToMove = 3*M_PI_2;
     
        
    } else if (angleOfMovement >= -M_PI_4 && angleOfMovement < M_PI_4) {
        angleToMove = M_PI;
     
        
    } else  {
        angleToMove = 0.0;
     
    }
    */
    _angleOfMovement = angleOfMovement;
}

@end





@implementation Player(Private)
/*
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
 */
/*
- (void)updateLocationWithDelta:(float)aDelta scene:(GameScene *)aScene{
    if (_acceleration == 0) {
        currentAnimation.state = kAnimationState_Stopped;
        currentAnimation.currentFrame = 0;
        _velocity = 0.5;
    }
    else {
        CGPoint oldPosition = _location;
                
        float angleToMove = 0.0;

        
        if (_angleOfMovement >= -3*M_PI_4 && _angleOfMovement < -M_PI_4) {
			currentAnimation = downAnimation;
            angleToMove = M_PI_2;
            
		} else if (_angleOfMovement >= M_PI_4 && _angleOfMovement < 3*M_PI_4) {
            angleToMove = 3*M_PI_2;
			currentAnimation = upAnimation;
            
		} else if (_angleOfMovement >= -M_PI_4 && _angleOfMovement < M_PI_4) {
            angleToMove = M_PI;
			currentAnimation = rightAnimation;
            
		} else  {
            angleToMove = 0.0;
			currentAnimation = leftAnimation;
		}
        
        float diff = ((aDelta * (_velocity * _acceleration)) * cosf(angleToMove));
        diff = 1.0 * cosf(angleToMove);  // constant velocity, remove this line to have versatile velocity
//        printf("velo = %f   -   accel = %f  -   angle = %f  -   diff-x = %f  -    ", _velocity, _acceleration, angleToMove, diff);
        _location.x -= diff;

        CGRect movementBounds = [self movementBounds];
        BoundingBoxTileQuad bbtq = getTileCoordsForBoundingRect(movementBounds, CGSizeMake(kTile_Width, kTile_Height));
        // check collision with bounding box
        if ([aScene isBlocked:bbtq.x1 y:bbtq.y1] ||
            [aScene isBlocked:bbtq.x2 y:bbtq.y2] || 
            [aScene isBlocked:bbtq.x3 y:bbtq.y3] ||
            [aScene isBlocked:bbtq.x4 y:bbtq.y4]) {
            _location.x = oldPosition.x;
        }
        
        
        
        
        diff = ((aDelta * (_velocity * _acceleration)) * sinf( angleToMove));
        diff = 1.0 * sinf( angleToMove);        // constant velocity, remove this line to have versatile velocity
//        printf("diff-y = %f\n",diff);
        _location.y -= diff;
        
        movementBounds = [self movementBounds];
        bbtq = getTileCoordsForBoundingRect(movementBounds, CGSizeMake(kTile_Width, kTile_Height));
        // check collision with bounding box
        if ([aScene isBlocked:bbtq.x1 y:bbtq.y1] ||
            [aScene isBlocked:bbtq.x2 y:bbtq.y2] || 
            [aScene isBlocked:bbtq.x3 y:bbtq.y3] ||
            [aScene isBlocked:bbtq.x4 y:bbtq.y4]) {
            _location.y = oldPosition.y;
        }
        
        
        // check collision with rocks
        NSMutableArray *rocks = aScene->rocks;
        
        [rocks description];
        
        for (Rock *rock in rocks) {

            if (CGRectIntersectsRect([self collisionBounds], [rock collisionBoundsForAngle:angleToMove])) {
//                NSLog(@"Collision");
            }
        }
        
        
        currentAnimation.state = kAnimationState_Running;
        [currentAnimation updateWithDelta:aDelta];
        
        _velocity += _acceleration;
        _velocity = CLAMP(_velocity, 0.5, 15);
    }
}
*/

- (void)populateSpriteToAnimations {
    
    float delay = 0.1f;
    self.leftAnimation = [[[Animation alloc] init] autorelease];
    self.rightAnimation = [[[Animation alloc] init] autorelease];
    self.upAnimation = [[[Animation alloc] init] autorelease];
    self.downAnimation = [[[Animation alloc] init] autorelease];
    
    [leftAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(0, 3)] delay:delay];
    [leftAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 3)] delay:delay];
    [leftAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(2, 3)] delay:delay];
    [leftAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 3)] delay:delay];
    [leftAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(3, 3)] delay:delay];
    leftAnimation.type = kAnimationType_Repeating;    
    leftAnimation.bounceFrame = 0;
    
    [rightAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(0, 2)] delay:delay];
    [rightAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 2)] delay:delay];
    [rightAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(2, 2)] delay:delay];
    [rightAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 2)] delay:delay];
    [rightAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(3, 2)] delay:delay];
    rightAnimation.type = kAnimationType_Repeating;
    rightAnimation.bounceFrame = 0;
    
    [upAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(0, 1)] delay:delay];
    [upAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 1)] delay:delay];
    [upAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(2, 1)] delay:delay];
    [upAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 1)] delay:delay];
    [upAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(3, 1)] delay:delay];
    upAnimation.type = kAnimationType_Repeating;
    upAnimation.bounceFrame = 0;
    
    [downAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
    [downAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 0)] delay:delay];
    [downAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(2, 0)] delay:delay];
    [downAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 0)] delay:delay];
    [downAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(3, 0)] delay:delay];
    downAnimation.type = kAnimationType_Repeating;
    downAnimation.bounceFrame = 0;
    
    currentAnimation = rightAnimation;
    currentAnimation.state = kAnimationState_Stopped;
    [currentAnimation setCurrentFrame:0];

}

- (void)setUpPlayer {    
    _acceleration = 0.0f;
    _velocity = 0.5f;
    _angleOfMovement = 0.0f;
    _location = CGPointZero;
}

@end

