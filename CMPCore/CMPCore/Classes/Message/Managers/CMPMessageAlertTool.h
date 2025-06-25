//
//  CMPMessageAlertManager.h
//  M3
//
//  Created by CRMO on 2017/12/23.
//

#import <CMPLib/CMPObject.h>
#import <CMPLib/JCAlertController.h>

//typedef NS_ENUM(NSUInteger, CMPMessageAlertContentType) {
//    CMPMessageAlertContentText = 0, // 纯文本
//    CMPMessageAlertContentImage, // 纯图片
//    CMPMessageAlertContentMix, // 图文
//};

typedef NS_ENUM(NSUInteger, CMPMessageAlertButtonType) {
    CMPMessageAlertButtonReadOnly, // 只有我知道了
    CMPMessageAlertButtonCanThrough, // 可以穿透查看
};

@interface CMPMessageAlertTool : CMPObject

// 展示纯文本弹窗
- (void)showAlertWithContent:(NSString *)content buttonType:(CMPMessageAlertButtonType)type;

@end
