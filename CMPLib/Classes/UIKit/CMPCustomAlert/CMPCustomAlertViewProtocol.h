//
//  CMPCustomAlertViewProtocol.h
//  CMPCustomAlertViewDemo
//
//  Created by yaowei on 2018/8/28.
//  Copyright © 2018年 yaowei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CMPResultModel;
@class CMPSingleGeneralModel;

typedef enum : NSUInteger {
    CMPAlertPublicFootStyleDefalut,//横排
    CMPAlertPublicFootStyleVertical,//竖排
    CMPAlertPublicFootStyleSegmentation,//横排，按钮之间有间隔10
} CMPAlertPublicFootStyle;

typedef enum : NSUInteger {
    
    CMPAlertPublicBodyStyleDefalut,
    CMPAlertPublicBodyStyleCustom,
    
    
    //CMPDatePicker专用
    CMPAlertStyleShowYearMonthDayHourMinuteSecond,//年月日时分秒
    CMPAlertStyleShowYearMonthDayHourMinute,//年月日时分
    CMPAlertStyleShowYearMonthDay,//年月日
    CMPAlertStyleShowYearMonth,//年月
    CMPAlertStyleShowHourMinuteSecond,//时分秒
    
    //CMPAddressPicker专用
    CMPAlertAddressPickerShowProvince, // 只显示省
    CMPAlertAddressPickerShowCity,// 显示省市
    CMPAlertAddressPickerShowArea,// 显示省市区（默认）

} CMPAlertPublicBodyStyle;

NS_ASSUME_NONNULL_BEGIN

@protocol CMPCustomAlertViewThemeProtocol <NSObject>
@optional

/**
 alert背景图
 
 @return im
 */
- (UIImage *)alertBackgroundView;
/**
 alert背景图的清晰度

 @return 0~1(越小越清晰)
 */
- (CGFloat)alterBackgroundViewArticulation;
/**
alert蒙版背景色

@return color
*/
-(UIColor *)maskViewBackgroundColor;

/**
 alert的背景颜色

 @return color
 */
- (UIColor *)alertBackgroundColor;
/**
 titleView的颜色
 
 @return color
 */
- (UIColor *)alertTitleViewColor;
/**
 取消按钮的颜色
 
 @return color
 */
- (UIColor *)alertCancelColor;
/**
 修改title的字体

 @return string
 */
- (NSString *)alertTitleFontWithName;
/**
 修改title的字号大小
 
 @return string
 */
- (CGFloat )alertTitleFont;
/**
 修改Message的字体
 
 @return string
 */
- (NSString *)alertMessageFontWithName;
/**
 修改title的字号大小
 
 @return string
 */
- (CGFloat )alertMessageFont;
/**
 修改所有按钮颜色
 
 @return color
 */
- (UIColor *)alertAllButtonTitleColor;
/**
修改所有按钮字体

@return font
*/
- (UIFont *)alertAllButtionTitleFont;
/**
修改所有BodyLine颜色

@return color
*/
- (UIColor *)alertAllBodyLineColor;
/**
修改所有n按钮分割线颜色

@return color
*/
- (UIColor *)alertButtonLineColor;

@end

//MARK: --------- CMPCustomAlertViewProtocol(基本接口协议)
@protocol CMPCustomAlertViewProtocol <NSObject>
@required
/**
 默认显示在Windows上
 */
- (void)show;
/**
 配合懒加载，即时即地show的时候，回调

 @param handler 回调
 */
- (void)showWindowWithHandler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler;
/**
 隐藏弹框
 */
- (void)hiddenAlertView;
//config配置信息
@optional
/**
 显示在viewController上
 */
- (void)showOnViewController;
/**
 隐藏bodyview上下的两个分隔线
 */
- (void)hiddenBodyLineView;
/**
 隐藏所有的分隔线
 */
- (void)hiddenAllLineView;

/**
 设置整个弹框的背景颜色

 @param color 颜色
 */
- (void)setAlertViewBackgroundColor:(UIColor *)color;
/**
 设置titleView的背景颜色

 @param color 颜色
 */
- (void)setTitleViewBackColor:(UIColor *)color;
/**
 设置titleView的title颜色

 @param color 颜色
 */
- (void)setTitleViewTitleColor:(UIColor *)color;
/**
 设置message的字体颜色

 @param color 颜色
 */
- (void)setMessageTitleColor:(UIColor *)color;
/**
 设置所有按钮的字体颜色

 @param color 颜色
 */
- (void)setAllButtionTitleColor:(UIColor *)color;
/**
设置所有按钮的字体

@param font 字体
*/
- (void)setAllButtionTitleFont:(UIFont *)font;
/**
设置body分割线颜色

@param color 颜色
*/
- (void)setAllBodyLineColor:(UIColor *)color;
/**
设置按钮分割线颜色

@param color 颜色
*/
- (void)setButtonLineColor:(UIColor *)color;
/**
 设置单个按钮的颜色

 @param color 颜色
 @param index 下标
 */
- (void)setButtionTitleColor:(UIColor *)color index:(NSInteger)index;
/**
 设置单个按钮的字体以及其大小

 @param name 什么字体
 @param size 大小
 @param index 小标
 */
- (void)setButtionTitleFontWithName:(NSString *)name size:(CGFloat)size index:(NSInteger)index;
/**
 设置title的字体以及其大小

 @param name 什么字体(为nil时,即是系统字体)
 @param size 大小
 */
- (void)setTitleFontWithName:(nullable NSString *)name size:(CGFloat)size;
/**
 设置message的字体以及其大小
 
 @param name 什么字体(为nil时,即是系统字体)
 @param size 大小
 */
- (void)setMessageFontWithName:(nullable NSString *)name size:(CGFloat)size;
/**
 设置蒙版的背景图

 @param image 蒙版的背景图（可使用高斯的image）
 */
- (void)setGaussianBlurImage:(UIImage *)image;
/**
 设置蒙版的背景色
 
 @param color 蒙版的背景色
 */
- (void)setMaskViewBackgroundColor:(UIColor *)color;
/**
 统一配置信息

 @param theme 主题
 */
- (void)setTheme:(id<CMPCustomAlertViewThemeProtocol>)theme;


/**
 修改tiele
 
 @param title 提示名称
 */
- (void)resetAlertTitle:(NSString *)title;
@end



//MARK: ------------------ addressPicker 私有的方法 ------------------
@protocol CMPAlertAddressPickerViewProtocol <CMPCustomAlertViewProtocol>
/**
 设置

 @param defalutModel 默认的省市区（具体使用，参考demo）
 */
- (void)setDefalutOnAddressPickerView:(CMPResultModel *)defalutModel;
/**
 设置picker的高度

 @param height 高度
 */
- (void)setPickerHeightOnAddressPickerView:(CGFloat)height;
@end

//MARK: ------------------ addressPicker 私有的方法 ------------------
@protocol CMPAlertSingleGeneralPickerViewProtocol <CMPCustomAlertViewProtocol>
/**
 设置

 @param defalutModel 默认的省市区（具体使用，参考demo）
 */
- (void)setDefalutOnSingleGeneraPickerView:(CMPSingleGeneralModel *)defalutModel;
/**
 设置picker的高度

 @param height 高度
 */
- (void)setPickerHeightOnAddressPickerView:(CGFloat)height;
@end



//MARK: ------------------- datePicker 私有的方法 ------------------
@protocol CMPAlertDatePickerViewProtocol <CMPCustomAlertViewProtocol>
/**
 设置默认选中的时间，该方法针对日期选择模式有效
 
 @param dateString 默认选中的时间
 */
- (void)selectedDateOnDatePickerView:(NSString *)dateString;
/**
 设置picker的高度
 
 @param height 高度
 */
- (void)setPickerHeightOnDatePickerView:(CGFloat)height;

@end

@protocol CMPAlertActionSheetViewProtocol <CMPCustomAlertViewProtocol>
/**
 修改message信息，高度也会跟着适配
 
 @param message 信息
 */
- (void)resetAlertMessage:(NSString *)message;

@end

//MARK: ------------------ alert 私有的方法 ------------------
@protocol CMPAlertAlertViewProtocol <CMPCustomAlertViewProtocol>
/**
 alert背景图(目前对CMPAlert有效)
 
 @param image image
 @param articulation 0~1(越小越清晰)
 */
- (void)setAlertBackgroundView:(UIImage *)image articulation:(CGFloat)articulation;
/**
 自定义bodyview
 
 @param bodyView 需要定义的view
 @param height 该view的高度
 */
- (void)setCustomBodyView:(UIView *)bodyView height:(CGFloat)height;
/**
 是否显示关闭的按妞
 */
- (void)showCloseOnTitleView;
/**
 修改message信息，高度也会跟着适配

 @param message 信息
 */
- (void)resetAlertMessage:(NSString *)message;

@end




@protocol CMPCustomAlertViewDelegate <NSObject>

@optional
/**
 点击view的回调

 @param buttonIndex 点击的下标
 @param value 标题名称
 */
- (void)didClickAlertView:(NSInteger)buttonIndex value:(id)value;
@end

NS_ASSUME_NONNULL_END


