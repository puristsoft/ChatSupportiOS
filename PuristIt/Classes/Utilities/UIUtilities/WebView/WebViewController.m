//
//  WebViewController.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 17/01/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "WebViewController.h"
#import "MBProgressHUD.h"

@interface WebViewController ()

@property (nonatomic, retain) MBProgressHUD *HUD;

@end

@implementation WebViewController

- (void)dealloc 
{
    PU_METHOD_LOG
	_webView.delegate = nil;
    [_webView stopLoading];
    [_webView release];
    
    if (_HUD)
	{
        [self cleanupHUD];
	}
    
	[super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    PU_METHOD_LOG
	self.webView.delegate = nil;
    [self.webView stopLoading];
    self.webView = nil;
    [self cleanupHUD];
	
    [UIApplication.sharedApplication setStatusBarHidden:NO
                                          withAnimation:UIStatusBarAnimationFade];
    
	[super viewWillDisappear:animated];
}

- (void) cleanupHUD
{
    PU_METHOD_LOG
    [self.HUD show:FALSE];
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

-(void)stopActivityIndicator
{
    PU_METHOD_LOG
	if (self.HUD)
	{
        [self cleanupHUD];
		
		if (self.navigationItem.rightBarButtonItem)
        {
			self.navigationItem.rightBarButtonItem.enabled = TRUE;
        }
		
		self.webView.userInteractionEnabled = TRUE;
	}
}

- (void)startActivityIndicator:(NSString *)url
{
    PU_METHOD_LOG
	if (! self.HUD)
    {
        self.webView.userInteractionEnabled = FALSE;

        // The hud will disable all input on the view
        self.HUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
        self.HUD.detailsLabelText = url;
        self.HUD.labelText = @"Loading";
        // Add HUD to screen
        [self.view addSubview:self.HUD];
        [self.HUD show:TRUE];
	}
}

- (id) init
{
    PU_METHOD_LOG
    if ((self = [super init]))
    {
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void) viewDidLoad
{
    PU_METHOD_LOG
    [super viewDidLoad];
    self.webView.frame = self.view.bounds;
    self.webView.autoresizingMask = self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.opaque = YES;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    self.view.backgroundColor = self.webView.backgroundColor = [UIColor whiteColor];
}

- (BOOL)weWerePushed
{
    PU_METHOD_LOG
    return self.presentingViewController == nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    PU_METHOD_LOG
    [super viewWillAppear:animated];
   
    [UIApplication.sharedApplication setStatusBarHidden:YES
                                          withAnimation:UIStatusBarAnimationFade];
    
    if(![self weWerePushed])
    {
        UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc]
                                          initWithTitle:@"Done"
                                          style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(dismiss)] autorelease];
        self.navigationItem.leftBarButtonItem = cancelButton;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        //self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleBordered;
    }
}

- (void)loadWebpage:(NSString *) urlString
{
    PU_METHOD_LOG
    [self startActivityIndicator:urlString];
    
	//Process request
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[self.webView performSelectorOnMainThread:@selector(loadRequest:)
                                   withObject:urlRequest
                                waitUntilDone:YES];
}

- (void)reloadWebpage
{
    PU_METHOD_LOG
	if (self.navigationItem.rightBarButtonItem)
    {
		self.navigationItem.rightBarButtonItem.enabled = FALSE;
    }
	
	[self.webView reload];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    PU_METHOD_LOG
	[self stopActivityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    PU_METHOD_LOG
	[self stopActivityIndicator];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    PU_METHOD_LOG
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dismiss
{
    PU_METHOD_LOG
    [self stopActivityIndicator];
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

@end
