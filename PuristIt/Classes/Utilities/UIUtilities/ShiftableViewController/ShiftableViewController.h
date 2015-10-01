//
//  ShiftableViewController.h
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 22/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

@interface ShiftableViewController : UIViewController

- (void) unShiftView;
- (BOOL) viewIsShifted;
    
- (void)textFieldDidBeginEditing:(UITextField *)textField;
    
@end
