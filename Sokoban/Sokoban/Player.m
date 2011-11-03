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




@implementation Player
@synthesize spriteSheetPlayer = _spriteSheetPlayer;
@synthesize spriteSheetImageName = _spriteSheetImageName;
@synthesize location = _location;


#pragma mark - dealloc
- (void)dealloc {
    self.spriteSheetPlayer = nil;
    self.spriteSheetImageName = nil;
    
    [leftAnimation release];
    [rightAnimation release];
    [upAnimation release];
    [downAnimation release];
    currentAnimation = nil;
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

@end




@implementation Player(Private)
- (void)updateLocationWithDelta:(float)aDelta {
    if (velocity <= 0) {
        currentAnimation.state = kAnimationState_Stopped;
        currentAnimation.currentFrame = 0;
    }
    else {
        _location.x -= ((aDelta * (velocity * acceleration)) * cosf(angleOfMovement));
        _location.y -= ((aDelta * (velocity * acceleration)) * sinf(angleOfMovement));
        
        if (angleOfMovement > 0.785 && angleOfMovement < 2.355) {
			currentAnimation = downAnimation;
		} else if (angleOfMovement < -0.785 && angleOfMovement > -2.355) {
			currentAnimation = upAnimation;
		} else if (angleOfMovement < -2.355 || angleOfMovement > 2.355) {
			currentAnimation = rightAnimation;
		} else  {
			currentAnimation = leftAnimation;
		}
        
        currentAnimation.state = kAnimationState_Running;
        [currentAnimation updateWithDelta:aDelta];
    }
}

- (void)populateSpriteToAnimations {
    float delay = 0.2f;
    [leftAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(0, 3)] delay:delay];
    [leftAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 3)] delay:delay];
    [leftAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(2, 3)] delay:delay];
    [leftAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 3)] delay:delay];
    [leftAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(3, 3)] delay:delay];
    leftAnimation.bounceFrame = 0;
    
    [rightAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(0, 2)] delay:delay];
    [rightAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 2)] delay:delay];
    [rightAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(2, 2)] delay:delay];
    [rightAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 2)] delay:delay];
    [rightAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(3, 2)] delay:delay];
    rightAnimation.bounceFrame = 0;
    
    [upAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(0, 1)] delay:delay];
    [upAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 1)] delay:delay];
    [upAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(2, 1)] delay:delay];
    [upAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 1)] delay:delay];
    [upAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(3, 1)] delay:delay];
    upAnimation.bounceFrame = 0;
    
    [downAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
    [downAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 0)] delay:delay];
    [downAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(2, 0)] delay:delay];
    [downAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(1, 0)] delay:delay];
    [downAnimation addFrameWithImage:[_spriteSheetPlayer spriteImageAtCoords:CGPointMake(3, 0)] delay:delay];
    downAnimation.bounceFrame = 0;
    
    currentAnimation = rightAnimation;
    currentAnimation.state = kAnimationState_Stopped;
    [currentAnimation setCurrentFrame:0];

}

- (void)setUpPlayer {
    leftAnimation = [[Animation alloc] init];
    rightAnimation = [[Animation alloc] init];
    upAnimation = [[Animation alloc] init];
    downAnimation = [[Animation alloc] init];
    
    acceleration = 0.0f;
    velocity = 0.0f;
    angleOfMovement = 0.0;
    _location = CGPointZero;
}

@end

