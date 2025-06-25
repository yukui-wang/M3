//
//  XZIntentStep.m
//  M3
//
//  Created by wujiansheng on 2019/3/7.
//

#import "XZIntentStep.h"
#import "XZCore.h"

@interface XZIntentStep ()

@end

@implementation XZIntentStep

- (void)dealloc {
    self.key = nil;
    self.type = nil;
    self.slot = nil;
    self.guideWord = nil;    
    self.nextStep = nil;
    self.parentStep = nil;

}

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        self.key = [SPTools stringValue:dic forKey:@"key"];
        self.type = [SPTools stringValue:dic forKey:@"type"];
        self.slot = [SPTools stringValue:dic forKey:@"slot"];
        self.guideWord = [SPTools stringValue:dic forKey:@"guideWord"];
        self.required = [SPTools boolValue:dic forKey:@"required"];
        self.relatePreIntent = [SPTools boolValue:dic forKey:@"relatePreIntent"];
        self.displayName = [SPTools stringValue:dic forKey:@"displayName"];
        if ([dic.allKeys containsObject:@"limit"]) {
            self.limit = [SPTools integerValue:dic forKey:@"limit"];
        }
        self.pairKey = [SPTools stringValue:dic forKey:@"pairKey"];
        self.currentLoc = [SPTools stringValue:dic forKey:@"currentLoc"];
        if ([[XZCore sharedInstance] isM3ServerIsLater8]) {
            self.native = YES;//默认走本地了
        }
        //兼容下 因为native为特征词，被转换成_native,新增nativeable代替native
        BOOL native = [SPTools boolValue:dic forKey:@"native"];
        BOOL nativeable = [SPTools boolValue:dic forKey:@"nativeable"];
        self.native = native||nativeable;
    }
    return self;
}

- (void)handleNativeResult:(NSString *)result complete:(void(^)(void))complete {
    
}

- (void)handleUnitResult:(NSArray *)result complete:(void(^)(void))complete {
    
}

- (void)handleMembers:(NSArray *)array {
    
}

- (void)handlePairValue:(NSString *)pairVaule {
    
}

- (long long)numberValue {
    return 0;
}

- (CMPOfflineContactMember *)currentUser{
    CMPOfflineContactMember *user = [[CMPOfflineContactMember alloc] init];
    user.name = [XZCore userName];
    user.orgID = [XZCore userID];
    user.postName = [XZCore postName];
    user.accountId = [XZCore accountID];
    return user;
}

- (NSString *)stringValue {
    id normalizedValue = self.normalizedValue;
    if ([normalizedValue isKindOfClass:[NSString class]]) {
        return normalizedValue;
    }
    else if (![normalizedValue isKindOfClass:[NSNull class]]) {
        return [normalizedValue JSONRepresentation];
    }
    return @"";
}

- (id)normalizedValue {
    return @"";
}
- (id)normalizeDefauleValue {
    return nil;
}

- (BOOL)canNext {
    return NO;
}

- (BOOL)canNextForCreate {
    return NO;
}

- (BOOL)isMultiSelectMember {
    return NO;
}

- (BOOL)isChooseMember {
    return NO;
}

- (BOOL)isLongText {
    return NO;
}

- (BOOL)useUnit {
    return !self.native;
}
- (void)handleOptionValue:(NSDictionary *)params {
    
}
+(XZIntentStep *)intentStepWithDic:(NSDictionary *)dic {
   NSString *type = [SPTools stringValue:dic forKey:@"type"];
    NSString *className = @"XZIntentTextStep";
    if ([type isEqualToString:kIntentStepType_LongText]) {
        className = @"XZIntentLongTextStep";
    }
    else if ([type isEqualToString:kIntentStepType_Enum]) {
        className = @"XZIntentEnumStep";
    }
    else if ([type isEqualToString:kIntentStepType_Number]) {
        className = @"XZIntentNumberStep";
    }
    else if ([type isEqualToString:kIntentStepType_Date]) {
        className = @"XZIntentDateStep";
    }
    else if ([type isEqualToString:kIntentStepType_Datetime]) {
        className = @"XZIntentDateTimeStep";
    }
    else if ([type isEqualToString:kIntentStepType_Timestamp]) {
        className = @"XZIntentTimestampStep";
    }
    else if ([type isEqualToString:kIntentStepType_Member]) {
        className = @"XZIntentMemberStep";
    }
    else if ([type isEqualToString:kIntentStepType_Multimember]) {
        className = @"XZIntentMultiMemberStep";
    }
    else if ([type isEqualToString:kIntentStepType_MemberId]) {
        className = @"XZIntentMemberIdStep";
    }
    else if ([type isEqualToString:kIntentStepType_MultimemberId]) {
        className = @"XZIntentMultiMemberIdStep";
    }
    else if ([type isEqualToString:kIntentStepType_ObtainOption]) {
        className = @"XZObtainOptionStep";
    }
   
    XZIntentStep *intent = [[NSClassFromString(className) alloc] initWithDic:dic];
    return intent;
}

- (void)handleNormalizedValue:(id)value {
    
}


@end


