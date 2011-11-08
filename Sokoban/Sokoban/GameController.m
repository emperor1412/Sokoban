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
#import "AppDelegate.h"
#import "GLViewController.h"



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
    [levels release];

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

// Returns an adjusted touch point based on the orientation of the device
- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch {
    CGPoint returnPoint = aTouch;
    returnPoint.y = 480 - aTouch.y;
    return returnPoint;
}




#pragma mark - control level
- (void)nextLevel {
    if (currentLevel + 1 < [levels count]) {
        ++currentLevel;
        NSString *levelFileName = [levels objectAtIndex:currentLevel];
        [(GameScene *)currentScene setUpMapWithFileName:[levelFileName stringByDeletingPathExtension] fileExtension:[levelFileName pathExtension]];

    }
}

- (void)previousLevel {
    if (currentLevel - 1 >= 0) {
        --currentLevel;
        NSString *levelFileName = [levels objectAtIndex:currentLevel];
        [(GameScene *)currentScene setUpMapWithFileName:[levelFileName stringByDeletingPathExtension] fileExtension:[levelFileName pathExtension]];
    }
}

- (void)replay {
    NSString *levelFileName = [levels objectAtIndex:currentLevel];
    [(GameScene *)currentScene setUpMapWithFileName:[levelFileName stringByDeletingPathExtension] fileExtension:[levelFileName pathExtension]];
}

- (void)winGameAction {
    [glViewController showWinGame];
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
    
    

     
    NSString *path =  [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    levels = [[[dic objectForKey:@"Levels"] objectForKey:@"LevelsContent"] retain];
    
    currentLevel = 0;
    
    NSString *levelFileName = [levels objectAtIndex:currentLevel];
    [(GameScene *)currentScene setUpMapWithFileName:[levelFileName stringByDeletingPathExtension] fileExtension:[levelFileName pathExtension]];
    
    glViewController = ((AppDelegate *)[UIApplication sharedApplication].delegate).glViewController;
    
    NSLog(@"levels : %@",dic);
    
}




#pragma mark -
#pragma mark Accelerometer

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
}

@end

