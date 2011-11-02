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

@implementation GameScene

- (void)dealloc {
	[myImage release];
	[myImage1 release];
	[myImage2 release];
	[spriteSheet release];
	[packedSpriteSheet release];
	[playerAnim release];
	[ghostAnim release];
	[super dealloc];
}

- (id) init
{
	self = [super init];
	if (self != nil) {

		// Grab an instance of the render manager
		sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];

		// Set the speed at which the image should scale.  This will increase the scale or the image by 3 per second
		scaleAmount = 3;
		
		// Define a sprite sheet
		packedSpriteSheet = [PackedSpriteSheet  packedSpriteSheetForImageNamed:@"atlas.png" controlFile:@"coordinates" imageFilter:GL_LINEAR];
		
		Image *spriteSheetImage = [packedSpriteSheet imageForKey:@"player_spritesheet.png"];

		spriteSheet = [SpriteSheet spriteSheetForImage:spriteSheetImage sheetKey:@"spriteSheet" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
		
		// Create three images by taking three different images from the sprite sheet.  Remember that the retain
		// is important as the sprite sheet does not control the life cycle of returned images
		myImage = [[spriteSheet spriteImageAtCoords:CGPointMake(2, 2)] retain];
		
		myImage1 = [[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] retain];
		
		// Set the scale of myImage1
		myImage1.scale = Scale2fMake(2, 4);
		
		myImage2 = [[spriteSheet spriteImageAtCoords:CGPointMake(1, 3)] retain]; 
		// Set the color filter
		myImage2.color = Color4fMake(0.2223, 0.99235, 0.5, 1.0f);
		
		////////////////////////////////////////////////////////////////////////
		// Ghost Animation
		////////////////////////////////////////////////////////////////////////
		
		// Grab the ghost sprite sheet from within the packed sprite sheet
		Image *ghostImages = [packedSpriteSheet imageForKey:@"ghost_spritesheet.png"];

		// By scaling the image that is going to be used in the sprite sheet, you can create scaled
		// animations.  The command below causes the ghost sprites to be double their normal size
		ghostImages.scale = Scale2fMake(2.0f, 2.0f);

		// Create a sprite sheet using the ghost image we have just obtained
		SpriteSheet *ghostSprites = [[SpriteSheet spriteSheetForImage:ghostImages sheetKey:@"ghostImages" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0] retain];
		
		// Create a new animation instance
		ghostAnim = [[Animation alloc] init];

		// Define how long each frame should be displayed before moving on.  Each frame could have its own
		// delay, they do not all need to be the same.
		float delay = 0.2f;

		// Add the frames of animation to the animation instance
		[ghostAnim addFrameWithImage:[ghostSprites spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
		[ghostAnim addFrameWithImage:[ghostSprites spriteImageAtCoords:CGPointMake(1, 0)] delay:delay];
		[ghostAnim addFrameWithImage:[ghostSprites spriteImageAtCoords:CGPointMake(2, 0)] delay:delay];

		// Set the state and type of animation
		ghostAnim.state = kAnimationState_Running;
		ghostAnim.type = kAnimationType_PingPong;
		
		////////////////////////////////////////////////////////////////////////
		// Player Animation
		////////////////////////////////////////////////////////////////////////
		
		// Grab the ghost sprite sheet from within the packed sprite sheet
		Image *playerImages = [packedSpriteSheet imageForKey:@"player_spritesheet.png"];
		
		// By scaling the image that is going to be used in the sprite sheet, you can create scaled
		// animations.  The command below causes the ghost sprites to be double their normal size
		playerImages.scale = Scale2fMake(2.0f, 2.0f);

		// You can also set the rotation point and rotation of an image that is going to be used as a
		// sprite sheet.  This will cause each image extracted from the sprite sheet to have their
		// properties set to these values
		playerImages.rotationPoint = CGPointMake(20, 20);
		playerImages.rotation = -45.0f;
		
		// Create a sprite sheet using the ghost image we have just obtained
		SpriteSheet *playerSprites = [[SpriteSheet spriteSheetForImage:playerImages sheetKey:@"playerSprites" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0] retain];
		
		// Create a new animation instance
		playerAnim = [[Animation alloc] init];
		
		// Define how long each frame should be displayed before moving on.  Each frame could have its own
		// delay, they do not all need to be the same.
		delay = 0.1;
		
		// Add the frames of animation to the animation instance
		[playerAnim addFrameWithImage:[playerSprites spriteImageAtCoords:CGPointMake(1, 2) ] delay:delay];        
		[playerAnim addFrameWithImage:[playerSprites spriteImageAtCoords:CGPointMake(2, 2) ] delay:delay];
		[playerAnim addFrameWithImage:[playerSprites spriteImageAtCoords:CGPointMake(1, 2) ] delay:delay];
		[playerAnim addFrameWithImage:[playerSprites spriteImageAtCoords:CGPointMake(3, 2) ] delay:delay];

		// Set the state and type of animation
		playerAnim.state = kAnimationState_Running;
		playerAnim.type = kAnimationType_Repeating;
		
		// Release the spritesheets we created as we no longer need them and don't want to leak memory
		[playerSprites release];
		[ghostSprites release];
        
        Image *robotImage = [[Image alloc] initWithImageNamed:@"RobotSpriteSheet2.png" filter:GL_LINEAR];
//        robotImage.color = Color4fMake(0.56742, 0.922, 0.886, 1.0);
        robotSpriteSheet = [SpriteSheet spriteSheetForImage:robotImage sheetKey:@"Robot" spriteSize:CGSizeMake(75, 75) spacing:0 margin:0];
//        robot = [SpriteSheet spriteSheetForImageNamed:@"RobotSpriteSheet2.png" spriteSize:CGSizeMake(75, 75) spacing:0 margin:0 imageFilter:GL_LINEAR];
        
        
        delay = 0.075f;
        robotAnim = [[Animation alloc] init];                        
    
        [robotAnim addFrameWithImage:[robotSpriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:delay];
        [robotAnim addFrameWithImage:[robotSpriteSheet spriteImageAtCoords:CGPointMake(0, 1)] delay:delay];        
        [robotAnim addFrameWithImage:[robotSpriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:delay];       
        [robotAnim addFrameWithImage:[robotSpriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:delay];
        [robotAnim addFrameWithImage:[robotSpriteSheet spriteImageAtCoords:CGPointMake(1, 1)] delay:delay];
        [robotAnim addFrameWithImage:[robotSpriteSheet spriteImageAtCoords:CGPointMake(1, 2)] delay:delay];
        [robotAnim addFrameWithImage:[robotSpriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:delay];
        [robotAnim addFrameWithImage:[robotSpriteSheet spriteImageAtCoords:CGPointMake(2, 1)] delay:delay];
        [robotAnim addFrameWithImage:[robotSpriteSheet spriteImageAtCoords:CGPointMake(2, 2)] delay:delay];                
         
        robotAnim.state = kAnimationState_Running;
        robotAnim.type = kAnimationType_Repeating;
        [robotSpriteSheet spriteImageAtCoords:CGPointMake(0, 0)].color = Color4fMake(0.0, 0.0, 1.0, 1.0);
        aRobotFrame = [robotSpriteSheet spriteImageAtCoords:CGPointMake(2, 2)];
        aRobotFrame.color = Color4fMake(1.0, 0.5, 0.5, 1.0);
	}
	return self;
}



- (void)updateSceneWithDelta:(float)aDelta {
	// Change the scale of the image
	float xScale = myImage.scale.x + scaleAmount * aDelta;
	float yScale = myImage.scale.y + scaleAmount * aDelta;
	
	// Set the scale of the image based on the values calculated above
	myImage.scale = Scale2fMake(xScale, yScale);

	// Set the point of rotation to the middle of the image taking the scale into account
	myImage.rotationPoint = CGPointMake(20 * myImage.scale.x, 20 * myImage.scale.y);

	// This will rotate the image by 360 degrees per second
//	myImage.rotation = myImage.rotation -= 360 * aDelta;
    myImage.rotation -= (360 * aDelta);

	// Reverse the scaling factor when we reach the limits defined below
	if (myImage.scale.x >= 2.5 || myImage.scale.x <= 1) {
		scaleAmount *= -1;
	}
	
	[ghostAnim updateWithDelta:aDelta];
	[playerAnim updateWithDelta:aDelta];
    
}


- (void)renderScene {
	// Get each image to render itself
    
	[myImage renderCenteredAtPoint:CGPointMake(160, 240)];
	[myImage1 renderCenteredAtPoint:CGPointMake(50, 100)];
	[myImage2 renderCenteredAtPoint:CGPointMake(270, 430)];
	
	[ghostAnim renderCenteredAtPoint:CGPointMake(50, 400)];
	[playerAnim renderCenteredAtPoint:CGPointMake(270, 75)];
	
	// Ask the image render manager to render all images in its render queue
	[sharedImageRenderManager renderImages];
     
    
    
}


@end
