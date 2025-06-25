//
//  CMPOcrTipTool.h
//  CMPCore
//
//  Created by Shoujian Rao on 2021/12/23.
//

#import <CMPLib/CMPObject.h>


@interface CMPOcrTipTool : CMPObject

//包列表
- (void)showNoDataView:(BOOL)show toView:(UIView *)view;

//识别页面
- (void)showNoCheckDataView:(BOOL)show toView:(UIView *)view;

//我的历史
- (void)showNoMoudleDataView:(BOOL)show toView:(UIView *)view;

//无可关联发票
- (void)showNoAssociateDataView:(BOOL)show toView:(UIView *)view;

//首页没有moudle数据
- (void)showNoMoudleMainPage:(BOOL)show toView:(UIView *)view;
@end

