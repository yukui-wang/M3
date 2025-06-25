//
//  CMPTopScreenView.h
//  M3
//
//  Created by Shoujian Rao on 2023/12/28.
//

#import <UIKit/UIKit.h>

@interface CMPTopScreenView : UIView

@property(nonatomic,copy) void(^pushSearchBlock)(void);

- (instancetype)initWithVC:(UIViewController *)vc frame:(CGRect)frame;
- (void)changeMask:(CGFloat)y;
- (void)loadData;
- (void)showMask:(BOOL)show;

- (void)handlePermisson:(BOOL)can;


@end
