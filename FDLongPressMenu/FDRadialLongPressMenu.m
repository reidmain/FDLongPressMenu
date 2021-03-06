#import "FDRadialLongPressMenu.h"
#import "FDCircleView.h"
#import "math.h"
#import "UIView+Layout.h"
#import "FDDegreesToRadians.h"


#pragma mark Constants

#define DEBUG_DRAWINGS 0 // Set to 1 to draw circles showing the intersection points with the view's bounds.
#define DEFAULT_RADIUS 90.0f


#pragma mark - Class Extension

@interface FDRadialLongPressMenu ()

- (void)_calculateMinimumRequiredRadiusForPoint: (CGPoint)point 
	inView: (UIView *)view 
	withHalfMaximumMenuItemDimension: (CGFloat)halfMaximumMenuItemDimension 
	items: (NSArray *)items 
	itemSpacing: (CGFloat *)itemSpacing 
	startingAngle: (CGFloat *)startingAngle 
	availableSpace: (CGFloat *)availableSpace;

@end


#pragma mark - Class Definition

@implementation FDRadialLongPressMenu
{
	@private CGFloat _radius;
	@private CGPoint _originPoint;
}


#pragma mark - Constructors

- (id)initWithDelegate: (id<FDLongPressMenuDelegate>)delegate
{
	// Abort if base initializer fails.
	if ((self = [super initWithDelegate: delegate]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_desiredItemSpacing = 50.0f;
	
	// Return initialized instance.
	return self;
}


#pragma mark - Overridden Methods

- (void)displayLongPressMenuItems: (NSArray *)longPressMenuItems 
	atPoint: (CGPoint)point 
	inView: (UIView *)view
{
	// Store the point so the menu items can be animated back to it when the menu is closed.
	_originPoint = point;
	
	// Set the default radius of the menu.
	_radius = DEFAULT_RADIUS;
	
	// Calculate the maximum dimension of the menu items to ensure that there is a margin of half that on all sides of the view so no menu items are clipped.
	__block CGFloat halfMaximumMenuItemDimension = 0.0f;
	[longPressMenuItems enumerateObjectsUsingBlock: ^(FDLongPressMenuItem *longPressMenuItem, NSUInteger idx, BOOL *stop)
		{
			CGSize menuItemSize = longPressMenuItem.view.bounds.size;
			
			halfMaximumMenuItemDimension = MAX(halfMaximumMenuItemDimension, MAX(menuItemSize.width, menuItemSize.height));
		}];
	halfMaximumMenuItemDimension /= 2.0f;
	
	// Calculate the starting angle available space for the current radius. If the item spacing is too large for the radius increase the radius and recalculate the starting and populating angles until they are big enough.
	CGFloat itemSpacing = 0.0f;
	CGFloat startingAngle = 0.0f;
	CGFloat availableSpace = 0.0f;
	
	[self _calculateMinimumRequiredRadiusForPoint: point 
		inView: view 
		withHalfMaximumMenuItemDimension: halfMaximumMenuItemDimension 
		items: longPressMenuItems 
		itemSpacing: &itemSpacing 
		startingAngle: &startingAngle 
		availableSpace: &availableSpace];
	
#if DEBUG_DRAWINGS
	// Draw an outline of the inner bounds of the view.
	CGRect outlineRect = CGRectMake(halfMaximumMenuItemDimension, halfMaximumMenuItemDimension, view.width - halfMaximumMenuItemDimension * 2, view.height - halfMaximumMenuItemDimension * 2);
	UIView *outlineView = [[UIView alloc] 
		initWithFrame: outlineRect];
	outlineView.backgroundColor = [UIColor clearColor];
	outlineView.layer.borderColor = [[UIColor blackColor] CGColor];
	outlineView.layer.borderWidth = 1.0f;
	[view addSubview: outlineView];
	
	// Add a circle to the view to shown the intersection points with the inner bounds.
	FDCircleView *outlineCircle = [[FDCircleView alloc] 
		initWithFrame: CGRectMake(0.0f, 0.0f, _radius * 2, _radius * 2)];
	outlineCircle.startingAngle = startingAngle;
	outlineCircle.endingAngle = startingAngle + availableSpace;
	outlineCircle.strokeColor = [UIColor greenColor];
	
	outlineCircle.center = point;
	[view addSubview: outlineCircle];
#endif
	
	// Animate the menu items out from the press point and center them inside the available space.
	[longPressMenuItems enumerateObjectsUsingBlock: ^(FDLongPressMenuItem *longPressMenuItem, NSUInteger index, BOOL *stop)
		{
			longPressMenuItem.view.center = point;
			longPressMenuItem.view.transform = CGAffineTransformMakeScale(0.4f, 0.4f);
			
			[view addSubview: longPressMenuItem.view];
		}];
	
	__block CGFloat angle = startingAngle + ((availableSpace - (([longPressMenuItems count] - 1) * itemSpacing)) / 2.0f);
	[UIView animateWithDuration: 0.2f 
		delay: 0.0f 
		options: UIViewAnimationOptionCurveEaseInOut 
		animations: ^
			{
				[longPressMenuItems enumerateObjectsUsingBlock: ^(FDLongPressMenuItem *longPressMenuItem, NSUInteger index, BOOL *stop)
					{
						CGFloat x = point.x + _radius * cosf(angle);
						CGFloat y = point.y + _radius * sinf(angle);
						[longPressMenuItem.view setPixelSnappedCenter: CGPointMake(x, y)];
						
						longPressMenuItem.view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
						
						angle += itemSpacing;
					}];
			} 
		completion:nil];
}

- (FDLongPressMenuItem *)updateLongPressMenuItems: (NSArray *)longPressMenuItems 
	atPoint: (CGPoint)point 
	inView: (UIView *)view
{
	FDLongPressMenuItem *highlightedLongPressMenuItem = nil;
	
	// Determine the distance of the closest menu item to the point.
	__block FDLongPressMenuItem *closestLongPressMenuItem = nil;
	__block CGFloat distanceToClosestItem = CGFLOAT_MAX;
	
	[longPressMenuItems enumerateObjectsUsingBlock: ^(FDLongPressMenuItem *longPressMenuItem, NSUInteger index, BOOL *stop)
		{
			UIView *view = longPressMenuItem.view;
			
			CGFloat xDistance = view.center.x - point.x;
			CGFloat yDistance = view.center.y - point.y;
			CGFloat distanceFromItem = sqrtf((xDistance * xDistance) + (yDistance * yDistance));
			
			if(distanceFromItem < distanceToClosestItem)
			{
				closestLongPressMenuItem = longPressMenuItem;
				distanceToClosestItem = distanceFromItem;
			}
			
			view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
		}];
	
	// If the distance to the closest menu item is less than the radius of the circle enlarge the item by some factor to indicate to the user they are close to selecting it.
	if(distanceToClosestItem <= _radius)
	{
		CGFloat enlargementFactor = 1.0f + (((_radius - distanceToClosestItem) / _radius) * 0.6);
		closestLongPressMenuItem.view.transform = CGAffineTransformMakeScale(enlargementFactor, enlargementFactor);
		
		// If the distance to the item is less than a given threshold highlight the item to indicate to the user they will select it if they release their finger.
		if(distanceToClosestItem <= _radius * 0.6f)
		{
			highlightedLongPressMenuItem = closestLongPressMenuItem;
		}
	}
	
	return highlightedLongPressMenuItem;
}

- (void)hideLongPressMenuItems: (NSArray *)longPressMenuItems 
	completionBlock: (void (^)(void))completionBlock
{
	// Animate all of the items out of view and then remove them from the view hierachy.
	[UIView animateWithDuration: 0.2f 
		delay: 0.0f 
		options: UIViewAnimationOptionCurveEaseInOut 
		animations: ^
			{
				[longPressMenuItems enumerateObjectsUsingBlock: ^(FDLongPressMenuItem *longPressMenuItem, NSUInteger index, BOOL *stop)
					{
						longPressMenuItem.view.center = _originPoint;
						longPressMenuItem.view.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
					}];
			} 
		completion: ^(BOOL finished)
			{
				completionBlock();
			}];
}


#pragma mark - Private Methods

- (void)_calculateMinimumRequiredRadiusForPoint: (CGPoint)point 
	inView: (UIView *)view 
	withHalfMaximumMenuItemDimension: (CGFloat)halfMaximumMenuItemDimension 
	items: (NSArray *)items 
	itemSpacing: (CGFloat *)itemSpacing 
	startingAngle: (CGFloat *)startingAngle 
	availableSpace: (CGFloat *)availableSpace
{
	// Calculate if the circle around the point will intersect the top or bottom of the view.
	BOOL intersectsTop = point.y - _radius - halfMaximumMenuItemDimension <= 0.0f;
	BOOL intersectsBottom = point.y + _radius + halfMaximumMenuItemDimension >= view.height;
	
	// Convert the desired item spacing to radians.
	*itemSpacing = FDDegreesToRadians(_desiredItemSpacing);
	
	// Default to using a half circle that is projected upwards from the point.
	*startingAngle = -M_PI;
	*availableSpace = M_PI;
	
	// Determine if the circle around the point is intersecting the left side of the view.
	if(point.x - _radius - halfMaximumMenuItemDimension <= 0.0f)
	{
		// Calculate the angle which the circle is intersecting with the left side of the view. Arccosine can be used because the intersection point of the cicle in the top two quadrants can be mirrored along the y-axis to get the intersection point in the bottom two quadrants.
		CGFloat xDifference = halfMaximumMenuItemDimension - point.x;
		CGFloat leftIntersectionAngle = acosf(xDifference / _radius);
		
		if(intersectsTop == YES)
		{
			// Calculate the angle which the circle is intersecting with the top side of the view. The circle is also intersecting with the left side of the view so arcsine can safely be used to calculate the angle because the first and fourth quadrants are the only possible points of intersection.
			CGFloat yDifference = point.y - halfMaximumMenuItemDimension;
			CGFloat topIntersectionAngle = asinf(yDifference / _radius);
			
			*startingAngle = -topIntersectionAngle;
			*availableSpace = topIntersectionAngle + leftIntersectionAngle;
		}
		else if(intersectsBottom == YES)
		{
			// Calculate the angle which the circle is intersecting with the bottom side of the view. The circle is also intersecting with the left side of the view so arcsine can safely be used to calculate the angle because the first and fourth quadrants are the only possible points of intersection.
			CGFloat yDifference = view.height - halfMaximumMenuItemDimension - point.y;
			CGFloat bottomIntersectionAngle = asinf(yDifference / _radius);
			
			*startingAngle = -leftIntersectionAngle;
			*availableSpace = leftIntersectionAngle + bottomIntersectionAngle;
		}
		else
		{
			*startingAngle = -leftIntersectionAngle;
			// Ensure the available space is less than or equal to a given maximum to prevent items from being displayed under the user's thumb. As the radius increases the maximum value can be increased because the circle will be drawn far enough away from the user's thumb that no items should be displayed under it.
			CGFloat maximumSpace = 50.0f + (_radius - DEFAULT_RADIUS);
			*availableSpace = leftIntersectionAngle + MIN(leftIntersectionAngle, FDDegreesToRadians(maximumSpace));
		}
	}
	// Determine if if the circle around the point is intersecting the right side of the view.
	else if(point.x + _radius + halfMaximumMenuItemDimension >= view.width)
	{
		// Calculate the angle which the circle is intersecting with the right side of the view. Arccosine can be used because the intersection point of the circle in the top two quadrants can be mirrored along the y-axis to get the intersection point in the bottom two quadrants.
		CGFloat xDifference = view.width - halfMaximumMenuItemDimension - point.x;
		CGFloat rightIntersectionAngle = acosf(xDifference / _radius);
		
		if(intersectsTop == YES)
		{
			// Calculate the angle which the circle is intersecting with the top side of the view.
			CGFloat yDifference = point.y - halfMaximumMenuItemDimension;
			CGFloat topIntersectionAngle = (M_PI_2 - acosf(yDifference / _radius)) + M_PI;
			
			// Ensure the starting angle is a minimum value to ensure that no items are displayed under the user's thumb. As the radius increases the minimum value can be relaxed because the circle will be drawn far enough away from the user's thumb that no items should be displayed under it.
			CGFloat minimumAngle = 130.0f - (_radius - DEFAULT_RADIUS);
			
			*startingAngle = MAX(rightIntersectionAngle, FDDegreesToRadians(minimumAngle));
			*availableSpace = topIntersectionAngle - *startingAngle;
		}
		else if(intersectsBottom == YES)
		{
			// Calculate the angle which the circle is intersecting with the bottom side of the view.
			CGFloat yDifference = point.y + halfMaximumMenuItemDimension - view.height;
			CGFloat bottomIntersectionAngle = (M_PI_2 - acosf(yDifference / _radius)) + M_PI;
			
			*startingAngle = bottomIntersectionAngle;
			*availableSpace = 2 * M_PI - rightIntersectionAngle - bottomIntersectionAngle;
		}
		else
		{
			// Ensure the starting angle is a minimum value to ensure that no items are displayed under the user's thumb. As the radius increases the minimum value can be relaxed because the circle will be drawn far enough away from the user's thumb that no items should be displayed under it.
			CGFloat minimumAngle = 140.0f - (_radius - DEFAULT_RADIUS);
			
			*startingAngle = MAX(rightIntersectionAngle, FDDegreesToRadians(minimumAngle));
			*availableSpace = (2 * M_PI) - *startingAngle - rightIntersectionAngle;
		}
	}
	// If the circle around the point intersects with only the top of the view use a half circle projected downward from the point.
	else if(intersectsTop == YES)
	{
		// Calculate the angle which the circle is intersecting with the top side of the view.
		CGFloat topIntersectionAngle = M_PI_2 - acosf((point.y - halfMaximumMenuItemDimension) / _radius);
		
		*startingAngle = -topIntersectionAngle;
		*availableSpace = M_PI + (2 * topIntersectionAngle);
	}
	// If the circle around the point intersects with only the bottom of the view use a half circle projected upwards from the point.
	else if(intersectsBottom == YES)
	{
		// Calculate the angle which the circle is intersecting with the bottom side of the view.
		CGFloat bottomIntersectionAngle = M_PI_2 - acosf((view.height - halfMaximumMenuItemDimension - point.y) / _radius);
		
		*startingAngle = -M_PI - bottomIntersectionAngle;
		*availableSpace = M_PI + (2 * bottomIntersectionAngle);
	}
	
	// If there is not enough space for the requested item spacing recalculate the item spacing to be as large as possible.
	if(([items count] - 1) * *itemSpacing > *availableSpace)
	{
		*itemSpacing = *availableSpace / ([items count] - 1);
	}
	
	// Ensure the radius of the circle is large enough so no items overlap one another. The distance between two items should be at least the maximum dimension of the menu items.
	// NOTE: The distance between two points along the circumference is distance^2 = radius^2 * 2(1 - cos(theta)) where theta is the angle between the two points. This can be reduced to radius = sqrt(distance^2 / 2(1 - cos(theta))).
	CGFloat distanceSquared = powf(halfMaximumMenuItemDimension * 2, 2);
	CGFloat angleMath = 1 - cosf(*itemSpacing);
	
	CGFloat minimumRadius = sqrtf(distanceSquared / (2 * angleMath));
	if (minimumRadius > _radius 
		&& ABS(minimumRadius - _radius) > 1.0f)
	{
		_radius = minimumRadius;
		
		[self _calculateMinimumRequiredRadiusForPoint: point 
			inView: view 
			withHalfMaximumMenuItemDimension: halfMaximumMenuItemDimension 
			items: items 
			itemSpacing: itemSpacing 
			startingAngle: startingAngle 
			availableSpace: availableSpace];
	}
}


@end