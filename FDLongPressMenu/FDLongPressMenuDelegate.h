#pragma mark Forward Declarations

@class FDLongPressMenu;
@class FDLongPressMenuItem;


#pragma mark - Protocol

@protocol FDLongPressMenuDelegate<NSObject>


#pragma mark - Required Methods

@required

- (NSArray *)itemsForLongPressMenu: (FDLongPressMenu *)longPressMenu 
	atPoint: (CGPoint)point 
	inView: (UIView *)view;
- (void)didCloseLongPressMenu: (FDLongPressMenu *)longPressMenu 
	withSelectedItem: (FDLongPressMenuItem *)longPressMenuItem;


#pragma mark - Optional Methods

@optional

- (BOOL)shouldDisplayLongPressMenu: (FDLongPressMenu *)longPressMenu 
	atPoint: (CGPoint)point 
	inView: (UIView *)view;


@end