#import "FDLongPressMenuItem.h"
#import "FDLongPressMenuItem+Private.h"


#pragma mark Class Definition

@implementation FDLongPressMenuItem
{
	@private __strong UIImage *_backgroundImage;
	@private __strong UIImage *_highlightedBackgroundImage;
	@private __strong UIImage *_iconImage;
	@private __strong UIImage *_highlightedIconImage;
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
	_backgroundImage = backgroundImage;
	_highlightedBackgroundImage = highlightedBackgroundImage;
	_iconImage = iconImage;
	_highlightedIconImage = highlightedIconImage;
	_backgroundImageView = [[UIImageView alloc] 
		initWithImage: backgroundImage 
			highlightedImage: highlightedBackgroundImage];
	_iconImageView = [[UIImageView alloc] initWithImage: iconImage 
		highlightedImage: highlightedIconImage];
	_iconImageView.contentMode = UIViewContentModeCenter;
	_iconImageView.frame = _backgroundImageView.bounds;
	
	// Create a UIView that will be the visual representation of the menu item.
	_view = [[UIView alloc] initWithFrame:[_backgroundImageView bounds]];
	[_view addSubview: _backgroundImageView];
	[_view addSubview: _iconImageView];
	
	// Return initialized instance.
	return self;
}


@end