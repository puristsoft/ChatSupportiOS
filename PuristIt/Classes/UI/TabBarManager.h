//
//  TabBarManager.h
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 26/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

@class MainViewController;
@class SettingsViewController;
@class DocumentationViewController;

@interface TabBarManager : NSObject <UITabBarControllerDelegate> {
    @private
	UITabBarController *tabBarController;
	BOOL viewControllersLoaded;
}

@property (nonatomic, readonly) BOOL viewControllersLoaded;

@property (nonatomic, retain, readonly) MainViewController *mainViewController;
@property (nonatomic, retain, readonly) SettingsViewController *settingsViewController;
@property (nonatomic, retain, readonly) DocumentationViewController *documentationViewController;

@property (nonatomic, readonly) BOOL mainSelected;
@property (nonatomic, readonly) BOOL settingsSelected;
@property (nonatomic, readonly) BOOL documentationSelected;

+ (TabBarManager *) shared;

- (void) addTabBarController:(UITabBarController *)theTabBarController;

-(void) loadAllViewControllers;
-(void) refreshAllViewControllers;

- (void) presentModalViewControllerOnTabBar:(UIViewController *)viewController animated:(BOOL)animated;
- (void) dismissModalViewControllerFromTabBarAnimated:(BOOL)animated;
- (void) presentActionSheetOnTabBar:(UIActionSheet *)actionSheet;
- (UIView *) tabBarView;
- (UIViewController *) visbleViewController;

- (void) showMain;
- (void) showSettings;
- (void) showDocumentation;

#define TAB_TITLE_MAIN @"Home"
#define TAB_TITLE_SETTINGS @"Settings"
#define TAB_TITLE_DOCUMENTATION @"Docs"

@end