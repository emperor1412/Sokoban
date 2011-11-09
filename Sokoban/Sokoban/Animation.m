//
//  Animation.m
//  SLQTSOR
//
//  Created by Michael Daley on 06/07/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "Animation.h"
#import "Image.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>


@implementation Animation

@synthesize state;
@synthesize type;
@synthesize direction;
@synthesize currentFrame;
@synthesize maxFrames;
@synthesize bounceFrame;

static SystemSoundID mySound;

- (void)dealloc {
    
	// Loop through the frames array and release all the frames which we have
	if (frames) {
		for(int i=0; i<frameCount; i++) {
			AnimationFrame *frame = &frames[i];
			[frame->image release];
		}
		free(frames);
	}
    [super dealloc];
}

- (id)init {
    if(self = [super init]) {
		// Init the animations properties
        maxFrames = 5;
        frameCount = 0;
        currentFrame = 0;
        state = kAnimationState_Stopped;
        type = kAnimationType_Once;
        direction = 1;
		bounceFrame = -1;
		
		// Initialize the array that will store the animation frames
        frames = calloc(maxFrames, sizeof(AnimationFrame));
        
        NSString *pewPewPath = [[NSBundle mainBundle] pathForResource:@"footstep4" ofType:@"wav"];
        NSURL *pewPewURL = [NSURL fileURLWithPath:pewPewPath];
        AudioServicesCreateSystemSoundID((CFURLRef)pewPewURL, &mySound);

    }
    return self;
}

#define FRAMES_TO_EXTEND 5

- (void)addFrameWithImage:(Image*)aImage delay:(float)aDelay {
	
    // If we try to add more frames than we have storage for then increase the storage
    if(frameCount+1 > maxFrames) {
        maxFrames += FRAMES_TO_EXTEND;
		frames = realloc(frames, sizeof(AnimationFrame) * maxFrames);
    }
	
    // Set the image and delay based on the arguments passed in
    frames[frameCount].image = [aImage retain];
    frames[frameCount].delay = aDelay;
	
	frameCount++;

}

- (void)updateWithDelta:(float)aDelta {

    // We only need to update the animation if its running
    if(state != kAnimationState_Running)
        return;

    // Increment the displayTime with the delta value sent in from the game loop
    displayTime += aDelta;
    
    // If the displayTime has exceeded the current frames delay then switch frames
    if(displayTime > frames[currentFrame].delay) {
        
        
        static float lastTime = 0;
        float currentTime = CACurrentMediaTime();
        if (currentTime - lastTime > 0.15) {
            AudioServicesPlaySystemSound(mySound);
            lastTime = currentTime;
        }
        
        
        currentFrame += direction;

		// Rather than set displayTime back to 0, we set it to the difference between the 
		// displayTime and frames delay. This will cause frames to be skipped as necessary
		// if the game should bog down
		displayTime -= frames[currentFrame].delay;
        
        // If we have reached the end or start of the animation, decide on what needs to be 
        // done based on the animations type
        if (type == kAnimationType_PingPong && (currentFrame == 0 || currentFrame == frameCount-1 || currentFrame == bounceFrame)) {
            direction = -direction;
        } else if (currentFrame > frameCount-1 || currentFrame == bounceFrame) {
            if (type != kAnimationType_Repeating) {
				currentFrame -= 1;
                state = kAnimationState_Stopped;
			} else {
				currentFrame = 0;
			}
        }
    }
}

- (Image*)currentFrameImage {
    return frames[currentFrame].image;
}

- (Image*)imageForFrame:(NSUInteger)aIndex {
    if(aIndex > frameCount) {
        NSLog(@"WARNING - Animation: Invalid frame index");
        return nil;
    }
    return frames[aIndex].image;
}

- (void)rotationPoint:(CGPoint)aPoint {
    for(int i=0; i<frameCount; i++) {
        [frames[i].image setRotationPoint:aPoint];
    }
}

- (void)setRotation:(float)aRotation {
    for(int i=0; i<frameCount; i++) {
        [frames[i].image setRotation:aRotation];
    }
}

- (void)renderAtPoint:(CGPoint)aPoint {
    [self renderAtPoint:aPoint scale:frames[currentFrame].image.scale rotation:frames[currentFrame].image.rotation];
}

- (void)renderAtPoint:(CGPoint)aPoint scale:(Scale2f)aScale rotation:(float)aRotation {
    [frames[currentFrame].image renderAtPoint:aPoint scale:aScale rotation:aRotation];    
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint {
    [self renderCenteredAtPoint:aPoint scale:frames[currentFrame].image.scale rotation:frames[currentFrame].image.rotation];
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint scale:(Scale2f)aScale rotation:(float)aRotation {
    [frames[currentFrame].image renderCenteredAtPoint:aPoint scale:aScale rotation:aRotation];    
}

@end
