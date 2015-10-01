//
//  TabBarManager.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 26/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "TabBarManager.h"
#import "WindowManager.h"
#import "MainViewController.h"
#import "SettingsViewController.h"
#import "DocumentationViewController.h"
#import "SynthesizeSingleton.h"

typedef enum {
	kMainTabTag = 1,
	kSettingsTabTag,
    kDocumentationTabTag
} TabBarItemTag;

@interface TabBarManager (Private)

- (id) findControllerByTag: (TabBarItemTag) tag;

@end

@implementation TabBarManager

SYNTHESIZE_SINGLETON_FOR_CLASS(TabBarManager);

@dynamic mainViewController;
@dynamic settingsViewController;
@dynamic documentationViewController;

@dynamic mainSelected;
@dynamic settingsSelected;
@dynamic documentationSelected;

@synthesize viewControllersLoaded;

- (id) init
{
	PU_METHOD_LOG
    
	if ((self = [super init]))
    {
        viewControllersLoaded = NO;
	}
	return self;
}

- (void) addTabBarController:(UITabBarController *)theTabBarController
{
	PU_METHOD_LOG
	tabBarController = theTabBarController;
	theTabBarController.delegate = self;
	viewControllersLoaded = NO;
}

+ (id) tabViewControllerForClass:(Class)vc
					   withTitle:(NSString *)title
					   withImage:(NSString *)image
						 withTag:(TabBarItemTag)tag
				addNavController:(BOOL)addNavController
{
	PU_METHOD_LOG
	UIViewController *newTab = addNavController ? [[UINavigationController alloc] initWithRootViewController:[[vc new] autorelease]] : [vc new];
	newTab.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:image] tag:tag] autorelease]; 
	return [newTab autorelease];
}

-(void) loadAllViewControllers
{
	NSMutableArray *controllers = [[NSMutableArray alloc] init];
	
	[controllers addObject: [TabBarManager tabViewControllerForClass:[MainViewController class]
														   withTitle:TAB_TITLE_MAIN
														   withImage:@"home.png"
															 withTag:kMainTabTag
													addNavController:NO]];
	
	[controllers addObject: [TabBarManager tabViewControllerForClass:[SettingsViewController class]
														   withTitle:TAB_TITLE_SETTINGS
														   withImage:@"settings.png"
															 withTag:kSettingsTabTag
													addNavController:NO]];
    
    [controllers addObject: [TabBarManager tabViewControllerForClass:[DocumentationViewController class]
                                                           withTitle:TAB_TITLE_DOCUMENTATION
                                                           withImage:@"documentation.png"
                                                             withTag:kDocumentationTabTag
                                                    addNavController:YES]];

	tabBarController.viewControllers = controllers;
	
    if(controllers)
    {
        [controllers release];
        controllers = nil;
    }
	
	[self showMain];
	tabBarController.view.autoresizesSubviews = YES;
	
	[[WindowManager shared].window addSubview:tabBarController.view];
	
	viewControllersLoaded = YES;
}

- (void)refreshAllViewControllers
{
	PU_METHOD_LOG
	[tabBarController.view removeFromSuperview];
	[self loadAllViewControllers];
}

- (void) presentModalViewControllerOnTabBar:(UIViewController *)viewController animated:(BOOL)animated
{
	PU_METHOD_LOG
	[tabBarController presentViewController:viewController animated:animated completion:nil];
}

- (void) presentActionSheetOnTabBar:(UIActionSheet *)actionSheet;
{
	PU_METHOD_LOG
	[actionSheet showInView:tabBarController.view];
}

- (void)dismissModalViewControllerFromTabBarAnimated:(BOOL)animated
{
	PU_METHOD_LOG
	[tabBarController dismissViewControllerAnimated:animated completion:nil];
}

- (UIView *) tabBarView
{
	return tabBarController.view;
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

- (BOOL)tabBarController:(UITabBarController *)_tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	PU_LOG(@"%@: shouldSelectViewController called: %@", self, [viewController class]);
    
	return YES;
}

- (void)tabBarController:(UITabBarController *)lTabBarController didSelectViewController:(UIViewController *)viewController 
{
	PU_LOG(@"%@: didSelectViewController called: %@", self, [viewController class]);
	
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed 
{
	PU_METHOD_LOG
}

- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers {
	PU_METHOD_LOG
}

- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
	PU_METHOD_LOG
}

- (id) findControllerByTag: (TabBarItemTag) tag
{
	PU_METHOD_LOG
	
	for (UIViewController *controller in tabBarController.viewControllers) {
		if (controller.tabBarItem.tag == tag) {
			return controller;
		}
	}
	return nil;
}

- (int) findControllerIndexByTag: (TabBarItemTag) tag
{
	PU_METHOD_LOG
	
	int i;
	
	for (i = 0; i < [tabBarController.viewControllers count]; i++) {
		
		UIViewController *vc = [[tabBarController viewControllers] objectAtIndex:i];
		
		if (vc.tabBarItem.tag == tag) {
			return i;
		}
	}
	return -1;
}

- (id) findViewControllerByTag:(TabBarItemTag)tag visible:(BOOL)visible
{
	PU_METHOD_LOG
	
	UIViewController *controller = [self findControllerByTag:tag];
	if ([controller isKindOfClass:[UINavigationController class]]) {
		if (visible) {
			return [(UINavigationController *)controller visibleViewController];
		} else {
			return [[(UINavigationController *)controller viewControllers] objectAtIndex:0];
		}
	} else {
		return controller;
	}
	
	return nil;
}

- (UITabBarItem *) findTabBarItemByTag: (TabBarItemTag) tag
{
    PU_METHOD_LOG
    return [tabBarController.tabBar.items objectAtIndex:[self findControllerIndexByTag:tag]];
}

- (UIViewController *) visbleViewController
{
	UIViewController *controller = tabBarController.selectedViewController;
	
	if ([controller isKindOfClass:[UINavigationController class]]) {
		return [(UINavigationController *)controller visibleViewController];
	}
	
	return controller;
}

- (MainViewController *)mainViewController
{
	PU_METHOD_LOG
	return [self findViewControllerByTag:kMainTabTag visible:NO];
}

- (SettingsViewController *)settingsViewController
{
    PU_METHOD_LOG
    return [self findViewControllerByTag:kSettingsTabTag visible:NO];
}

- (DocumentationViewController *)documentationViewController
{
    PU_METHOD_LOG
    return [self findViewControllerByTag:kDocumentationTabTag visible:NO];
}

- (BOOL) mainSelected
{
	PU_METHOD_LOG
	return tabBarController.selectedViewController.tabBarItem.tag == kMainTabTag;
}

- (BOOL) settingsSelected
{
    PU_METHOD_LOG
    return tabBarController.selectedViewController.tabBarItem.tag == kSettingsTabTag;
}

- (BOOL) documentationSelected
{
    PU_METHOD_LOG
    return tabBarController.selectedViewController.tabBarItem.tag == kDocumentationTabTag;
}

- (void) showMain
{
	PU_METHOD_LOG
	tabBarController.selectedIndex = [self findControllerIndexByTag:kMainTabTag];
}

- (void) showSettings
{
    PU_METHOD_LOG
    tabBarController.selectedIndex = [self findControllerIndexByTag:kSettingsTabTag];
}

- (void) showDocumentation
{
    PU_METHOD_LOG
    tabBarController.selectedIndex = [self findControllerIndexByTag:kDocumentationTabTag];
}

@end
