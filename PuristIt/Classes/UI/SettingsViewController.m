//
//  SettingsViewController.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 22/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "SettingsViewController.h"
#import "DBManager.h"
#import "ChatManager.h"
#import "DeviceUtility.h"
#import "UIViewAdditions.h"

@interface SettingsViewController () <UITextFieldDelegate>

@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UITextField *domainField;
@property (nonatomic, retain) UITextField *apikeyField;

@end

@implementation SettingsViewController

- (void)dealloc
{
	PU_METHOD_LOG
 
    [_usernameField release];
    [_passwordField release];
    [_domainField release];
    [_apikeyField release];
	[super dealloc];
}

- (void) preloadData
{
    PU_METHOD_LOG
    
    self.usernameField.text = [DBManager getUsername];
    self.passwordField.text = [DBManager getPassword];
    self.domainField.text = [DBManager getDomain];
    self.apikeyField.text = [DBManager getAPIKey];
}

- (void) updatePressed
{
    PU_METHOD_LOG
    
    [self.view endEditing:YES];
    
    if(![self.usernameField.text length])
    {
        [self displayAlert:@"Username can't be blank"];
        return;
    }
    if([self.usernameField.text containsString:@"@"] ||
       [self.usernameField.text containsString:@"."])
    {
        [self displayAlert:@"Username can't be an email address"];
        return;
    }
    if(![self.passwordField.text length])
    {
        [self displayAlert:@"Password can't be blank"];
        return;
    }
    if(![self.domainField.text length])
    {
        [self displayAlert:@"Domain can't be blank"];
        return;
    }
    if([self.domainField.text containsString:@"@"] ||
       ![self.domainField.text containsString:@"."])
    {
        [self displayAlert:@"Invalid domain name. If your company is Yahoo, then your domain name should be yahoo.com"];
    }
    if(![self.apikeyField.text length])
    {
        [self displayAlert:@"API key can't be blank"];
        return;
    }
    
    [DBManager setUsername:self.usernameField.text];
    [DBManager setPassword:self.passwordField.text];
    [DBManager setDomain:self.domainField.text];
    [DBManager setAPIKey:self.apikeyField.text];
    [DBManager setChatURLExpirationTimestamp:0];
    [DBManager setRegistrationStatus:FALSE];
    [DBManager setInitializationStatus:FALSE];
    [DBManager setChatURL:@""];
    
    [self displayAlert:@"Update successful!"];
}

- (void) resetPressed
{
    PU_METHOD_LOG
    
    [self.view endEditing:YES];
    
    [[ChatManager shared] loadDefaultUserData];
    [self preloadData];
}

- (void) displayAlert:(NSString *)msg
{
    PU_METHOD_LOG
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    return;
}

- (id)init
{
	PU_METHOD_LOG
	if ((self = [super init]))
	{
	}
	
	return self;
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
    CGFloat textFieldTop = logoImageView.bottom + 30;
    [logoImageView release];
    
    self.usernameField = [self makeTextField];
    self.usernameField.placeholder = @"Enter a username of choice";
    self.usernameField.center = self.view.center;
    self.usernameField.top = textFieldTop;
    self.usernameField.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:self.usernameField];
    
    self.passwordField = [self makeTextField];
    self.passwordField.placeholder = @"Enter a password of choice";
    self.passwordField.center = self.view.center;
    self.passwordField.top = self.usernameField.bottom + 10;
    self.passwordField.returnKeyType = UIReturnKeyNext;
    self.passwordField.secureTextEntry = YES;
    [self.view addSubview:self.passwordField];
    
    self.domainField = [self makeTextField];
    self.domainField.placeholder = @"Enter your company's domain name. Eg. google.com";
    self.domainField.center = self.view.center;
    self.domainField.top = self.passwordField.bottom + 10;
    self.domainField.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:self.domainField];
    
    self.apikeyField = [self makeTextField];
    self.apikeyField.placeholder = @"Enter your company's PuristIt API Key";
    self.apikeyField.center = self.view.center;
    self.apikeyField.top = self.domainField.bottom + 10;
    [self.view addSubview:self.apikeyField];
    
    UIButton *updateButton = [self makeButtonWithText:@"Update"
                                             selector:@selector(updatePressed)
                                               target:self];
    updateButton.left = self.apikeyField.left;
    updateButton.top = self.apikeyField.bottom + 30;
    updateButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:updateButton];
    
    UIButton *resetButton = [self makeButtonWithText:@"Reset"
                                            selector:@selector(resetPressed)
                                              target:self];
    resetButton.center = updateButton.center;
    resetButton.right = self.apikeyField.right;
    resetButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:resetButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    PU_METHOD_LOG
    
    [self preloadData];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	PU_METHOD_LOG
	[self.view endEditing:YES];
    
	[super viewWillDisappear:animated];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	PU_METHOD_LOG
	
    [super textFieldDidBeginEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	PU_METHOD_LOG
	
	[self unShiftView];
}
                            
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    PU_METHOD_LOG
    
    if (textField == self.usernameField)
    {
        [self.usernameField resignFirstResponder];
        [self.passwordField becomeFirstResponder];
    }
    else if (textField == self.passwordField)
    {
        [self.passwordField resignFirstResponder];
        [self.domainField becomeFirstResponder];
    }
    else if (textField == self.domainField)
    {
        [self.domainField resignFirstResponder];
        [self.apikeyField becomeFirstResponder];
    }
    else if (textField == self.apikeyField)
    {
        [self.apikeyField resignFirstResponder];
        
        [self updatePressed];
    }
    
    return YES;
}

- (UITextField *) makeTextField
{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 26.0, 291.0, 35.0)];
    textField.adjustsFontSizeToFitWidth = YES;
    textField.alpha = 1.000;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autoresizesSubviews = YES;
    textField.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    textField.backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:0.000];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.clearButtonMode = UITextFieldViewModeNever;
    textField.clearsContextBeforeDrawing = NO;
    textField.clearsOnBeginEditing = NO;
    textField.clipsToBounds = NO;
    textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    textField.contentMode = UIViewContentModeScaleToFill;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.enabled = YES;
    //textField.enablesReturnKeyAutomatically = NO;
    textField.hidden = NO;
    textField.highlighted = NO;
    textField.keyboardAppearance = UIKeyboardAppearanceDefault;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDone;
    textField.minimumFontSize = 10.000;
    textField.font = [UIFont systemFontOfSize:10];
    textField.multipleTouchEnabled = NO;
    textField.opaque = NO;
    textField.secureTextEntry = NO;
    textField.selected = NO;
    textField.tag = 30;
    textField.text = @"";
    textField.textColor = [UIColor colorWithWhite:0.000 alpha:1.000];
    textField.userInteractionEnabled = YES;
    textField.delegate = self;
    
    return [textField autorelease];
}

- (UIButton *) makeButtonWithText:(NSString *)title selector:(SEL) selector target:(id) target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"button-bg.png"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [button setBounds:CGRectMake(0, 0, 130, 35)];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

@end



