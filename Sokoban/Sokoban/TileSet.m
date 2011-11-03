//
//  TileSet.m
//  SLQTSOR
//
//  Created by Michael Daley on 05/04/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "TileSet.h"
#import "SpriteSheet.h"
#import "TextureManager.h"

@implementation TileSet

@synthesize tileSetID;
@synthesize name;
@synthesize firstGID;
@synthesize lastGID;
@synthesize tileWidth;
@synthesize tileHeight;
@synthesize spacing;
@synthesize margin;
@synthesize tiles;

- (void)dealloc {
	SLQLOG(@"INFO - TileSet: Deallocating");
	if (tiles)
		[tiles release];
	[super dealloc];
}
- (id)initWithImageNamed:(NSString*)aImageFileName name:(NSString*)aTileSetName tileSetID:(int)tsID firstGID:(int)aFirstGlobalID tileSize:(CGSize)aTileSize spacing:(int)aSpacing margin:(int)aMargin {
	self = [super init];
	if (self != nil) {
		
		sharedTextureManager = [TextureManager sharedTextureManager];
		
		// Create a sprite sheet using the filename and type identified above
        tiles = [[SpriteSheet spriteSheetForImageNamed:aImageFileName spriteSize:aTileSize spacing:aSpacing margin:aMargin imageFilter:GL_LINEAR] retain];
		
		// Set up the classes properties based on the info passed into the method
		tileSetID = tsID;
		name = aTileSetName;
		firstGID = aFirstGlobalID;
		tileWidth = aTileSize.width;
		tileHeight = aTileSize.height;
		spacing = aSpacing;
		margin = aMargin;
		
		// Calculate the value for the remaining class propertie
		horizontalTiles = tiles.horizSpriteCount;
		verticalTiles = tiles.vertSpriteCount;
		
		// Calculate the lastGID for this tile set based on the number of sprites in the image
		// and the firstGID
		lastGID = horizontalTiles * verticalTiles + firstGID - 1;
		
	}
	return self;
}


- (BOOL)containsGlobalID:(int)aGlobalID {
	// If the global ID which has been passed is within the global IDs in this
	// tileset then return YES
	return (aGlobalID >= firstGID) && (aGlobalID <= lastGID);
}


- (int)getTileX:(int)aTileID {
	return aTileID % horizontalTiles;
}


- (int)getTileY:(int)aTileID {
	return aTileID / horizontalTiles;
}

@end
