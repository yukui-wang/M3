//
//  XZModelButton.h
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//小致模块按钮

#import <UIKit/UIKit.h>
#import <CMPLib/CMPConstant.h>
@interface XZModelButton : UIButton
@property(nonatomic, retain)NSObject *info;
- (CGFloat)memberWidth;
- (CGFloat)textWWidth;
@end
