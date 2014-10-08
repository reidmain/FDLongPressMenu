@import UIKit;
#import "FDLongPressMenuItem.h"
#import "FDLongPressMenuDelegate.h"
#import "UIView+LongPressMenu.h"


#pragma mark Type Definitions

typedef void (^FDLongPressMenuHideCompletionBlock)(void);


#pragma mark - Class Interface

@interface FDLongPressMenu : NSObject<
	UIGestureRecognizerDelegate>


#pragma mark - Properties

@property (nonatomic, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;


#pragma mark - Constructors

- (id)initWithDelegate: (id<FDLongPressMenuDelegate>)delegate;


#pragma mark - Instance Methods

// These methods must be implemented by any subclass of FDLongPressMenu
- (void)displayLongPressMenuItems: (NSArray *)longPressMenuItems 
	atPoint: (CGPoint)point 
	inView: (UIView *)view;
- (FDLongPressMenuItem *)updateLongPressMenuItems: (NSArray *)longPressMenuItems 
	atPoint: (CGPoint)point 
	inView: (UIView *)view;
- (void)hideLongPressMenuItems: (NSArray *)longPressMenuItems 
	completionBlock: (FDLongPressMenuHideCompletionBlock)completionBlock;


@end