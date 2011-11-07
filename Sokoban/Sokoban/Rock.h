//
//  Rock.h
//  Sokoban
//
//  Created by Le Huy Hoang on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Image.h"

@interface Rock : NSObject {
    @public
    CGPoint _location;
}

@property (assign) CGPoint tileCoord;
@property (assign) CGPoint location;
@property (nonatomic, retain)Image *imageRock;

- (void)render;
- (id)initWithImage:(Image *)image;

- (CGRect)movementBounds;
- (CGRect)collisionBounds;

@end
