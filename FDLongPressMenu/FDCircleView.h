#pragma mark Class Interface

@interface FDCircleView : UIView


#pragma mark - Properties

@property (nonatomic, assign) CGFloat startingAngle;
@property (nonatomic, assign) CGFloat endingAngle;
@property (nonatomic, copy) UIColor *fillColor;
@property (nonatomic, copy) UIColor *strokeColor;


@end