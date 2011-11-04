/*
 *  Global.h
 *  OGLGame
 *
 *  Created by Michael Daley on 19/04/2009.
 *  Copyright 2009 Michael Daley. All rights reserved.
 *
 */

#import <OpenGLES/ES1/gl.h>
#import "Structures.h"
#import "Constants.h"


#pragma mark -
#pragma mark Debug

#define SLQLOG(...) NSLog(__VA_ARGS__);

#define DLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])

#define DEBUG 1
#define SCB 0

#pragma mark -
#pragma mark Macros

// Macro which returns a random value between -1 and 1
#define RANDOM_MINUS_1_TO_1() ((random() / (GLfloat)0x3fffffff )-1.0f)

// Macro which returns a random number between 0 and 1
#define RANDOM_0_TO_1() ((random() / (GLfloat)0x7fffffff ))

// Macro which converts degrees into radians
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

// Macro which converts radians into degrees
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 180.0 / M_PI)

// Macro that allows you to clamp a value within the defined bounds
#define CLAMP(X, A, B) ((X < A) ? A : ((X > B) ? B : X))

#pragma mark -
#pragma mark Inline Functions

// Return a Color4f structure populated with 1.0's
static const Color4f Color4fOnes = {1.0f, 1.0f, 1.0f, 1.0f};

// Return a Scale2f structure populated with the provided floats
static inline Scale2f Scale2fMake(float x, float y) {
    return (Scale2f) {x, y};
}

// Return a Color4f structure populated with the color values passed in
static inline Color4f Color4fMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
	return (Color4f) {red, green, blue, alpha};
}