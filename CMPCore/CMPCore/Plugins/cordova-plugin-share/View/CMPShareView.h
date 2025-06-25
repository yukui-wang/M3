//
//  CMPShareView.h
//  M3
//
//  Created by MacBook on 2019/10/24.
//

#import <CMPLib/CMPTopCornerView.h>

@class CMPShareFileModel,CMPFileManagementRecord,CMPPopFromBottomViewController;

NS_ASSUME_NONNULL_BEGIN

@interface CMPShareView : CMPTopCornerView

/// 工厂方法，返回一个此类的对象
/// @param frame frame
/// @param shareFileModel 其他地方调用分享组件时传过来的参数，为空的话就显示默认设置的分享列表
+ (instancetype)shareViewWithFrame:(CGRect)frame shareFileModel:(CMPShareFileModel *)shareFileModel;

/* 是否是默认列表 */
@property (assign, nonatomic) BOOL isDefaultList;

/* 其他地方调用分享组件时传过来的参数，为空的话就显示默认设置的分享列表 */
@property (strong, nonatomic) CMPShareFileModel *shareFileModel;
/* 本地文件分享时要传过来的文件参数 */
@property (strong, nonatomic) CMPFileManagementRecord *mfr;

/* 当前viewController */
@property (weak, nonatomic) CMPPopFromBottomViewController *viewController;
/* pushVC */
@property (weak, nonatomic) UIViewController *pushVC;
/* webview */
@property (weak, nonatomic) UIView *webview;
/* 是否是来自致信 */
@property (assign, nonatomic) BOOL isUc;

-(instancetype)initWithFrame:(CGRect)frame
              ksCommonParams:(NSDictionary *)params
             ksCommonRsltBlk:(void(^)(NSInteger step,NSDictionary *actInfo, NSError *err, __nullable id ext))rsltBlk;

@end

NS_ASSUME_NONNULL_END
