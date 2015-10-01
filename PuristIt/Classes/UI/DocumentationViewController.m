//
//  DocumentationViewController.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 22/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "DocumentationViewController.h"
#import "WebViewController.h"
#import "TabBarManager.h"

@interface DocumentationViewController ()

@end

@implementation DocumentationViewController

- (id)init
{
    PU_METHOD_LOG
    
    if ((self = [super init]))
    {
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    PU_METHOD_LOG
        
    WebViewController *webViewController = [[WebViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    
    [self presentViewController:navController
                       animated:FALSE
                     completion:^{
                                    [[TabBarManager shared] showMain];
                                }];
    [webViewController loadWebpage:@"https://developer.puristit.com"];
    [webViewController release];
    [navController release];
    [super viewDidAppear:animated];
}

@end
