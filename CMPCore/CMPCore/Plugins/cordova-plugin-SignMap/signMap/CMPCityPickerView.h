//
//  CMPCityPickerView.h
//  CMPCore
//
//  Created by wujiansheng on 16/8/1.
//
//

#import <CMPLib/CMPBaseView.h>

@protocol CMPCityPickerViewDelegate;
@interface CMPCityPickerView : CMPBaseView

@property (nonatomic, retain) UIPickerView *cityPickerView;//悬浮视图
@property (nonatomic, assign)id<CMPCityPickerViewDelegate>delegate;
- (void)show;
@end

@protocol CMPCityPickerViewDelegate <NSObject>

- (void)cityPickerViewDidCancel;
- (void)cityPickerViewDidSelectCityWithInfo:(NSDictionary *)infoDict;

@end
