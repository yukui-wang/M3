//
//  CMPSMSGraphVerView.h
//  M3
//
//  Created by zy on 2022/3/1.
//

#import <UIKit/UIKit.h>
#import <CMPLib/CMPBaseView.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPSMSGraphVerView : CMPBaseView

@property (copy, nonatomic) NSString *phoneNumber;

@property (copy, nonatomic) NSString *imageURL;

@property (copy, nonatomic) void(^cancelBtnClicked)(void);

@property (copy, nonatomic) void(^confirmBtnClicked)(NSString *code);

@property (copy, nonatomic) void(^verifyCodeImgDownloadCallback)(UIImage * _Nullable image,NSError * _Nullable error);

@end

NS_ASSUME_NONNULL_END
