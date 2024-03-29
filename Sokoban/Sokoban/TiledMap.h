//
//  TileMap.h
//  SLQTSOR
//
//  Created by Michael Daley on 05/04/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "Global.h"
#import "Layer.h"

@class SpriteSheet;
@class TileSet;
@class GameController;
@class ImageRenderManager;

// Maximum numbers that can be handled in a single tile map
#define kMax_Map_Layers 5

// This class will parse the tmx file from the tiled tool available on http://mapeditor.org
//
// This class is used to read the XML output from Tiled.  It can handle multiple layers,
// tilesets and properties on each of these. 
//
@interface TiledMap : NSObject {
	
	///////////////////// Singleton managers
    GameController *sharedGameController;	// Reference to the game controller
	ImageRenderManager *sharedImageRenderManager;

	///////////////////// Global tile map ivars
	uint mapWidth;								// The width of the map in tiles
	uint mapHeight;								// The height of the map in tiles
	uint tileWidth;								// The width of a tile
	uint tileHeight;							// The height of a tile
	uint currentTileSetID;						// Current TileSet ID
	TileSet *currentTileSet;					// Current TileSet Instance
	uint currentLayerID;						// Current Layer ID
	Layer *currentLayer;						// Current Layer instance
	Color4f	colorFilter;						// Color to be applied to a rendered map layer
	NSMutableArray *tileSets;					// Array of TileSets in this map
	NSMutableArray *layers;						// Array of Layers in this map
	NSMutableDictionary *mapProperties;			// Map properties
	NSMutableDictionary *tileSetProperties;		// Tile set properties
	NSMutableDictionary *objectGroups;			// Object groups

	///////////////////// Rendering globals
	TexturedColoredQuad nullTCQ;				// Empty TexturedColoredQuad used to check for empty tile entries
	
	///////////////////// Tileset ivars	
	NSString *tileSetName;
	int tileSetID;					
	int tileSetWidth;
	int tileSetHeight;
	int tileSetFirstGID;
	int tileSetSpacing;
	int tileSetMargin;
	
	///////////////////// Layer & tile ivars
	NSString *layerName;
	int layerID;
	int layerWidth;
	int layerHeight;
	int tile_x;
	int tile_y;

}

@property (nonatomic, readonly) NSMutableArray *tileSets;
@property (nonatomic, readonly) NSMutableArray *layers;
@property (nonatomic, readonly) NSMutableDictionary *objectGroups;
@property (nonatomic, readonly) GLuint mapWidth;
@property (nonatomic, readonly) GLuint mapHeight;
@property (nonatomic, readonly) GLuint tileWidth;
@property (nonatomic, readonly) GLuint tileHeight;

@property (nonatomic, assign) Color4f colorFilter;

// Designated selector that loads the tile map details from the supplied file name and extension
- (id)initWithFileName:(NSString*)aTiledFile fileExtension:(NSString*)aFileExtension;

// Renders the tilemap layer provided from point {0, 0}
- (void)renderLayer:(int)aLayerIndex mapx:(int)aMapx mapy:(int)aMapy width:(int)aWidth height:(int)aHeight useBlending:(BOOL)aUseBlending;

// Returns the tileset which contains a tile image with the |aGlobalID| which is passed in
- (TileSet*)tileSetWithGlobalID:(int)aGlobalID;

// Returns the layer ID which belongs to the layer whose name matches the |aName| provided
- (int)layerIndexWithName:(NSString*)aLayerName;

// Returns the string value for a map property which matches |aKey|.  It also takes a default
// value which is used if no matching key can be found
- (NSString*)mapPropertyForKey:(NSString*)aKey defaultValue:(NSString*)aDefaultValue;

// Returns the string value for a layer property on the specified layer |aLayerID| with the specified
// |aKey|.  If not match for the key is found then |aDefaultValue| is returned
- (NSString*)layerPropertyForKey:(NSString*)aKey layerID:(int)aLayerID defaultValue:(NSString*)aDefaultValue;

// Returns the string value for a tile property on the specified |aGlobalTileID| with the key |aKey|.
// If no match is found for the key then |aDefaultValue| is returned
- (NSString*)tilePropertyForGlobalTileID:(int)aGlobalTileID key:(NSString*)aKey defaultValue:(NSString*)aDefaultValue;

@end
