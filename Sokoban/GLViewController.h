//
//  GLViewController.h
//  Sokoban
//
//  Created by hoangkaka on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"

@interface GLViewController : UIViewController
- (IBAction)replay:(id)sender;

- (void)startAnimation;
- (void)stopAnimation;

@end
