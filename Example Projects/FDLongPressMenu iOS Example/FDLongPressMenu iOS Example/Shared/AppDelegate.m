#import "AppDelegate.h"
#import "FDColouredBlocksGridController.h"


#pragma mark Class Definition

@implementation AppDelegate
{
	@private __strong UIWindow *_mainWindow;
}


#pragma mark - UIApplicationDelegate Methods

- (BOOL)application: (UIApplication *)application 
	didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
	// Create the main window.
	UIScreen *mainScreen = [UIScreen mainScreen];
	
	_mainWindow = [[UIWindow alloc] 
		initWithFrame: mainScreen.bounds];
	
	_mainWindow.backgroundColor = [UIColor blackColor];
	
	// Create the window's root view controller.
	FDColouredBlocksGridController *colouredBlocksGridController = [[FDColouredBlocksGridController alloc] 
		initWithDefaultNibName];
	
	UINavigationController *navigationController = [[UINavigationController alloc] 
		initWithRootViewController: colouredBlocksGridController];
	
	_mainWindow.rootViewController = navigationController;
	
	// Show the main window.
	[_mainWindow makeKeyAndVisible];
	
	// Indicate success.
	return YES;
}


@end