//
//  MegLiveV5DetectManager.h
//  MegLiveV5Detect
//
//  Created by MegviiDev on 2021/10/15.
//

#import <UIKit/UIKit.h>
#if __has_include(<MegLiveV5Detect/MegLiveV5DetectItem.h>)
#import <MegLiveV5Detect/MegLiveV5DetectItem.h>
#else
#import "MegLiveV5DetectItem.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MegLiveV5DetectManager : NSObject

/**
 开启FaceID活体检测
 
 @param bizTokenStr   设置FaceID活体检测的启动配置
 @param configItem    设置FaceID活体检测的自定义配置
 @param extraDict     预留参数，当前为nil
 @param startBlock    活体检测初始化完成block
 @param detectVC      开启活体检测的VC页面，一般为当前ViewController
 @param endBlock      活体检测结束时block
 */
+ (void)megFaceIDLiveDetectManagerWithBizToken:(NSString *__nonnull)bizTokenStr
                                    configInfo:(MegLiveV5DetectInitConfigItem *__nullable)configItem
                                     extraData:(NSDictionary *__nullable)extraDict
                                 startCallBack:(MegLiveV5StartDetectBlock)startBlock
                                      detectVC:(UIViewController *)detectVC
                                   endCallBack:(MegLiveV5EndDetectBlock)endBlock
                               dismissCallBack:(MegLiveV5DismissBlock)dismissBlock;

/**
 获取活体检测过程中的日志信息。加密数据。
 
 @return 加密后的日志信息
 */
+ (NSData *)queryMGFaceIDLiveDetectLogInfo;

/**
 解密活体检测过程中的视频和图片文件。加密数据，需要提供key进行解密。
 @param filePath   存储加密文件的路径
 @param encodeStr  用于解密的key。
 @return 解密后的原始数据
 */
+ (NSDictionary *)encodeMGFaceIDLiveDetectFileWithFilePath:(NSString *)filePath encodeKey:(NSString *)encodeStr;

/**
 重置FaceID请求队列。
 如果调用`+megFaceIDLiveDetectManagerWithBizToken`时一直提示`MegLiveV5DetectErrorTypeRequestFrequently`错误，但并没有频繁调用开启FaceID活体检测方法，请使用该方法重置FaceID请求队列。
 */
+ (void)resetFaceIDFrequentlyRequest;

/**
 获取 SDK 版本号信息
 
 @return SDK 版本号
 */
+ (NSString *_Nonnull)getSDKVersion;

/**
 获取 SDK 构建信息
 
 @return SDK 构建号
 */
+ (NSString *_Nonnull)getSDKBuild;

@end

NS_ASSUME_NONNULL_END
