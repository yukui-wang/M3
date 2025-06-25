//
//  CMPImpAlertManager.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/8/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPImpAlertManager : NSObject
+(instancetype)shareInstance;
-(void)begin;
+(void)showMsgWithDatas:(NSArray *)datas;
@end

NS_ASSUME_NONNULL_END
