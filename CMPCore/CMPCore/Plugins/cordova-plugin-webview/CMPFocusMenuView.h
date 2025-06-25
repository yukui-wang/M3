//
//  CMPFocusMenuView.h
//  M3
//
//  Created by Shoujian Rao on 2024/1/19.
//

#import <UIKit/UIKit.h>
#import "CMPFocusMenuItem.h"

@interface CMPFocusMenuView : UIView

- (void)showFocusImage:(UIImage *)screenShotImage inPosition:(CGRect)screenRect topGroup:(NSArray *)topGroup didSelectItem:(void(^)(CMPFocusMenuItem *))didSelectItemBlock;
- (void)showFocusImage:(UIImage *)focusImage screenImage:(UIImage *)screenShotImage inPosition:(CGRect)screenRect topGroup:(NSArray *)topGroup didSelectItem:(void(^)(CMPFocusMenuItem *))didSelectItemBlock;
@end

