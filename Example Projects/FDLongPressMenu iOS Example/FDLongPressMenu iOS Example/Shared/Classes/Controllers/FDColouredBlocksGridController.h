#import <FDLongPressMenu/FDLongPressMenu.h>


#pragma mark Class Interface

@interface FDColouredBlocksGridController : UIViewController<
	UICollectionViewDataSource, 
	UICollectionViewDelegateFlowLayout, 
	FDLongPressMenuDelegate>


#pragma mark - Constructors

- (id)initWithDefaultNibName;


@end