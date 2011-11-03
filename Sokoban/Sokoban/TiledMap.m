//
//  TileMap.m
//  SLQTSOR
//
//  Created by Michael Daley on 05/04/2009.
//  Copyright 2009 Michael Daley. All rights reserved.

#import "TiledMap.h"
#import "Transform2D.h"
#import "TBXML.h"
#import "TileSet.h"
#import "SpriteSheet.h"
#import "GameController.h"
#import "ImageRenderManager.h"
#import "AbstractScene.h"
#import "NSDataAdditions.h"
#import "Texture2D.h"

#pragma mark -
#pragma mark Private interface

@interface TiledMap (Private)

// Parses the XML read from the tiled tmx file.
- (void)parseMapFileTBXML:(TBXML*)tbXML;

// Using the parsed tilemap data, generate a VBO that contains information on each tile
// that is present in that layer.  These VBOs are then used to render layers as requested
- (void)createLayerTileImages;

// Parse the objects that have been defined on the map
- (void)parseMapObjects:(TBXML*)aTmxXML;
@end

#pragma mark -
#pragma mark Public implementation

@implementation TiledMap

@synthesize tileSets;
@synthesize layers;
@synthesize objectGroups;
@synthesize mapWidth;
@synthesize mapHeight;
@synthesize tileWidth;
@synthesize tileHeight;
@synthesize colorFilter;

- (void)dealloc {
    NSLog(@"INFO - TiledMap: Deallocating");
    [objectGroups release];
    [mapProperties release];
    if (tileSetProperties)
        [tileSetProperties release];
    [tileSets release];
    [layers release];
    [super dealloc];
}

- (id)initWithFileName:(NSString*)aTiledFile fileExtension:(NSString*)aFileExtension {
    
    self = [super init];
    if (self != nil) {
        
        // Grab a reference to the game controller
        sharedGameController = [GameController sharedGameController];
		sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
        
        // Set up the arrays and default values for layers and tilesets
        tileSets = [[NSMutableArray alloc] init];
        layers = [[NSMutableArray alloc] init];
        mapProperties = [[NSMutableDictionary alloc] init];
        objectGroups = [[NSMutableDictionary alloc] init];
        
        // Get the path to the tiled config file and parse that file
        NSLog(@"INFO - Tiled: Loading tilemap XML file");
        TBXML *tmxXML = [[TBXML alloc] initWithXMLFile:aTiledFile fileExtension:aFileExtension];
        
        NSLog(@"INFO - Tiled: Started parsing tilemap XML");
        // Parse the core tiled map
        [self parseMapFileTBXML:tmxXML];
        [self parseMapObjects:tmxXML];
        
        NSLog(@"INFO - Tiled: Finishing parsing tilemap XML");

        [tmxXML release];
    }
    
    // Create an empty TexturedColoredQuad that can be used to check for other empty TexturedColoredQuads
    // inside a layers tileImages array.
	memset(&nullTCQ, 0, sizeof(TexturedColoredQuad));
    
    // Create tile images for each layer in the tilemap.  These will then be used when we render
    // a layer.
    [self createLayerTileImages];
    
    colorFilter = Color4fOnes;
    
    return self;
}

- (void)renderLayer:(int)aLayerIndex mapx:(int)aMapx mapy:(int)aMapy width:(int)aWidth height:(int)aHeight useBlending:(BOOL)aUseBlending {

    // Make sure the boundaries of the tiles to be rendered are within the bounds of the layer
    if (aMapx < 0)
        aMapx = 0;
    if (aMapx > mapWidth)
        aMapx = mapWidth;
    if (aMapy < 0)
        aMapy = 0;
    if (aMapy > mapHeight)
        aMapy = mapHeight;
	
    int maxWidth = aMapx + aWidth;
    int maxHeight = aMapy + aHeight;	

    // Grab the layer specified
	Layer *layer = [layers objectAtIndex:aLayerIndex];
	
    // There is only ever one tileset so grab it and get the name of the texture it uses
    TileSet *tileSet = [tileSets objectAtIndex:0];
	uint textureName = [tileSet tiles].image.texture.name;
	
    // Loop through the tiles within the range specified and add their images to the render queue.
	for (int y=aMapy; y < maxHeight; y++) {
        for (int x=aMapx; x < maxWidth; x++) {
            // Grab the TexturedColoredQuad for the image at this tile location
			TexturedColoredQuad *tcq = [layer getTileImageAt:CGPointMake(x, y)];

			// If the TexturedColoredQuad returned is not the same as the nullTCQ then it is populated
            // and we can add it to the render quque.
			if (memcmp(tcq, &nullTCQ, sizeof(TexturedColoredQuad)) != 0)
				[sharedImageRenderManager addTexturedColoredQuadToRenderQueue:tcq texture:textureName];
		}
    }
}

- (TileSet*)tileSetWithGlobalID:(int)aGlobalID {
    // Loop through all the tile sets we have and check to see if the supplied global ID
    // is within one of those tile sets.  If the global ID is found then return the tile set
    // in which it was found
    for(TileSet *tileSet in tileSets) {
        if([tileSet containsGlobalID:aGlobalID]) {
            return tileSet;
        }
    }
    return nil;
}

- (int)layerIndexWithName:(NSString*)aLayerName {
    
    // Loop through the names of the layers and pass back the index if found
    for(Layer *layer in layers) {
        if([[layer layerName] isEqualToString:aLayerName]) {
            return [layer layerID];
        }
    }
    
    // If we reach here then no layer with a matching name was found
    return -1;
}


- (NSString*)mapPropertyForKey:(NSString*)aKey defaultValue:(NSString*)aDefaultValue {
    NSString *value = [mapProperties valueForKey:aKey];
    if(!value)
        return aDefaultValue;
    return value;
}


- (NSString*)layerPropertyForKey:(NSString*)aKey layerID:(int)aLayerID defaultValue:(NSString*)aDefaultValue {
    if(aLayerID < 0 || aLayerID > [layers count] -1) {
        NSLog(@"TILED ERROR: Request for a property on a layer which is out of range.");
        return nil;
    }
    NSString *value = [[[layers objectAtIndex:aLayerID] layerProperties] valueForKey:aKey];
    if(!value)
        return aDefaultValue;
    return value;
}


- (NSString*)tilePropertyForGlobalTileID:(int)aGlobalTileID key:(NSString*)aKey defaultValue:(NSString*)aDefaultValue {
    NSString *value = [[tileSetProperties valueForKey:[NSString stringWithFormat:@"%d", aGlobalTileID]] valueForKey:aKey];
    if(!value)
        return aDefaultValue;
    return value;
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation TiledMap (Private)

- (void)createLayerTileImages {
    
    int x = 0;
    int y = 0;

    // Grab the tileset for the tile map
    TileSet *tileSet = [tileSets objectAtIndex:0];
    
    // Loop through all the layers in the map and create a VBO for each
    for(int layerIndex=0; layerIndex < [layers count]; layerIndex++) {
        
        Layer *layer = [layers objectAtIndex:layerIndex];
        
        // Only create images for this layer is it is marked as visible
        if ([self layerPropertyForKey:@"visible" layerID:layerIndex defaultValue:@"0"]) {
            for(int mapTileY=0; mapTileY < mapHeight; mapTileY++) {
                for(int mapTileX=0; mapTileX < mapWidth; mapTileX++) {
                    
                    // Get the tileID and tilesetID for the current map location
                    int tileID = [layer tileIDAtTile:CGPointMake(mapTileX, mapTileY)];
                    
                    // We only want to generate information for this tile if the tile is being used
                    if (tileID > -1) {
                        // Get the sprite used at this tile locaiton
                        SpriteSheet *tileSprites = [tileSet tiles];
                        Image *tileImage = [tileSprites spriteImageAtCoords:CGPointMake([tileSet getTileX:tileID], [tileSet getTileY:tileID])];

                        // Add the tile images ImageDetails to the layer
                        [layer addTileImageAt:CGPointMake(mapTileX, mapTileY) imageDetails:tileImage.imageDetails];
                    }
                    x += tileWidth;
                }
                // Now we have finished so move to the next row of tiles and reset x.  y has to be incremented as
                // we are rendering the rows from the bottom to the top of the screen.
                y += tileHeight;
                x = 0;
            }
            y = 0;
        }
    }
}

- (void)parseMapFileTBXML:(TBXML*)tbXML {
    
    // Init the current layer, tileset and tile x and y
    currentLayerID = 0;
    currentTileSetID = 0;
    tile_x = 0;
    tile_y = 0;
    
    TBXMLElement * rootXMLElement = tbXML.rootXMLElement;
    
    if (rootXMLElement) {
        
        mapWidth = [[TBXML valueOfAttributeNamed:@"width" forElement:rootXMLElement] intValue];
        mapHeight = [[TBXML valueOfAttributeNamed:@"height" forElement:rootXMLElement] intValue];
        tileWidth = [[TBXML valueOfAttributeNamed:@"tilewidth" forElement:rootXMLElement] intValue];
        tileHeight = [[TBXML valueOfAttributeNamed:@"tileheight" forElement:rootXMLElement] intValue];
        
        NSLog(@"INFO - Tiled: Tilemap map dimensions are %dx%d", mapWidth, mapHeight);
        NSLog(@"INFO - Tiled: Tilemap tile dimensions are %dx%d", tileWidth, tileHeight);
        
        TBXMLElement * properties = [TBXML childElementNamed:@"properties" parentElement:rootXMLElement];
        if (properties) {
            TBXMLElement * property = [TBXML childElementNamed:@"property" parentElement:properties];
            
            while (property) {
                
                NSString *name = [TBXML valueOfAttributeNamed:@"name" forElement:property];
                NSString *value = [TBXML valueOfAttributeNamed:@"value" forElement:property];
                [mapProperties setObject:value forKey:name];
                NSLog(@"INFO - Tiled: Tilemap property '%@' found with value '%@'", name, value);
                
                property = property->nextSibling;
            }
        }
        
        // Process the tileset elements and read the attributes we need.
        tileSetProperties = [[NSMutableDictionary alloc] init];
        
        TBXMLElement * tileset = [TBXML childElementNamed:@"tileset" parentElement:rootXMLElement];
        while (tileset) {
            tileSetName = [TBXML valueOfAttributeNamed:@"name" forElement:tileset];
            tileSetWidth = [[TBXML valueOfAttributeNamed:@"tilewidth" forElement:tileset] intValue];
            tileSetHeight = [[TBXML valueOfAttributeNamed:@"tileheight" forElement:tileset] intValue];
            tileSetFirstGID = [[TBXML valueOfAttributeNamed:@"firstgid" forElement:tileset] intValue];
            tileSetSpacing = [[TBXML valueOfAttributeNamed:@"spacing" forElement:tileset] intValue];
            tileSetMargin = [[TBXML valueOfAttributeNamed:@"margin" forElement:tileset] intValue];
            
            NSLog(@"INFO - Tiled: --> TILESET found named: %@, width=%d, height=%d, firstgid=%d, spacing=%d, id=%d", 
                               tileSetName, tileSetWidth, tileSetHeight, tileSetFirstGID, tileSetSpacing, currentTileSetID);
            
            // Retrieve the image element
            TBXMLElement * image = [TBXML childElementNamed:@"image" parentElement:tileset];
            NSString *source = [TBXML valueOfAttributeNamed:@"source" forElement:image];
            NSLog(@"INFO - Tiled: ----> Found source for tileset called '%@'.", source);
            
            // Process any tileset properties
            TBXMLElement * tile = [TBXML childElementNamed:@"tile" parentElement:tileset];
            while (tile) {
                int tileID = [[TBXML valueOfAttributeNamed:@"id" forElement:tile] intValue] + tileSetFirstGID;
                
                NSMutableDictionary *tileProperties = [[NSMutableDictionary alloc] init];
                
                TBXMLElement * tstp = [TBXML childElementNamed:@"properties" parentElement:tile];
                TBXMLElement * tstp_property = [TBXML childElementNamed:@"property" parentElement:tstp];
                while (tstp_property) {
                    
                    //NSLog(@"INFO - Tiled: ----> Property '%@' found with value '%@' for global tile id '%@'", name, value, tileIDKey);
                    [tileProperties setObject:[TBXML valueOfAttributeNamed:@"value" forElement:tstp_property] 
                                       forKey:[TBXML valueOfAttributeNamed:@"name" forElement:tstp_property]];
                    
                    tstp_property = [TBXML nextSiblingNamed:@"property" searchFromElement:tstp_property];
                }
                [tileSetProperties setObject:tileProperties forKey:[NSString stringWithFormat:@"%d", tileID]];
                
                // Release the tileProperties now they have been added to tileSetProperties
                [tileProperties release];
                tileProperties = nil;
                
                tile = [TBXML nextSiblingNamed:@"tile" searchFromElement:tile];
            }
            
            // Create a tileset instance based on the retrieved information
            currentTileSet = [[TileSet alloc] initWithImageNamed:source 
                                                            name:tileSetName 
                                                       tileSetID:currentTileSetID 
                                                        firstGID:tileSetFirstGID 
                                                        tileSize:CGSizeMake(tileWidth, tileHeight) 
                                                         spacing:tileSetSpacing
                                                          margin:tileSetMargin];
            
            // Add the tileset instance we have just created to the array of tilesets
            [tileSets addObject:currentTileSet];
            
            // Release the current tileset instance as its been added to the array and we do not need it now
            [currentTileSet release];
            
            // Increment the current tileset id
            currentTileSetID++;
            
            tileset = [TBXML nextSiblingNamed:@"tileset" searchFromElement:tileset];
        }
        
        // Process the layer elements
        TBXMLElement * layer = [TBXML childElementNamed:@"layer" parentElement:rootXMLElement];
        while (layer) {
            layerName = [TBXML valueOfAttributeNamed:@"name" forElement:layer];
            layerWidth = [[TBXML valueOfAttributeNamed:@"width" forElement:layer] intValue];
            layerHeight = [[TBXML valueOfAttributeNamed:@"height" forElement:layer] intValue];
            
            currentLayer = [[Layer alloc] initWithName:layerName layerID:currentLayerID layerWidth:layerWidth layerHeight:layerHeight];
            NSLog(@"INFO - Tiled: --> LAYER found called: %@, width=%d, height=%d", layerName, layerWidth, layerHeight);
            
            
            // Process any layer properties
            TBXMLElement * layerProperties = [TBXML childElementNamed:@"properties" parentElement:layer];
            if (layerProperties) {
                TBXMLElement * layerProperty = [TBXML childElementNamed:@"property" parentElement:layerProperties];
                NSMutableDictionary *layerProps = [[NSMutableDictionary alloc] init];
                
                while (layerProperty) {
                    NSString *name = [TBXML valueOfAttributeNamed:@"name" forElement:layerProperty];
                    NSString *value = [TBXML valueOfAttributeNamed:@"value" forElement:layerProperty];
                    [layerProps setObject:value forKey:name];
                    //NSLog(@"INFO - Tiled: ----> Property '%@' found with value '%@'", name, value);                
                    layerProperty = layerProperty->nextSibling;
                }
                [currentLayer setLayerProperties:layerProps];
                // Release layerprops as its been added to the current layer which will have a retain on it
                [layerProps release];
            }
            
            // Process the data and tile elements
            TBXMLElement * dataElement = [TBXML childElementNamed:@"data" parentElement:layer];
            if (dataElement) {
                if ([[TBXML valueOfAttributeNamed:@"encoding" forElement:dataElement] isEqualToString:@"base64"]) {
                    
                    NSData * deflatedData = [NSData dataWithBase64EncodedString:[TBXML textForElement:dataElement]];
                    if ([[TBXML valueOfAttributeNamed:@"compression" forElement:dataElement] isEqualToString:@"gzip"])
                        deflatedData = [deflatedData gzipInflate];
                    
                    long size = sizeof(int) * (layerWidth * layerHeight);
                    int *bytes = malloc(size);
                    [deflatedData getBytes:bytes length:size];
                    
                    long y;
                    for (tile_y=0, y=0;y<layerHeight*layerWidth;y+=layerWidth,tile_y++) {
                        for (tile_x=0;tile_x<layerWidth;tile_x++) {
                            int globalID = bytes[y+tile_x];
                            if(globalID == 0) {
                                // So that the tile coordinate y axis is reversed, we perform the layerHeight - tileY
                                // calculation below
                                [currentLayer addTileAt:CGPointMake(tile_x, (layerHeight - 1) - tile_y) tileSetID:-1 tileID:-1 globalID:-1 value:-1];
                            } else {
                                TileSet *tileSet = [self tileSetWithGlobalID:globalID];
                                // So that the tile coordinate y axis is reversed, we perform the layerHeight - tileY
                                // calculation below
                                [currentLayer addTileAt:CGPointMake(tile_x, (layerHeight - 1) - tile_y) 
                                               tileSetID:[tileSet tileSetID] 
                                                  tileID:globalID - [tileSet firstGID] 
                                                globalID:globalID
                                                   value:-1];
                            }
                        }                   
                    }
                } else {
                    
                    // As we are starting the data element we need to make sure that the tileX and tileY ivars are
                    // reset ready to process the tile elements
                    tile_x = 0;
                    tile_y = 0;
                    
                    // Process the tile elements
                    TBXMLElement * tileElements = [TBXML childElementNamed:@"tile" parentElement:dataElement];
                    
                    while (tileElements) {
                        int globalID = [[TBXML valueOfAttributeNamed:@"gid" forElement:tileElements] intValue];
                        
                        // If the globalID is 0 then this is an empty tile else populate the tile array with the 
                        // retrieved tile information
                        if(globalID == 0) {
                            [currentLayer addTileAt:CGPointMake(tile_x, (layerHeight - 1) - tile_y) tileSetID:-1 tileID:-1 globalID:-1 value:-1];
                        } else {
                            TileSet *tileSet = [self tileSetWithGlobalID:globalID];
                            [currentLayer addTileAt:CGPointMake(tile_x, (layerHeight - 1) - tile_y) 
                                              tileSetID:[tileSet tileSetID] 
                                                 tileID:globalID - [tileSet firstGID] 
                                               globalID:globalID
                                                  value:-1];
                        }
                        
                        // Calculate the next coord within the tiledata array
                        tile_x++;
                        if(tile_x > layerWidth - 1) {
                            tile_x = 0;
                            tile_y++;
                        }
                        
                        tileElements = tileElements->nextSibling;
                    }
                }
            }
            // We have finished processing the layer element so add the current layer to the
            // layers array, release it and increment the current layer ID.
            [layers addObject:currentLayer];
            [currentLayer release];
            currentLayerID++;
            
            layer = [TBXML nextSiblingNamed:@"layer" searchFromElement:layer];
        }
    }
}

- (void)parseMapObjects:(TBXML*)aTmxXML {
    
    // Create the root element
    TBXMLElement *rootXMLElement = aTmxXML.rootXMLElement;
    
    // Grab the first object group
    TBXMLElement *objectGroup = [TBXML childElementNamed:@"objectgroup" parentElement:rootXMLElement];
    
    // As long as object groups are found keep processing them
    while (objectGroup) {
        NSMutableDictionary *objectGroupDetails = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *objectGroupAttribs = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *objectGroupObjects = [[NSMutableDictionary alloc] init];
        
        // Grab the attribute values from the objectGroup and add them to the objectGroups Attributes dictionary
        NSString *objectGroupName = [TBXML valueOfAttributeNamed:@"name" forElement:objectGroup];
        NSString *objectGroupWidth = [TBXML valueOfAttributeNamed:@"width" forElement:objectGroup];
        NSString *objectGroupHeight = [TBXML valueOfAttributeNamed:@"height" forElement:objectGroup];
        [objectGroupAttribs setObject:objectGroupName forKey:@"name"];
        [objectGroupAttribs setObject:objectGroupWidth forKey:@"width"];
        [objectGroupAttribs setObject:objectGroupHeight forKey:@"height"];
        [objectGroupDetails setObject:objectGroupAttribs forKey:@"Attributes"];
        
        NSLog(@"INFO - Tiled: --> OBJECT LAYER found called '%@', width:'%@', height:'%@'", objectGroupName, objectGroupWidth, objectGroupHeight);
        
        // Grab the first object within this object group
        TBXMLElement *object = [TBXML childElementNamed:@"object" parentElement:objectGroup];
        
        // Process all objects found in this object group
        while (object) {
            NSMutableDictionary *objectDetails = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *objectAttribs = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *objectProperties = [[NSMutableDictionary alloc] init];
            
            // Grab the attribute values and add them to the objectDetails attributes dictionary
            NSString *objectName = [TBXML valueOfAttributeNamed:@"name" forElement:object];
            NSString *objectType = [TBXML valueOfAttributeNamed:@"type" forElement:object];
            NSString *objectX = [TBXML valueOfAttributeNamed:@"x" forElement:object];
            NSString *objectY = [TBXML valueOfAttributeNamed:@"y" forElement:object];
            NSString *objectWidth = [TBXML valueOfAttributeNamed:@"width" forElement:object];
            NSString *objectHeight = [TBXML valueOfAttributeNamed:@"height" forElement:object];
            [objectAttribs setObject:objectName forKey:@"name"];
            if (objectType)
                [objectAttribs setObject:objectType forKey:@"type"];
            [objectAttribs setObject:objectX forKey:@"x"];
            [objectAttribs setObject:objectY forKey:@"y"];
            if (objectWidth) [objectAttribs setObject:objectWidth forKey:@"width"];
            if (objectHeight) [objectAttribs setObject:objectHeight forKey:@"height"];
            [objectDetails setObject:objectAttribs forKey:@"Attributes"];
            [objectAttribs release];
            
            //NSLog(@"INFO - Tiled: ----> Object found called '%@', type:'%@', x:'%@', y:'%@'", objectName, objectType,
            //                    objectX, objectY);
            
            // Grab the first properties for this object
            TBXMLElement *properties = [TBXML childElementNamed:@"properties" parentElement:object];
            
            // Process all property elements found inside the objects properties element
            if (properties) {
                // Grab a property element
                TBXMLElement *property = [TBXML childElementNamed:@"property" parentElement:properties];
                
                // Process all properties within this properties element
                while (property) {
                    // Grab the attributes for this property and load them into the objectsProperties dictionary
                    NSString *objectPropertyName = [TBXML valueOfAttributeNamed:@"name" forElement:property];
                    NSString *objectPropertyValue = [TBXML valueOfAttributeNamed:@"value" forElement:property];
                    [objectProperties setObject:objectPropertyValue forKey:objectPropertyName];
                    
                    //NSLog(@"INFO - Tiled: ------> Object property found called '%@', value:'%@'", objectPropertyName, objectPropertyValue);
                    
                    // Move to the next property element
                    property = [TBXML nextSiblingNamed:@"property" searchFromElement:property];
                }
                
                // Finished processing the properties so add the objectProperties dictionary to the obejctDetails dictionary
                [objectDetails setObject:objectProperties forKey:@"Properties"];
            }
            
            // Add the objects detals dictionary to the objectGroupDetails dictionary using the objects name as a key
            [objectGroupObjects setObject:objectDetails forKey:objectName];
            [objectProperties release];
            [objectDetails release];
            
            // Move to the next object
            object = object->nextSibling;
        }
        
        // Finished processing all the objects in this object group.  Add the objectsGroupDetails dictionary to the
        // objectGroups dictionary using the objectGroups name as a key
        [objectGroupDetails setObject:objectGroupObjects forKey:@"Objects"];
        
        [objectGroups setObject:objectGroupDetails forKey:objectGroupName];
        [objectGroupAttribs release];
        [objectGroupDetails release];
        [objectGroupObjects release];
        
        // Move to the next objectGroup in the map file.
        objectGroup = [TBXML nextSiblingNamed:@"objectgroup" searchFromElement:objectGroup];
    }
}

@end