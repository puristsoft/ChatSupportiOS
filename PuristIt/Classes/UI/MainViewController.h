//
//  MainViewController.h
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 17/01/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

@interface MainViewController : UIViewController

- (void) showChatUrlWithRoom:(NSString *)room
                    roomlist:(BOOL)roomlist
                      header:(BOOL)header
                     bgcolor:(NSString *)bgcolor
                     fgcolor:(NSString *)fgcolor
                 headercolor:(NSString *)headercolor;

@end

