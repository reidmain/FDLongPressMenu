#import "FDCollectionViewCell.h"


#pragma mark Class Extension

@interface FDCollectionViewCell ()

- (void)_initializeCollectionViewCell;


@end


#pragma mark - Class Definition

@implementation FDCollectionViewCell
{
	@private __strong UIColor *_backgroundColour;
}


#pragma mark - Constructors

- (id)initWithFrame: (CGRect)frame
{
	// Abort if base initializer fails.
	if ((self = [super initWithFrame: frame]) == nil)
	{
		return nil;
	}
	
	// Initialize collection view cell.
	[self _initializeCollectionViewCell];
	
	// Return initialized instance.
	return self;
}

- (id)initWithCoder: (NSCoder *)coder
{
	// Abort if base initializer fails.
	if ((self = [super initWithCoder: coder]) == nil)
	{
		return nil;
	}
	
	// Initialize collection view cell.
	[self _initializeCollectionViewCell];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Overridden Methods

- (void)setHighlighted: (BOOL)highlighted
{
	// Call the base implementation.
	[super setHighlighted: highlighted];
	
	// Configure the collection view cell for the highlighted state.
	if (self.selected == NO)
	{
		self.backgroundColor = highlighted == YES ? [UIColor orangeColor] : _backgroundColour;
	}
}

- (void)setSelected: (BOOL)selected
{
	// Call the base implementation.
	[super setSelected: selected];
	
	// Configure the table view cell for the selected state.
	self.backgroundColor = selected == YES ? [UIColor orangeColor] : _backgroundColour;
}


#pragma mark - Private Methods

- (void)_initializeCollectionViewCell
{
	// Initialize instance variables.
	_backgroundColour = [UIColor colorWithRed: 0.0f / 255.0f 
		green: 56.0f / 255.0f 
		blue: 118.0f / 255.0f 
		alpha: 1.0f];
	
	self.backgroundColor = _backgroundColour;
}


@end