//
//  ShiftableViewController.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 22/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "ShiftableViewController.h"
#import "WindowManager.h"
#import "DeviceUtility.h"
#import "UIViewAdditions.h"

@interface ShiftableViewController ()

@end

@implementation ShiftableViewController

- (void) dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = FALSE;
    self.navigationController.navigationBar.translucent = NO;
}

- (CGPoint) unshiftedViewOrigin
{
    return [DeviceUtility doesHaveTransparentStatusBar] ? CGPointMake(0.0f, self.navigationController.navigationBar.bottom) : CGPointZero;
}
    
- (void) unShiftView
{
    if (self.viewIsShifted)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        self.view.origin = self.unshiftedViewOrigin;
        [UIView commitAnimations];
    }
}

- (BOOL) viewIsShifted
{
    return ! CGPointEqualToPoint(self.view.origin, self.unshiftedViewOrigin);
}
    
    
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    PU_METHOD_LOG
    [self unShiftView];
        
    CGFloat keyBoardTop = self.view.frame.size.height - 216 - textField.inputAccessoryView.height;
        
    CGPoint textFieldOrigin = [textField convertPoint:CGPointZero toView:self.view];
        
    CGFloat textFieldBottom = textFieldOrigin.y + textField.size.height;
        
    if (textFieldBottom >
        keyBoardTop)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
            
#define KEYBOARD_MARGIN 5.0f
            
        self.view.centerY += (keyBoardTop - textFieldBottom -  KEYBOARD_MARGIN);
        [UIView commitAnimations];
    }
}

@end
