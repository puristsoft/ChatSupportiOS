//
//  WindowManager.h
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 26/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

@interface WindowManager : NSObject {
    @private
	UIWindow *window;
}
	
@property (nonatomic, retain) UIWindow *window;
	
+ (WindowManager *) shared;

@end
