#import "FDLongPressMenuItem.h"
#import "FDLongPressMenuItem+Private.h"
#import "UIView+Layout.h"


#pragma mark Class Definition

@implementation FDLongPressMenuItem
{
	@private __strong UIImageView *_backgroundImageView;
	@private __strong UIImageView *_iconImageView;
}


#pragma mark - Properties

- (void)_setHighlighted: (BOOL)highlighted
{
	_backgroundImageView.highlighted = highlighted;
	_iconImageView.highlighted = highlighted;
}


#pragma mark - Constructors

- (id)initWithBackgroundImage: (UIImage *)backgroundImage 
	highlightedBackgroundImage: (UIImage *)highlightedBackgroundImage 
	iconImage:	(UIImage *)iconImage 
	highlightedIconImage: (UIImage *)highlightedIconImage
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_backgroundImageView = [[UIImageView alloc] 
		initWithImage: backgroundImage 
			highlightedImage: highlightedBackgroundImage];
	_iconImageView = [[UIImageView alloc] initWithImage: iconImage 
		highlightedImage: highlightedIconImage];
	
	// Create a UIView that will be the visual representation of the menu item.
	_view = [[UIView alloc] initWithFrame:[_backgroundImageView bounds]];
	[_view addSubview: _backgroundImageView];
	[_view addSubview: _iconImageView];
	
	// Center the icon in the middle of the background image.
	[_iconImageView alignHorizontally: UIViewHorizontalAlignmentCenter 
		vertically: UIViewVerticalAlignmentMiddle];
	
	// Return initialized instance.
	return self;
}


@end