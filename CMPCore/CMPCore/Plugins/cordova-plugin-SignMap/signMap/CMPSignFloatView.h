//
//  CMPSignFloatView.h
//  CMPCore
//
//  Created by wujiansheng on 16/7/28.
//
//

#import <CMPLib/CMPBaseView.h>

@interface CMPSignFloatView : CMPBaseView

@property(nonatomic, readonly)UIButton *cityButton;//城市
@property(nonatomic, retain)UITextField *adressField;

- (void)layoutProvince:(NSString *)province  city:(NSString *)city address:(NSString *)address;

@end
