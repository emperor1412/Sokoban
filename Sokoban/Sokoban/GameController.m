//
//  GameController.m
//  GLGamev2
//
//  Created by Michael Daley on 10/07/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "GameController.h"
#import "GameScene.h"
#import "Global.h"

#pragma mark -
#pragma mark Private interface

@interface GameController (Private) 

// Initialize the game
- (void)initGame;

// Used as the callback from the accelerometer
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
@end

#pragma mark -
#pragma mark Public implementation

@implementation GameController

@synthesize currentScene;

// Make this class a singleton class
SYNTHESIZE_SINGLETON_FOR_CLASS(GameController);

- (void)dealloc {
    [gameScenes release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if(self != nil) {
		// Initialize the game
		currentScene = nil;
        [self initGame];
    }
    return self;
}

- (void)updateCurrentSceneWithDelta:(float)aDelta {
    [currentScene updateSceneWithDelta:aDelta];
}

-(void)renderCurrentScene {
	
	// Render the current scene
	[currentScene renderScene];
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation GameController (Private)

- (void)initGame {

    if(DEBUG) NSLog(@"INFO - GameController: Starting game initialization.");
    
    // Initialize game scenes
	gameScenes = [[NSMutableDictionary alloc] initWithCapacity:5];
	AbstractScene *scene = [[GameScene alloc] init];
	[gameScenes setValue:scene forKey:@"game"];
	[scene release];
	
	// Set the initial game scene
	currentScene = [gameScenes objectForKey:@"game"];
    
    if(DEBUG) NSLog(@"INFO - GameController: Finished game initialization.");
}

#pragma mark -
#pragma mark Accelerometer

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
}

@end

