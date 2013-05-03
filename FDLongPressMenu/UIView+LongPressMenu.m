#import "UIView+LongPressMenu.h"
#import <objc/runtime.h>


#pragma mark Constants

static const void *const UIView_LongPressMenuKey = &UIView_LongPressMenuKey;


#pragma mark - Class Definition

@implementation UIView (LongPressMenu)


#pragma mark - Public Methods

- (void)addLongPressMenu: (FDLongPressMenu *)longPressMenu
{
	if (objc_getAssociatedObject(self, UIView_LongPressMenuKey) != nil)
	{
		// TODO: Throw error/exception because this view already has a long press menu attached to it.
	}
	else
	{
		[self addGestureRecognizer: longPressMenu.longPressGestureRecognizer];
		
		objc_setAssociatedObject(self, UIView_LongPressMenuKey, longPressMenu, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
}

- (void)removeLongPressMenu
{
	objc_setAssociatedObject(self, UIView_LongPressMenuKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end