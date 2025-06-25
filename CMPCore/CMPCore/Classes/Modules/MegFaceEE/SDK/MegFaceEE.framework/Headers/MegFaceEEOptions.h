//
//  MegFaceEEVerificationOptions.h
//  MegFaceEE
//
//  Created by Megvii on 2023/1/30.
//

#import <Foundation/Foundation.h>
#import <MegFaceEE/MegFaceEEConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegFaceEEOptions : NSObject

@property (nonatomic, assign) BOOL needConfirmPage;
@property (nonatomic, assign) BOOL needSuccessPage;
@property (nonatomic, assign) BOOL needFailedPage;
@property (nonatomic, assign) MegFaceEECredentialType credentialType;
@property (nonatomic, assign) BOOL showAuthenticationManagementButton;
//确认页认证信息
@property (nonatomic, strong) NSString *confirmPageMessage;
//只对通知认证且needConfirmPage为YES时起作用，认证确认页为卡片的样式
@property (nonatomic, assign) BOOL isNotificationConfirmCard;

@end

NS_ASSUME_NONNULL_END
