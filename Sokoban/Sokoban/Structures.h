/*
 *  Structures.h
 *  SLQTSOR
 *
 *  Created by Mike Daley on 22/09/2009.
 *  Copyright 2009 Michael Daley. All rights reserved.
 *
 */

#import <OpenGLES/ES1/gl.h>

@class Image;

#pragma mark -
#pragma mark Types

// Structure to hold the x and y scale
typedef struct {
    float x;
    float y;
} Scale2f;

// Structure that defines the elements which make up a color
typedef struct {
	float red;
	float green;
	float blue;
	float alpha;
} Color4f;

// Stores geometry, texture and colour information for a single vertex
typedef struct {
    CGPoint geometryVertex;
    Color4f vertexColor;
    CGPoint textureVertex;
} TexturedColoredVertex;

// Stores 4 TexturedColoredVertex structures needed to define a quad
typedef struct {
    TexturedColoredVertex vertex1;
    TexturedColoredVertex vertex2;
    TexturedColoredVertex vertex3;
    TexturedColoredVertex vertex4;
} TexturedColoredQuad;

// Stores information about each image which is created.  texturedColoredQuad
// holds the original zero origin quad for the image and the texturedColoredQuadIVA
// holds a pointer to the images entry within the IVA
typedef struct {
    TexturedColoredQuad *texturedColoredQuad;
    TexturedColoredQuad *texturedColoredQuadIVA;
    GLuint textureName;
    NSUInteger renderIndex;
} ImageDetails;

// Stores a single frame of an animation which is used within the Animation class
typedef struct {
    Image *image;
    float delay;
} AnimationFrame;
