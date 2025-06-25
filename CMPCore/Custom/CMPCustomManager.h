//
//  CMPCustomManager.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/12/12.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface CMPCustomModel : NSObject

@property (nonatomic,copy) NSString *bundleIdWithPrefix;
@property (nonatomic,copy) NSString *appGroupId;
@property (nonatomic,copy) NSString *callExtensionBundleId;
@property (nonatomic,copy) NSString *shareExtensionBundleId;
@property (nonatomic,copy) NSString *bundleVersion;
@property (nonatomic,copy) NSString *defaultServer;
@property (nonatomic,copy) NSString *defaultServerNote;
@property (nonatomic,copy) NSString *baiduApiKey;
@property (nonatomic,copy) NSString *gaodeApiKey;
//@property (nonatomic,copy) NSString *mobAppKey;
//@property (nonatomic,copy) NSString *mobAppSecret;
@property (nonatomic,copy) NSString *qqAppId;
@property (nonatomic,copy) NSString *qqAppKey;
@property (nonatomic,copy) NSString *qqUniversalLink;
@property (nonatomic,copy) NSString *wcAppId;
@property (nonatomic,copy) NSString *wcAppKey;
@property (nonatomic,copy) NSString *wcUniversalLink;
@property (nonatomic,copy) NSString *dingAppId;
@property (nonatomic,copy) NSString *leboAppId;
@property (nonatomic,copy) NSString *leboAppKey;
@property (nonatomic,assign) BOOL hasPrivacy;
@property (nonatomic,copy) NSString *privacyPath;

@end

@interface CMPCustomManager : NSObject

@property (nonatomic,strong,readonly) CMPCustomModel *cusModel;
//@property (nonatomic,strong,readonly) NSDictionary *cusDic;

+ (instancetype)sharedInstance;
+(NSString *)matchValueFromOri:(NSString *)ori andCus:(NSString *)cus;
-(void)checkVersionFrom:(NSInteger)from;

@end

NS_ASSUME_NONNULL_END
