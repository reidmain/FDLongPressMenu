#import "FDColouredBlocksGridController.h"
#import <FDLongPressMenu/FDRadialLongPressMenu.h>
#import "FDCollectionViewCell.h"


#pragma mark Constants

static NSString * const CellReuseIdentifier = @"CellIdentifier";


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
		
		UIImage *backgroundImage = [UIImage imageNamed: @"radial_menu_background"];
		UIImage *highlightedBackgroundImage = [UIImage imageNamed: @"radial_menu_background_highlighted"];
		
		FDLongPressMenuItem *fillRedMenuItem = [[FDLongPressMenuItem alloc] 
			initWithBackgroundImage: backgroundImage 
				highlightedBackgroundImage: highlightedBackgroundImage 
				iconImage: [UIImage imageNamed: @"radial_menu_icon_fill_red"] 
				highlightedIconImage: nil];
		fillRedMenuItem.title = @"Red";
		
		FDLongPressMenuItem *fillGreenMenuItem = [[FDLongPressMenuItem alloc] 
			initWithBackgroundImage: backgroundImage 
				highlightedBackgroundImage: highlightedBackgroundImage 
				iconImage: [UIImage imageNamed: @"radial_menu_icon_fill_green"] 
				highlightedIconImage: nil];
		fillGreenMenuItem.title = @"Green";
		
		FDLongPressMenuItem *fillBlueMenuItem = [[FDLongPressMenuItem alloc] 
			initWithBackgroundImage: backgroundImage 
				highlightedBackgroundImage: highlightedBackgroundImage 
				iconImage: [UIImage imageNamed: @"radial_menu_icon_fill_blue"] 
				highlightedIconImage: nil];
		fillBlueMenuItem.title = @"Blue";
		
		FDLongPressMenuItem *eraserMenuItem = [[FDLongPressMenuItem alloc] 
			initWithBackgroundImage: backgroundImage 
				highlightedBackgroundImage: highlightedBackgroundImage 
				iconImage: [UIImage imageNamed: @"radial_menu_icon_eraser"] 
				highlightedIconImage: nil];
		eraserMenuItem.title = @"Eraser";
		
		longPressMenuItems = @ [ fillRedMenuItem, fillGreenMenuItem, fillBlueMenuItem, eraserMenuItem ];
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
				
				UIImage *backgroundImage = [UIImage imageNamed: @"radial_menu_background"];
				UIImage *highlightedBackgroundImage = [UIImage imageNamed: @"radial_menu_background_highlighted"];
				
				FDLongPressMenuItem *fillRedMenuItem = [[FDLongPressMenuItem alloc] 
					initWithBackgroundImage: backgroundImage 
						highlightedBackgroundImage: highlightedBackgroundImage 
						iconImage: [UIImage imageNamed: @"radial_menu_icon_fill_red"] 
						highlightedIconImage: nil];
				fillRedMenuItem.context = indexPath;
				fillRedMenuItem.title = @"Red";
				
				FDLongPressMenuItem *fillGreenMenuItem = [[FDLongPressMenuItem alloc] 
					initWithBackgroundImage: backgroundImage 
						highlightedBackgroundImage: highlightedBackgroundImage 
						iconImage: [UIImage imageNamed: @"radial_menu_icon_fill_green"] 
						highlightedIconImage: nil];
				fillGreenMenuItem.context = indexPath;
				fillGreenMenuItem.title = @"Green";
				
				FDLongPressMenuItem *fillBlueMenuItem = [[FDLongPressMenuItem alloc] 
					initWithBackgroundImage: backgroundImage 
						highlightedBackgroundImage: highlightedBackgroundImage 
						iconImage: [UIImage imageNamed: @"radial_menu_icon_fill_blue"] 
						highlightedIconImage: nil];
				fillBlueMenuItem.context = indexPath;
				fillBlueMenuItem.title = @"Blue";
				
				longPressMenuItems = @ [ fillRedMenuItem, fillGreenMenuItem, fillBlueMenuItem ];
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
	
	NSIndexPath *indexPath = longPressMenuItem.context;
	if(indexPath == nil)
	{
		_footerView.backgroundColor = [UIColor whiteColor];
		if ([longPressMenuItem.title isEqualToString: @"Red"] == YES)
		{
			_footerViewContent.backgroundColor = [UIColor redColor];
		}
		else if ([longPressMenuItem.title isEqualToString: @"Green"] == YES)
		{
			_footerViewContent.backgroundColor = [UIColor greenColor];
		}
		else if ([longPressMenuItem.title isEqualToString: @"Blue"] == YES)
		{
			_footerViewContent.backgroundColor = [UIColor blueColor];
		}
		else if ([longPressMenuItem.title isEqualToString: @"Eraser"] == YES)
		{
			_footerViewContent.backgroundColor = [UIColor colorWithRed: 0.0f / 255.0f 
				green: 56.0f / 255.0f 
				blue: 118.0f / 255.0f 
				alpha: 1.0f];
		}
	}
	else
	{
		UICollectionViewCell *collectionViewCell = [_collectionView cellForItemAtIndexPath: indexPath];
		if ([longPressMenuItem.title isEqualToString: @"Red"] == YES)
		{
			collectionViewCell.backgroundColor = [UIColor redColor];
		}
		else if ([longPressMenuItem.title isEqualToString: @"Green"] == YES)
		{
			collectionViewCell.backgroundColor = [UIColor greenColor];
		}
		else if ([longPressMenuItem.title isEqualToString: @"Blue"] == YES)
		{
			collectionViewCell.backgroundColor = [UIColor blueColor];
		}
	}
}


@end