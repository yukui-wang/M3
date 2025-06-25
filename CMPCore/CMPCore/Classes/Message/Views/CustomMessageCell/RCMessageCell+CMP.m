//
//  RCMessageCell+CMP.m
//  M3
//
//  Created by Kaku Songu on 5/12/21.
//

#import "RCMessageCell+CMP.h"
#import <CMPLib/SOSwizzle.h>
#import <objc/runtime.h>
#import <CMPLib/NSObject+Thread.h>

static char kRCMessageCellSetSenderInfoKey;

@implementation RCMessageCell (CMP)


-(void)setServerSenderInfo:(NSDictionary *)serverSenderInfo
{
    objc_setAssociatedObject(self, &kRCMessageCellSetSenderInfoKey, serverSenderInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self _customAct];
}

-(NSDictionary *)serverSenderInfo
{
    return objc_getAssociatedObject(self, &kRCMessageCellSetSenderInfoKey);
}

+ (void)load {
//    SOSwizzleInstanceMethod([self class], @selector(setDataModel:), @selector(cmp_setDataModel:));
    SOSwizzleInstanceMethod([self class], @selector(updateUserInfoUI:), @selector(cmp_updateUserInfoUI:));
}

//- (void)cmp_setDataModel:(RCMessageModel *)model
//{
//    [self cmp_setDataModel:model];
//
//    [self _customAct];
//}

- (void)cmp_updateUserInfoUI:(RCUserInfo *)userInfo
{
    [self cmp_updateUserInfoUI:userInfo];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _customAct];
    });
}


-(void)_customAct
{
    NSDictionary *aDic = self.serverSenderInfo;
    if (aDic) {
        NSString *postName = aDic[@"postName"];
        [self _nickeNameLabelAppendSomething:postName];
    }
}


-(void)_nickeNameLabelAppendSomething:(NSString *)something
{
    if (something) {
        [self dispatchAsyncToMain:^{
            NSString *nickStr = @"";
            if (self.model.userInfo) {
                nickStr = self.model.userInfo.name;
            }
            NSString *somStr = something;
            if (nickStr.length>0) {
                if (nickStr.length>10 && somStr.length) {
                    nickStr = [nickStr substringToIndex:10];
                }
                if (somStr.length>12) {
                    somStr = [somStr substringToIndex:12];
                }
                self.nicknameLabel.text = [NSString stringWithFormat:@"%@ %@",nickStr,somStr];
            }else{
                self.nicknameLabel.text = somStr;
            }
        }];
    }
}

@end
