//
//  XZSendIMMsgIntent.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/27.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CMPLib/CMPOfflineContactMember.h>
#import "XZOptionMemberParam.h"

@protocol XZSendIMMsgIntentDelegate <NSObject>
- (void)intentSendIMMsg:(CMPOfflineContactMember *)member content:(NSString *)content;
- (void)intentSendIMMsgClarifyMembers:(XZOptionMemberParam *)param;
- (void)intentSendIMMsgClarifyText:(NSString *)text;
- (void)intentSendIMMsgShowMember:(BOOL)show;
@end

@interface XZSendIMMsgIntent : NSObject
@property(nonatomic, strong)CMPOfflineContactMember *member;
@property(nonatomic, strong)NSString *content;
@property(nonatomic, assign)id<XZSendIMMsgIntentDelegate> delegate;

- (void)handleMember:(CMPOfflineContactMember *)member
          memberName:(NSString *)name
             content:(NSString *)content;
- (BOOL)useUnit;//意图完成
- (void)handleText:(NSString *)text;
@end

