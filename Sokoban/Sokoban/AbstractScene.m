//
//  AbstractState.m
//  OGLGame
//
//  Created by Michael Daley on 01/06/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "AbstractScene.h"

@implementation AbstractScene

@synthesize sceneState;
@synthesize sceneAlpha;

- (void)updateSceneWithDelta:(GLfloat)aDelta {}
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)updateWithAccelerometer:(UIAcceleration*)aAcceleration {}
- (void)transitionToSceneWithKey:(NSString*)aKey {}
- (void)renderScene {}

@end