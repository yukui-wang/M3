//
//  SyFileManager.h
//  M1Core
//
//  Created by admin on 12-10-19.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//
//
#import <Foundation/Foundation.h>
@interface SyFileManager : NSObject {
    NSInteger _type;//清除缓存时，模态窗口显示方式 1 ＝ loadingView 2 = 顶部提示条
    long long _maxSize;
}
@property(nonatomic,retain)UIViewController *viewController;
+ (SyFileManager *)defaultManager;

+ (NSString *)appendCurrentHomeDirectory:(NSString *)aPath;
+ (NSString *)homeDirectory;
+ (NSString *)createFullPath:(NSString *)aPath;
+ (NSString *)fileTempPath;
+ (NSString *)downloadFilePath;
+ (NSString *)uploadTempFilePath;
+ (NSString *)downloadFileTempPathWithFileName:(NSString *)aFileName;
+ (NSString *)fileTempPathWithType:(NSInteger)aType ext:(NSString *)ext;
+ (NSString *)fileTempPathWithType:(NSInteger)aType ext:(NSString *)ext index:(NSInteger)index;

+ (NSString *)menuSettingPathWithAccountID:(long long)aAccountID userID:(long long)aUserID;
+ (NSString *)menuSettingDeleteFlagPathWithAccountID:(long long)aAccountID userID:(long long)aUserID;//删除
//快截菜单
+(NSString *)quicFunctionMenuAddedWidhAccountID:(long long)aAccountID userID:(long long)aUserID;
+ (NSString *)promptFlagsFilePathWithAccountID:(long long)aAccountID userID:(long long)aUserID;
+ (NSString *)faceImagePathWithWithUniqueId:(NSString *)aUniqueId serverIdentifier:(NSString *)aServerId;
+ (void)removeFileTempPath;
- (void)deleteCacheFilesWithViewController:(UIViewController*)acontroller type:(NSInteger)type;//删除缓存 type:清除缓存时，模态窗口显示方式 1 ＝ loadingView 2 = 顶部提示条
- (long long)sizeOfCacheFiles;//删除缓存的大小

+ (NSString *)uniqueFileNameWithSuffix:(NSString *)aSuffix;
+ (NSString *)localFilePath; // 本地文件路径
+ (NSString *)cmpIconPath; // cmp icon存放路径

+ (void)removeFileWithPath:(NSString *)aPath;
//业务管理添加到菜单
+ (NSString *)menuSettingBGaddFlagPathWithAccountID:(long long)aAccountID userID:(long long)aUserID;//已添加Bg
+ (NSArray *)arrayForBGInMenuViewWithAccountID:(long long)aAccountID userID:(long long)aUserID;
+ (NSDictionary *)dictionaryForBGInMenuViewWithAccountID:(long long)aAccountID userID:(long long)aUserID;
+ (void)addBGToMenuViewWithMenuIDArray:(NSArray *)menuIDArray AccountID:(long long)aAccountID userID:(long long)aUserID;
+ (void)removeBGFormMenuViewWithMenuID:(NSString *)menuID AccountID:(long long)aAccountID userID:(long long)aUserID;

//cmp添加到菜单
+ (NSString *)menuSettingCMPaddFlagPathWithAccountID:(long long)aAccountID userID:(long long)aUserID;//已添加Bg
+ (NSArray *)arrayForCMPInMenuViewWithAccountID:(long long)aAccountID userID:(long long)aUserID;
+ (NSDictionary *)dictionaryForCMPInMenuViewWithAccountID:(long long)aAccountID userID:(long long)aUserID;
+ (void)addCMPToMenuViewWithMenuIDArray:(NSArray *)menuIDArray AccountID:(long long)aAccountID userID:(long long)aUserID;
+ (void)removeCMPFormMenuViewWithMenuID:(NSString *)menuID AccountID:(long long)aAccountID userID:(long long)aUserID;

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end
