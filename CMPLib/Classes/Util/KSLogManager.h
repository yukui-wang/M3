//
//  KSLogManager.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2021/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSLogManager : NSObject

@property (nonatomic,copy) NSString *logPath;
@property (nonatomic,assign) NSInteger locationTag;

+(KSLogManager *)shareManager;
-(void)setDev:(BOOL)isDev;
-(BOOL)isDev;
-(void)shareLogInView:(UIView *)inView;
-(void)redirectNSlogToDocumentFolderWithIde:(NSString *)ideStr;
-(BOOL)addObjLocalPath:(NSString *)localPath newNameWithType:(NSString *)name;
-(void)addActBeforeShareBlk:(void(^)(void))blk;
+(BOOL)registerOnView:(UIView *)aView delegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
