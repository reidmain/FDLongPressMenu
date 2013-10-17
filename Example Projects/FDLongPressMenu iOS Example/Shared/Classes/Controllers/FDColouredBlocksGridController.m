#import "FDColouredBlocksGridController.h"
#import <FDLongPressMenu/FDRadialLongPressMenu.h>
#import "FDCollectionViewCell.h"


#pragma mark Constants

static NSString * const CellReuseIdentifier = @"CellIdentifier";
static NSString * const FillColour_Red = @"Red";
static NSString * const FillColour_Green = @"Green";
static NSString * const FillColour_Blue = @"Blue";
static NSString * const FillColour_Black = @"Black";
static NSString * const FillColour_Orange = @"Orange";
static NSString * const FillColour_Purple = @"Purple";
static NSString * const FillColour_Yellow = @"Yellow";


#pragma mark - Class Extension

@interface FDColouredBlocksGridController ()

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *footerView;
@property (nonatomic, weak) IBOutlet UIView *footerViewContent;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *footerViewHeightConstraint;

- (void)_initializeColouredBlocksGridController;


@end


#pragma mark - Class Definition

@implementation FDColouredBlocksGridController


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [self initWithNibName: @"FDColouredBlocksGridView" 
		bundle: nil]) == nil)
	{
		return nil;
	}
	
	// Return initialized instance.
	return self;
}

- (id)initWithNibName: (NSString *)nibName 
    bundle: (NSBundle *)bundle
{
	// Abort if base initializer fails.
	if ((self = [super initWithNibName: nibName 
        bundle: bundle]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeColouredBlocksGridController];
	
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
	[self _initializeColouredBlocksGridController];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Destructor

- (void)dealloc 
{
	// nil out delegates of any instance variables.
	_collectionView.delegate = nil;
	_collectionView.dataSource = nil;
}


#pragma mark - Overridden Methods

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)viewDidLoad
{
	// Call base implementation.
	[super viewDidLoad];
	
	// On iPad increase the height of the footer view.
	UIDevice *currentDevice = [UIDevice currentDevice];
	if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		_footerViewHeightConstraint.constant = 180.0f;
	}
	
	// Register cell classes with the collection view.
	[_collectionView registerClass: [FDCollectionViewCell class] 
		forCellWithReuseIdentifier: CellReuseIdentifier];
	
	// Add a radial long press menu to the controller's view.
	FDRadialLongPressMenu *radialLongPressMenu = [[FDRadialLongPressMenu alloc] 
		initWithDelegate: self];
	[self.view addLongPressMenu: radialLongPressMenu];
}


#pragma mark - Private Methods

- (void)_initializeColouredBlocksGridController
{
	// Set the controller's title.
	self.title = @"Press and hold";
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView: (UICollectionView *)collectionView 
	numberOfItemsInSection: (NSInteger)section
{
	NSInteger numberOfItems = 0;
	
	if (collectionView == _collectionView)
	{
		UIDevice *currentDevice = [UIDevice currentDevice];
		numberOfItems = currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? 50 : 30;
	}
	
	return numberOfItems;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView 
	cellForItemAtIndexPath: (NSIndexPath *)indexPath
{
	UICollectionViewCell *cell = nil;
	
	if (collectionView == _collectionView)
	{
		cell = [collectionView dequeueReusableCellWithReuseIdentifier: CellReuseIdentifier 
			forIndexPath: indexPath];
	}
	
	return cell;
}


#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView: (UICollectionView *)collectionView 
	didSelectItemAtIndexPath: (NSIndexPath *)indexPath
{
	[collectionView deselectItemAtIndexPath: indexPath 
		animated: YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView: (UICollectionView *)collectionView 
	layout: (UICollectionViewLayout *)collectionViewLayout 
	sizeForItemAtIndexPath: (NSIndexPath *)indexPath
{
	UIDevice *currentDevice = [UIDevice currentDevice];
	CGFloat squareSideLength = currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? 244.0f : 100.0f;
	
	CGSize itemSize = CGSizeMake(squareSideLength, squareSideLength);
	
	return itemSize;
}

- (CGFloat)collectionView: (UICollectionView *)collectionView 
	layout: (UICollectionViewLayout*)collectionViewLayout 
	minimumLineSpacingForSectionAtIndex: (NSInteger)section
{
	CGFloat minimumLineSpacing = 0.0f;
	
	if (collectionView == _collectionView)
	{
		UIDevice *currentDevice = [UIDevice currentDevice];
		minimumLineSpacing = currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? 12.0f : 10.0f;
	}
	
	return minimumLineSpacing;
}

- (CGFloat)collectionView: (UICollectionView *)collectionView 
	layout: (UICollectionViewLayout *)collectionViewLayout 
	minimumInteritemSpacingForSectionAtIndex: (NSInteger)section
{
	CGFloat minimumInteritemSpacing = 0.0f;
	
	if (collectionView == _collectionView)
	{
		UIDevice *currentDevice = [UIDevice currentDevice];
		minimumInteritemSpacing = currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? 12.0f : 10.0f;
	}
	
	return minimumInteritemSpacing;
}


#pragma mark - FDLongPressMenuDelegate Methods

- (BOOL)shouldDisplayLongPressMenu: (FDLongPressMenu *)longPressMenu 
	atPoint: (CGPoint)point 
	inView: (UIView *)view
{
	BOOL shouldDisplayLongPressMenu = NO;
	
	// Allow the menu to appear if the point is inside the footer view or on an item in the collection view.
	CGPoint footerViewPoint = [_footerView convertPoint: point 
		fromView: view];
	BOOL pointIsInsideFooterView = [_footerView pointInside: footerViewPoint 
		withEvent: nil];
	if (pointIsInsideFooterView == YES)
	{
		shouldDisplayLongPressMenu = YES;
	}
	else
	{
		CGPoint collectionViewPoint = [_collectionView convertPoint: point 
			fromView: view];
		BOOL pointIsInsideCollectionView = [_collectionView pointInside: collectionViewPoint 
			withEvent: nil];
		if (pointIsInsideCollectionView == YES)
		{
			CGPoint pointInCollectionView = [_collectionView convertPoint: point 
				fromView: view];
			NSIndexPath *indexPathOfSelectedItem = [_collectionView indexPathForItemAtPoint: pointInCollectionView];
			
			shouldDisplayLongPressMenu = indexPathOfSelectedItem != nil;
		}
	}
	
	return shouldDisplayLongPressMenu;
}

- (NSArray *)itemsForLongPressMenu: (FDLongPressMenu *)longPressMenu 
	atPoint: (CGPoint)point 
	inView: (UIView *)view
{
	NSArray *longPressMenuItems = nil;
		
	// Generate the menu items if the point is inside the footer view.
	CGPoint footerViewPoint = [_footerView convertPoint: point 
		fromView: view];
	BOOL pointIsInsideFooterView = [_footerView pointInside: footerViewPoint 
		withEvent: nil];	
	if (pointIsInsideFooterView == YES)
	{
		_footerView.backgroundColor = [UIColor orangeColor];
		
		UIImage *bucketImage = [UIImage imageNamed: @"radial_menu_icon_bucket"];
		
		FDLongPressMenuItem *fillRedMenuItem = [[FDLongPressMenuItem alloc] 
			initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_red"] 
				highlightedBackgroundImage: nil 
				iconImage: bucketImage 
				highlightedIconImage: nil];
		fillRedMenuItem.title = FillColour_Red;
		
		FDLongPressMenuItem *fillGreenMenuItem = [[FDLongPressMenuItem alloc] 
			initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_green"] 
				highlightedBackgroundImage: nil 
				iconImage: bucketImage 
				highlightedIconImage: nil];
		fillGreenMenuItem.title = FillColour_Green;
		
		FDLongPressMenuItem *fillBlueMenuItem = [[FDLongPressMenuItem alloc] 
			initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_blue"] 
				highlightedBackgroundImage: nil 
				iconImage: bucketImage 
				highlightedIconImage: nil];
		fillBlueMenuItem.title = FillColour_Blue;
		
		FDLongPressMenuItem *blackMenuItem = [[FDLongPressMenuItem alloc] 
			initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_black"] 
				highlightedBackgroundImage: nil 
				iconImage: bucketImage 
				highlightedIconImage: nil];
		blackMenuItem.title = FillColour_Black;
		
		longPressMenuItems = @ [ fillRedMenuItem, fillGreenMenuItem, fillBlueMenuItem, blackMenuItem ];
	}
	// Generate the menu items if the point is on a item in the collection view.
	else
	{
		CGPoint collectionViewPoint = [_collectionView convertPoint: point 
			fromView: view];
		BOOL pointIsInsideCollectionView = [_collectionView pointInside: collectionViewPoint 
			withEvent: nil];
		if (pointIsInsideCollectionView == YES)
		{
			CGPoint pointInCollectionView = [_collectionView convertPoint: point 
				fromView: view];
			NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint: pointInCollectionView];
			
			if (indexPath != nil)
			{
				[_collectionView selectItemAtIndexPath: indexPath 
					animated: YES 
					scrollPosition: UICollectionViewScrollPositionNone];
				
				UIImage *bucketImage = [UIImage imageNamed: @"radial_menu_icon_bucket"];
				
				FDLongPressMenuItem *fillRedMenuItem = [[FDLongPressMenuItem alloc] 
					initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_red"] 
						highlightedBackgroundImage: nil 
						iconImage: bucketImage 
						highlightedIconImage: nil];
				fillRedMenuItem.context = indexPath;
				fillRedMenuItem.title = FillColour_Red;
				
				FDLongPressMenuItem *fillGreenMenuItem = [[FDLongPressMenuItem alloc] 
					initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_green"] 
						highlightedBackgroundImage: nil 
						iconImage: bucketImage 
						highlightedIconImage: nil];
				fillGreenMenuItem.context = indexPath;
				fillGreenMenuItem.title = FillColour_Green;
				
				FDLongPressMenuItem *fillBlueMenuItem = [[FDLongPressMenuItem alloc] 
					initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_blue"] 
						highlightedBackgroundImage: nil 
						iconImage: bucketImage 
						highlightedIconImage: nil];
				fillBlueMenuItem.context = indexPath;
				fillBlueMenuItem.title = FillColour_Blue;
				
				FDLongPressMenuItem *blackMenuItem = [[FDLongPressMenuItem alloc] 
					initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_black"] 
						highlightedBackgroundImage: nil 
						iconImage: bucketImage 
						highlightedIconImage: nil];
				blackMenuItem.context = indexPath;
				blackMenuItem.title = FillColour_Black;
				
				FDLongPressMenuItem *orangeMenuItem = [[FDLongPressMenuItem alloc] 
					initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_orange"] 
						highlightedBackgroundImage: nil 
						iconImage: bucketImage 
						highlightedIconImage: nil];
				orangeMenuItem.context = indexPath;
				orangeMenuItem.title = FillColour_Orange;
				
				FDLongPressMenuItem *purpleMenuItem = [[FDLongPressMenuItem alloc] 
					initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_purple"] 
						highlightedBackgroundImage: nil 
						iconImage: bucketImage 
						highlightedIconImage: nil];
				purpleMenuItem.context = indexPath;
				purpleMenuItem.title = FillColour_Purple;
				
				FDLongPressMenuItem *yellowMenuItem = [[FDLongPressMenuItem alloc] 
					initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_yellow"] 
						highlightedBackgroundImage: nil 
						iconImage: bucketImage 
						highlightedIconImage: nil];
				yellowMenuItem.context = indexPath;
				yellowMenuItem.title = FillColour_Yellow;
				
				longPressMenuItems = @ [ fillRedMenuItem, fillGreenMenuItem, fillBlueMenuItem, blackMenuItem, orangeMenuItem, purpleMenuItem, yellowMenuItem ];
			}
		}
	}
	
	return longPressMenuItems;
}

- (void)didCloseLongPressMenu: (FDLongPressMenu *)longPressMenu 
	withSelectedItem: (FDLongPressMenuItem *)longPressMenuItem
{
	NSIndexPath *indexPathOfSelectedItem = [[_collectionView indexPathsForSelectedItems] lastObject];
	[_collectionView deselectItemAtIndexPath: indexPathOfSelectedItem 
		animated: YES];
	
	UIColor *color = nil;
	if ([longPressMenuItem.title isEqualToString: FillColour_Red] == YES)
	{
		color = [UIColor redColor];
	}
	else if ([longPressMenuItem.title isEqualToString: FillColour_Green] == YES)
	{
		color = [UIColor greenColor];
	}
	else if ([longPressMenuItem.title isEqualToString: FillColour_Blue] == YES)
	{
		color = [UIColor blueColor];
	}
	else if ([longPressMenuItem.title isEqualToString: FillColour_Black] == YES)
	{
		color = [UIColor blackColor];
	}
	else if ([longPressMenuItem.title isEqualToString: FillColour_Orange] == YES)
	{
		color = [UIColor colorWithRed: 255.0f / 255.0f 
			green: 138.0f / 255.0f 
			blue: 0.0f / 255.0f 
			alpha: 1.0f];
	}
	else if ([longPressMenuItem.title isEqualToString: FillColour_Purple] == YES)
	{
		color = [UIColor colorWithRed: 138.0f / 255.0f 
			green: 0.0f / 255.0f 
			blue: 255.0f / 255.0f 
			alpha: 1.0f];
	}
	else if ([longPressMenuItem.title isEqualToString: FillColour_Yellow] == YES)
	{
		color = [UIColor colorWithRed: 255.0f / 255.0f 
			green: 240.0f / 255.0f 
			blue: 0.0f / 255.0f 
			alpha: 1.0f];
	}
	
	NSIndexPath *indexPath = longPressMenuItem.context;
	if(indexPath == nil)
	{
		_footerView.backgroundColor = [UIColor lightGrayColor];
		
		if (color != nil)
		{
			_footerViewContent.backgroundColor = color;
		}
	}
	else
	{
		UICollectionViewCell *collectionViewCell = [_collectionView cellForItemAtIndexPath: indexPath];
		collectionViewCell.backgroundColor = color;
	}
}


@end