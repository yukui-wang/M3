//
//  CMPTopScreenManager.h
//  M3
//
//  Created by Shoujian Rao on 2023/12/26.
//

#import <Foundation/Foundation.h>
#import "CMPTopScreenDB.h"
#import <CMPLib/CMPAppListModel.h>
#define kNotificationTopScreenRefreshData_Common @"kNotificationTopScreenRefreshData_Common"
#define kNotificationTopScreenRefreshData_SecondFloor @"kNotificationTopScreenRefreshData_SecondFloor"
typedef void(^CompletionBlock)(id respData,NSError *error);
NS_ASSUME_NONNULL_BEGIN

@interface CMPTopScreenManager : NSObject

//本地常用
- (void)loadAppClickByParam:(NSDictionary *)param;
- (void)pushPageClickByParam:(NSDictionary *)param;
- (void)savePulginWithId:(NSString *)iid appName:(NSString *)appName iconUrl:(NSString *)iconUrl param:(NSDictionary *)param openType:(CMPTopScreenOpenType)openType;
- (NSArray *)getTopData;
- (BOOL)delAllTopData;
- (void)jumpPage:(CMPTopScreenModel *)model fromVC:(UIViewController *)fromVC;


- (CMPAppList_2 *)getAppInfoByAppId:(NSString *)appId;
//我的二楼
- (void)checkById:(NSString *)iid completion:(void(^)(BOOL exist,NSError *err))completion;
- (void)topScreenSaveByParam:(NSDictionary *)param completion:(CompletionBlock)completionBlock;
- (void)topScreenDelById:(NSString *)iid completion:(CompletionBlock)completionBlock;
- (void)topScreenGetAllCompletion:(CompletionBlock)completionBlock;

@end
NS_ASSUME_NONNULL_END
