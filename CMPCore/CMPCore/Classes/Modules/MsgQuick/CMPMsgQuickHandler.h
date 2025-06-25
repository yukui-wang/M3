//
//  CMPMsgQuickHandler.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/1/9.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPMsgQuickHandler : CMPObject
@property (nonatomic,assign) NSInteger enterRoute;//用于记录登录入口，1.自动登录没有物理识别 2.离线登录，不弹出，其他登录都弹出，默认9,0不弹出，大于0弹出
+(void)updateActWithIfHandled:(BOOL)ifHandled;
+(void)updateActWithIfNeverTip:(BOOL)ifNeverTip;
+(instancetype)shareInstance;
-(void)begin;
@end

NS_ASSUME_NONNULL_END
