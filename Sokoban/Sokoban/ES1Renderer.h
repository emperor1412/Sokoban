//
//  ES1Renderer.h
//  SLQTSOR
//
//  Created by Michael Daley on 25/08/2009.
//  Copyright Michael Daley 2009. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "ESRenderer.h"
#import "Global.h"

@class GameController;

@interface ES1Renderer : NSObject <ESRenderer>
{
@private
	EAGLContext *context;
	
	// The pixel dimensions of the CAEAGLLayer
	GLint backingWidth;
	GLint backingHeight;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint defaultFramebuffer, colorRenderbuffer;
    
    // Shared game controller
    GameController *sharedGameController;
}

- (void) render;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;

@end
