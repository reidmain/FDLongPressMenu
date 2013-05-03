#pragma mark Class Interface

@interface FDLongPressMenuItem : NSObject


#pragma mark - Properties

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id context;
@property (nonatomic, readonly) UIView *view;


#pragma mark - Constructors

- (id)initWithBackgroundImage: (UIImage *)backgroundImage 
	highlightedBackgroundImage: (UIImage *)highlightedBackgroundImage 
	iconImage:	(UIImage *)iconImage 
	highlightedIconImage: (UIImage *)highlightedIconImage;


@end