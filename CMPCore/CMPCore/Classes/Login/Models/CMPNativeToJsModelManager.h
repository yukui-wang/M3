//
//  CMPNativeToJsModelManager.h
//  M3
//
//  Created by Kaku Songu on 6/21/21.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKWebView.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CMPSyncDataToJsResultComplete,
    CMPSyncDataToJsResultSuccess,
    CMPSyncDataToJsResultError
} CMPSyncDataToJsResult;

@interface CMPNativeToJsModelManager : NSObject

@property (nonatomic,strong) NSMutableArray *runJsModelsArr;

+(CMPNativeToJsModelManager *)shareManager;
-(void)saveJsModelStr:(NSString *)jsStr;
-(void)clearData;
-(void)safeHandleIfForce:(BOOL)force;
-(void)syncInfoToJsWithUrl:(NSString *)url
                   isForce:(BOOL)isForce
                   webview:(WKWebView *)webview
                    result:(void(^)(CMPSyncDataToJsResult state,NSError *err))result;

@end

NS_ASSUME_NONNULL_END
