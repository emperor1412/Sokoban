//
//  Player.m
//  Sokoban
//
//  Created by Le Huy Hoang on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Player.h"



@interface Player(Private)
- (void)updateLocationWithDelta:(float)aDelta;
- (void)populateSpriteToAnimations;
- (void)setUpPlayer;
@end


@interface Player() {
    
}
@property (nonatomic, retain)   Animation *leftAnimation;
@property (nonatomic, retain)   Animation *rightAnimation;
@property (nonatomic, retain)   Animation *upAnimation;
@property (nonatomic, retain)   Animation *downAnimation;
@property (nonatomic, assign)   Animation *currentAnimation;
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
    [self updateLocationWithDelta:aDelta];
}

- (void)render {
    [currentAnimation renderCenteredAtPoint:_location];
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
    _angleOfMovement = angleOfMovement;

}

@end





@implementation Player(Private)

- (void)updateLocationWithDelta:(float)aDelta {
    if (_acceleration == 0) {
        currentAnimation.state = kAnimationState_Stopped;
        currentAnimation.currentFrame = 0;
        _velocity = 0.5;
    }
    else {
        CGPoint oldPosition = _location;
        
        float angleToMove = 0.0f;
        
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
//        printf("velo = %f   -   accel = %f  -   angle = %f  -   diff-x = %f  -    ", _velocity, _acceleration, angleToMove, diff);
        _location.x -= diff;
        if (_location.x < 20) {
            _location.x = oldPosition.x;
        }
        if (_location.x > 320 - 20) {
            _location.x = oldPosition.x;
        }    
        
        diff = ((aDelta * (_velocity * _acceleration)) * sinf(angleToMove));
//        printf("diff-y = %f\n",diff);
        _location.y -= diff;
        
        if (_location.y < 20) {
            _location.y = oldPosition.y;
        }
        if (_location.y > 480 - 20) {
            _location.y = oldPosition.y;
        }                    
        
        currentAnimation.state = kAnimationState_Running;
        [currentAnimation updateWithDelta:aDelta];
        
        _velocity += _acceleration;
        _velocity = CLAMP(_velocity, 0.5, 20);
    }
}

- (void)populateSpriteToAnimations {
    float delay = 0.1f;
    self.leftAnimation = [[Animation alloc] init];
    self.rightAnimation = [[Animation alloc] init];
    self.upAnimation = [[Animation alloc] init];
    self.downAnimation = [[Animation alloc] init];
    
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

