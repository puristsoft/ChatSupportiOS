//
//  WebViewController.h
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 17/01/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) UIWebView *webView;

- (id)init;
- (void)loadWebpage:(NSString *)urlString;
- (void)reloadWebpage;
- (void)stopActivityIndicator;

@end
