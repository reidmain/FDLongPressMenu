#import "FDCircleView.h"


#pragma mark Class Definition

@implementation FDCircleView


#pragma mark - Properties

- (void)setStartingAngle: (CGFloat)startingAngle
{
	if (_startingAngle != startingAngle)
	{
		_startingAngle = startingAngle;
		
		[self setNeedsDisplay];
	}
}

- (void)setEndingAngle: (CGFloat)endingAngle
{
	if (_endingAngle != endingAngle)
	{
		_endingAngle = endingAngle;
		
		[self setNeedsDisplay];
	}
}


#pragma mark - Constructors

- (id)initWithFrame: (CGRect)frame
{
	// Abort if base initializer fails.
	if ((self = [super initWithFrame: frame]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeCircleView];
	
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
	
	// Initialize view.
	[self _initializeCircleView];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Overridden Methods

- (void)drawRect: (CGRect)rect
{
	CGContextRef contextRef = UIGraphicsGetCurrentContext();
	
	CGFloat radius = self.bounds.size.width / 2.0f;
	CGPoint center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
	
	CGFloat startX = center.x + (cosf(_startingAngle) * radius);
	CGFloat startY = center.y + (sinf(_startingAngle) * radius);
	
	CGMutablePathRef path = CGPathCreateMutable();

	CGPathMoveToPoint(path, NULL, center.x, center.y);
	CGPathAddLineToPoint(path, NULL, startX, startY);
	CGPathAddArc(path, NULL, center.x, center.y, radius, _startingAngle, _endingAngle, NO);
	
	CGPathCloseSubpath(path);
	
	CGContextAddPath(contextRef, path);
	CGContextSetFillColorWithColor(contextRef, [_fillColor CGColor]);
	CGContextFillPath(contextRef);
	
	CGContextAddPath(contextRef, path);
	CGContextSetLineWidth(contextRef, 1.0f);
	CGContextSetStrokeColorWithColor(contextRef, [_strokeColor CGColor]);
	CGContextStrokePath(contextRef);
	
	CGPathRelease(path);
}


#pragma mark - Private Methods

- (void)_initializeCircleView
{
	// Initialize instance variables.
	_startingAngle = 0.0f;
	_endingAngle = 2 * M_PI;
	_fillColor = [UIColor colorWithRed: 0.0f 
		green: 0.0f 
		blue: 1.0f 
		alpha: 0.5f];
	_strokeColor = [UIColor blackColor];
	
	// Set the background color of the view to be clear otherwise it will default to black.
	self.backgroundColor = [UIColor clearColor];
}


@end