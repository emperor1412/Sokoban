//
//  GLViewController.m
//  Sokoban
//
//  Created by hoangkaka on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GLViewController.h"
#import "Global.h"

@implementation GLViewController
@synthesize winGameLabel;



#pragma mark - memory management
- (void)dealloc {
    
    [winGameLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}




#pragma mark - init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}




#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewDidUnload
{

    [self setWinGameLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - show/hide win game label
- (void)showWinGame {
    self.winGameLabel.hidden = NO;
}

- (void)hideWinGame {
    self.winGameLabel.hidden = YES;
}




#pragma mark - glview start/stop
- (void)startAnimation {
    [(EAGLView *)self.view startAnimation];
}

- (void)stopAnimation {
    [(EAGLView *)self.view stopAnimation];
}



#pragma mark - action methods
- (IBAction)replay:(id)sender {
    DLog(@"");
    [(EAGLView *)self.view stopAnimation];
    [(EAGLView *)self.view startAnimation];
    [[GameController sharedGameController] replay];
    [self hideWinGame];
}

- (IBAction)nextLevel:(id)sender {
    DLog(@"");
    [(EAGLView *)self.view stopAnimation];
    [(EAGLView *)self.view startAnimation];
    [[GameController sharedGameController] nextLevel];
    [self hideWinGame];
}

- (IBAction)previousLevel:(id)sender {
    DLog(@"");
    [(EAGLView *)self.view stopAnimation];
    [(EAGLView *)self.view startAnimation];
    [[GameController sharedGameController] previousLevel];
    [self hideWinGame];
}






@end
