//
//  GameController.h
//  GLGamev2
//
//  Created by Michael Daley on 10/07/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import "SynthesizeSingleton.h"


@class AbstractScene;
@class GLViewController;

// Class responsbile for managing the games overall state and game scenes.
//
@interface GameController : NSObject <UIAccelerometerDelegate> {
    // Dictionary of the different game scenes
    NSDictionary *gameScenes;
    // Current scene
    AbstractScene *currentScene;
    
    NSMutableArray *levels;
    int currentLevel;
    
    GLViewController *glViewController;
}

@property (nonatomic, retain) AbstractScene *currentScene;

// Class method to return an instance of GameController.  This is needed as this
// class is a singleton class
+ (GameController *)sharedGameController;

// Updates the logic within the current scene
- (void)updateCurrentSceneWithDelta:(float)aDelta;

// Render the current scene
- (void)renderCurrentScene;

// Returns an adjusted touch point based on the orientation of the device
- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch;

- (void)nextLevel;
- (void)previousLevel;
- (void)replay;

- (void)winGameAction;

@end
