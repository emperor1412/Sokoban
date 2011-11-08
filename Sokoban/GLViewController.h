//
//  GLViewController.h
//  Sokoban
//
//  Created by hoangkaka on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
#import "GameController.h"


@interface GLViewController : UIViewController
- (IBAction)replay:(id)sender;
- (IBAction)nextLevel:(id)sender;
- (IBAction)previousLevel:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *winGameLabel;


- (void)startAnimation;
- (void)stopAnimation;

- (void)showWinGame;
- (void)hideWinGame;

@end
