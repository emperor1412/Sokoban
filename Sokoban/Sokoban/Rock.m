//
//  Rock.m
//  Sokoban
//
//  Created by Le Huy Hoang on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Rock.h"

@implementation Rock
@synthesize location = _location;
@synthesize imageRock;
@synthesize tileCoord;



#pragma mark - dealloc
- (void)dealloc {
    [super dealloc];
}




#pragma mark - init
- (id)initWithImage:(Image *)image {
    self = [super init];
    if (self) {
        self.imageRock = image;
    }
    return self;
}




#pragma mark - render
- (void)render {
    [imageRock renderCenteredAtPoint:_location];
}




#pragma mark - get bounds
- (CGRect)movementBounds {
    return CGRectMake(_location.x - 15, _location.y - 16, 30, 30);
}

- (CGRect)collisionBounds {
    return CGRectMake(_location.x - 18, _location.y - 19, 36, 38);
}

@end
