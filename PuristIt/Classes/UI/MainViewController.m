//
//  MainViewController.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 17/01/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "MainViewController.h"
#import "DBManager.h"
#import "ChatManager.h"
#import "WebViewController.h"
#import "MBProgressHUD.h"
#import "UIViewAdditions.h"
#import "TabBarManager.h"
#import "PushHandler.h"

@interface MainViewController () <UIActionSheetDelegate>
{
    UIImageView *step1Status;
    UIImageView *step2Status;
    UIImageView *step3Status;
}

@property (assign) APIResponseCode apiResponseCode;
@property (nonatomic, retain) MBProgressHUD *HUD;

@end

@implementation MainViewController

- (void) refreshStatusDisplay
{
    PU_METHOD_LOG
    
    step1Status.image = ([DBManager getRegistrationStatus])?[UIImage imageNamed:@"success.png"]:[UIImage imageNamed:@"fail.png"];
    step2Status.image = ([DBManager getInitializationStatus])?[UIImage imageNamed:@"success.png"]:[UIImage imageNamed:@"fail.png"];
    step3Status.image = ([DBManager getInitializationStatus])?[UIImage imageNamed:@"success.png"]:[UIImage imageNamed:@"fail.png"];
}

- (void) step1Pressed
{
    PU_METHOD_LOG
    
    if([DBManager getRegistrationStatus])
    {
        [self displayAlert:@"You have already registered successfully. To register as a different user, please tap 'Settings' and enter a different username of your choice, before attempting to register"];
        return;
    }
    
    if(![[DBManager getUsername] length])
    {
        [self displayAlert:@"Please tap 'Settings' and enter a username and password of your choice, before attempting to register"];
        return;
    }
    
    [self startActivityIndicator:@"Registering" description:@"The registration API is now being called with the credentials set up by you under Settings"];
    [self performSelectorOnMainThread:@selector(callRegisterAPI)
                           withObject:nil
                        waitUntilDone:YES];
    
    [self performSelector:@selector(unfreezeAfterRegistration)
               withObject:nil
               afterDelay:1.5];
}

- (void) callRegisterAPI
{
    PU_METHOD_LOG
    
    self.apiResponseCode = [[ChatManager shared] registrationAPI];
}

- (void) unfreezeAfterRegistration
{
    PU_METHOD_LOG
    
    [self stopActivityIndicator];
    [self refreshStatusDisplay];
    
    if(self.apiResponseCode != kNetworkSuccess)
    {
        [self displayAlert:@"Registration API call failed"];
    }
}

- (void) step2Pressed
{
    PU_METHOD_LOG
    
    if([DBManager getInitializationStatus])
    {
        [self displayAlert:@"You have already initialized successfully"];
        return;
    }
    
    if(![DBManager getRegistrationStatus])
    {
        [self displayAlert:@"Please complete registration before attempting to initialize"];
        return;
    }
    
    [self startActivityIndicator:@"Initializing" description:@"The initialization API is now being called with the registered username and password"];
    [self performSelectorOnMainThread:@selector(callInitializeAPI)
                           withObject:nil
                        waitUntilDone:YES];
    
    [self performSelector:@selector(unfreezeAfterInitialization)
               withObject:nil
               afterDelay:1.5];
}

- (void) callInitializeAPI
{
    PU_METHOD_LOG
    
    self.apiResponseCode = [[ChatManager shared] initializationAPI];
}

- (void) unfreezeAfterInitialization
{
    PU_METHOD_LOG
    
    [self stopActivityIndicator];
    [self refreshStatusDisplay];
    
    if(self.apiResponseCode != kNetworkSuccess)
    {
        [self displayAlert:@"Initialization API call failed"];
    }
}

- (void) step3Pressed
{
    PU_METHOD_LOG
    
    if(![DBManager getRegistrationStatus])
    {
        [self displayAlert:@"Please complete registration and initialization before attempting to chat"];
        return;
    }
    
    if(![DBManager getInitializationStatus])
    {
        [self displayAlert:@"Please complete initialization before attempting to chat"];
        return;
    }
    
    if([[ChatManager shared] isChatURLValid])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = self;
        
        [actionSheet setTitle:@"Select your Chat room"];
        [actionSheet addButtonWithTitle:@"General room"];
        [actionSheet addButtonWithTitle:@"Allow me to switch to any room"];
        [actionSheet addButtonWithTitle:@"Cancel"];
        
        actionSheet.cancelButtonIndex = [actionSheet numberOfButtons] - 1;
        
        [[TabBarManager shared] presentActionSheetOnTabBar:actionSheet];
        [actionSheet release];
    }
    else
    {
        [self displayAlert:@"Chat URL has expired, please repeat initialization before attempting to chat"];
    }
    
    [self refreshStatusDisplay];
}

- (void) showChatUrlWithRoom:(NSString *)room
                    roomlist:(BOOL)roomlist
                      header:(BOOL)header
                     bgcolor:(NSString *)bgcolor
                     fgcolor:(NSString *)fgcolor
                 headercolor:(NSString *)headercolor
{
    PU_METHOD_LOG
    
    WebViewController *webViewController = [[WebViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    [self presentViewController:navController animated:TRUE completion:nil];
    
    NSString *pushid = @"";
    if([[PushHandler shared] getPushRegistrationStatus] == kPushRegistered)
        pushid = [[PushHandler shared] getPushID];
    NSString *getString = [NSString stringWithFormat:@"platform=IPHONE&roomlist=%d&header=%d&registration_id=%@", roomlist, header, pushid];
    
    if([room length])
        getString = [NSString stringWithFormat:@"%@&room=%@", getString, room];
    if([bgcolor length] && [fgcolor length])
        getString = [NSString stringWithFormat:@"%@&bgcolor=%@&fgcolor=%@&headercolor=%@", getString, bgcolor, fgcolor, headercolor ];
    
    NSString *url = [NSString stringWithFormat:@"%@?%@", [DBManager getChatURL], getString];
    //url = @"https://s-user.puristit.com/webchat/test.html";
    //url = @"https://s-user.puristit.com/webchat/test2.html";
    //  url = @"https://s-user.puristit.com/webchat/test4.html";
    NSLog(@"url -----> %@", url);
    
    [webViewController loadWebpage:url];
    [webViewController release];
    [navController release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    PU_METHOD_LOG
    
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    if(buttonIndex == 0)
        [self showChatUrlWithRoom:@"General" roomlist:FALSE header:FALSE bgcolor:nil fgcolor:nil headercolor:nil];
    else
        [self showChatUrlWithRoom:nil roomlist:TRUE header:TRUE bgcolor:@"feffb7" fgcolor:@"ff2323" headercolor:@"ffb554"];
}

- (void) displayAlert:(NSString *)msg
{
    PU_METHOD_LOG
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@""
                                                     message:msg
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] autorelease];
    [alert show];
    return;
}

- (void)dealloc
{
    PU_METHOD_LOG
    
    if (_HUD)
    {
        [self stopActivityIndicator];
    }
    
    [super dealloc];
}

-(void)stopActivityIndicator
{
    PU_METHOD_LOG
    
    if (self.HUD)
    {
        [self.HUD show:FALSE];
        [self.HUD removeFromSuperview];
        
        [[UIApplication sharedApplication] keyWindow].userInteractionEnabled = TRUE;
    }
    
     self.HUD = nil;
}

- (void)startActivityIndicator:(NSString *)message description:(NSString *)description
{
    PU_METHOD_LOG
    
    if (! self.HUD)
    {
        [[UIApplication sharedApplication] keyWindow].userInteractionEnabled = FALSE;
        
        self.HUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
        self.HUD.detailsLabelText = description;
        self.HUD.labelText = message;
        
        [self.view addSubview:self.HUD];
        [self.HUD show:TRUE];
    }
}

- (void)viewDidLoad
{
    PU_METHOD_LOG
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view autoresizesSubviews];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logoImageView.center = self.view.center;
    logoImageView.top = self.view.top + 60;
    [self.view addSubview:logoImageView];
    [logoImageView release];
    
    UIButton *step1Button = [self makeButtonWithText:@"Step 1: Registration"
                                            selector:@selector(step1Pressed)
                                              target:self];
    
    
    UIButton *step2Button = [self makeButtonWithText:@"Step 2: Initialization"
                                            selector:@selector(step2Pressed)
                                              target:self];
    
    
    UIButton *step3Button = [self makeButtonWithText:@"Step 3: Chat"
                                            selector:@selector(step3Pressed)
                                              target:self];
    
    step2Button.center = self.view.center;
    step2Button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    step1Button.center = step2Button.center;
    step1Button.bottom = step2Button.top - 40;
    step1Button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    step3Button.center = step2Button.center;
    step3Button.top = step2Button.bottom + 40;
    step3Button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    step1Status = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fail.png"]];
    step1Status.center = step1Button.center;
    step1Status.left = step1Button.right + 10;
    
    step2Status = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fail.png"]];
    step2Status.center = step2Button.center;
    step2Status.left = step2Button.right + 10;
    
    step3Status = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fail.png"]];
    step3Status.center = step3Button.center;
    step3Status.left = step3Button.right + 10;
    
    [self.view addSubview:step1Button];
    [self.view addSubview:step2Button];
    [self.view addSubview:step3Button];
    [self.view addSubview:step1Status];
    [self.view addSubview:step2Status];
    [self.view addSubview:step3Status];
    
    [self refreshStatusDisplay];
}

- (void)viewWillAppear:(BOOL)animated
{
    PU_METHOD_LOG
    
    [self refreshStatusDisplay];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    PU_METHOD_LOG
    
    [self stopActivityIndicator];
    
    [super viewWillDisappear:animated];
}

- (UIButton *) makeButtonWithText:(NSString *)title selector:(SEL) selector target:(id) target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"button-bg.png"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [button setBounds:CGRectMake(0, 0, 210, 40)];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

@end
