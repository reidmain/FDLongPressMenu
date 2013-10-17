#import "FDLongPressMenu.h"
#import "FDLongPressMenuItem+Private.h"
#import "UIView+Layout.h"


#pragma mark Class Extension

@interface FDLongPressMenu ()

- (void)_longPressGestureRecognized: (UILongPressGestureRecognizer *)longPressGestureRecognizer;
- (void)_closeLongPressMenuWithSelectedItem: (FDLongPressMenuItem *)longPressMenuItem;
- (void)_deviceOrientationDidChangeNotificationRaised;


@end


#pragma mark - Class Definition

@implementation FDLongPressMenu
{
	@private __weak id<FDLongPressMenuDelegate> _delegate;
	@private __strong NSArray *_longPressMenuItems;
	@private __weak UIView *_containerView;
	@private __weak FDLongPressMenuItem *_highlightedLongPressMenuItem;
}


#pragma mark - Constructors

- (id)initWithDelegate: (id<FDLongPressMenuDelegate>)delegate
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_delegate = delegate;
	_longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] 
		initWithTarget: self 
			action:@selector(_longPressGestureRecognized:)];
	_longPressGestureRecognizer.minimumPressDuration = 0.2;
	_longPressGestureRecognizer.allowableMovement = 50.0f;
	_longPressGestureRecognizer.delegate = self;
	
	// Start listening for changes to device orientation.
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver: self 
		selector: @selector(_deviceOrientationDidChangeNotificationRaised) 
		name: UIDeviceOrientationDidChangeNotification 
		object: nil];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Destructor

- (void)dealloc
{
	// Stop listening for changes to device orientation.
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver: self 
		name: UIDeviceOrientationDidChangeNotification 
		object: nil];
}


#pragma mark - Public Methods

- (void)displayLongPressMenuItems: (NSArray *)longPressMenuItems 
	atPoint: (CGPoint)point 
	inView: (UIView *)view
{
	// Abstract method.
}

- (FDLongPressMenuItem *)updateLongPressMenuItems: (NSArray *)longPressMenuItems 
	atPoint: (CGPoint)point 
	inView: (UIView *)view
{
	// Abstract method.
	return nil;
}

- (void)hideLongPressMenuItems: (NSArray *)longPressMenuItems 
	completionBlock: (FDLongPressMenuHideCompletionBlock)completionBlock
{
	// Abstract method.
	completionBlock();
}


#pragma mark - Private Methods

- (void)_longPressGestureRecognized: (UILongPressGestureRecognizer *)longPressGestureRecognizer
{
	UIView *gestureView = longPressGestureRecognizer.view;
	UIWindow *gestureWindow = gestureView.window;
	UIView *gestureWindowRootView = [[gestureWindow subviews] objectAtIndex: 0];
	
	// To display the menu items outside of the bounds of the gesture view a container view must be created and added to the gesture view's window. However a UIWindow does not get a transform applied to it when the device is rotated. The transform is applied to the window's root subview. To properly convert the touch point from the gesture view's coordinate system to the window's the container view must be added to the window's root view instead.
	if (_containerView == nil 
		&& longPressGestureRecognizer.state == UIGestureRecognizerStateBegan)
	{
		UIView *containerView = [[UIView alloc] 
			initWithFrame: gestureWindowRootView.bounds];
		
		// If the root view controller of the window wants full screen layout and the status bar is visible the container view needs to be offset so it does not appear below the status bar.
		UIApplication *sharedApplication = [UIApplication sharedApplication];
		if (sharedApplication.statusBarHidden == NO)
		{
			// The statusBarFrame property returns back the incorrect values when the app is in landscape mode. The minimum value of the width/height will be the actual height of the status bar.
			CGFloat statusBarHeight = MIN(sharedApplication.statusBarFrame.size.width, sharedApplication.statusBarFrame.size.height);
			
			containerView.yOrigin = statusBarHeight;
			containerView.height -= statusBarHeight;
		}
		
		_containerView = containerView;
		[gestureWindowRootView addSubview: _containerView];
	}
	
	// Calculate whichs point in the gesture view and the container view the user is pressed down on.
	CGPoint viewPressPoint = [longPressGestureRecognizer locationInView: gestureView];
	CGPoint containerViewPressPoint = [longPressGestureRecognizer locationInView: _containerView];
	
	switch(longPressGestureRecognizer.state)
	{
		// If the user has just started the long press gesture add the menu items to the container view.
		case UIGestureRecognizerStateBegan:
		{
			// Ask the delegate for the menu items that should be displayed.
			_longPressMenuItems = [_delegate itemsForLongPressMenu: self 
				atPoint: viewPressPoint 
				inView: gestureView];
			
			// If no menu items exist then there is nothing to do.
			if ([_longPressMenuItems count] == 0)
			{
				break;
			}
			
			// FDLongPressMenu is an abstract base class so ask the subclass to display the menu items inside the container view.
			[self displayLongPressMenuItems: _longPressMenuItems 
				atPoint: containerViewPressPoint 
				inView: _containerView];
			
			break;
		}
		
		case UIGestureRecognizerStateChanged:
		{
			// FDLongPressMenu is a abstract base class so ask the subclass to update the menu items based on the proximity of the user's touch to them.
			_highlightedLongPressMenuItem = [self updateLongPressMenuItems: _longPressMenuItems 
				atPoint: containerViewPressPoint 
				inView: _containerView];
			
			// Bring the highlighted long press menu item to the front so if any scaling or sizing changes are made it will appear above the other menu items.
			[_highlightedLongPressMenuItem.view.superview bringSubviewToFront: _highlightedLongPressMenuItem.view];
			
			[_longPressMenuItems enumerateObjectsUsingBlock: ^(FDLongPressMenuItem *longPressMenuItem, NSUInteger index, BOOL *stop)
				{
					[longPressMenuItem _setHighlighted: _highlightedLongPressMenuItem == longPressMenuItem];
				}];
			
			break;
		}
		
		case UIGestureRecognizerStateEnded:
		{
			[self _closeLongPressMenuWithSelectedItem: _highlightedLongPressMenuItem];
			
			break;
		}
		
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed:
		{
			[self _closeLongPressMenuWithSelectedItem: nil];
			
			break;
		}
		
		default:
			break;
	}
}

- (void)_closeLongPressMenuWithSelectedItem: (FDLongPressMenuItem *)longPressMenuItem
{
	// Notify the delegate which item was selected.
	[_delegate didCloseLongPressMenu: self 
		withSelectedItem: longPressMenuItem];
	
	[self hideLongPressMenuItems: _longPressMenuItems 
		completionBlock: ^
			{
				[_containerView removeFromSuperview];
			}];
	
	_longPressMenuItems = nil;
}

- (void)_deviceOrientationDidChangeNotificationRaised
{
	// If the device's rotation orientation changes kill any gesture that is being recognized so the menu will be hidden. The menu cannot be easily repositioned under the user's finger so it is a better experience to simply hide the menu.
	UIDevice *currentDevice = [UIDevice currentDevice];
	UIDeviceOrientation currentOrientation = currentDevice.orientation;
	
	if (currentOrientation == UIDeviceOrientationFaceUp 
		|| currentOrientation == UIDeviceOrientationFaceDown)
	{
		return;
	}
	
	// Toggle the long gesture recognizer off than on to kill any gesture that is currently being recognized.
	_longPressGestureRecognizer.enabled = NO;
	_longPressGestureRecognizer.enabled = YES;
}


#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin: (UIGestureRecognizer *)gestureRecognizer
{
	BOOL gestureRecognizerShouldBegin = YES;
	
	// Ask the delegate if the menu can be shown at the pressed point.
	if ([_delegate respondsToSelector:@selector(shouldDisplayLongPressMenu:atPoint:inView:)] == YES)
	{
		gestureRecognizerShouldBegin = [_delegate shouldDisplayLongPressMenu: self 
			atPoint: [gestureRecognizer locationInView:gestureRecognizer.view] 
			inView: gestureRecognizer.view];
	}

	return gestureRecognizerShouldBegin;
}

@end