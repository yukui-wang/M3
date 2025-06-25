//
//  CMPMsgFilterResult.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/4/13.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CMPMsgFilterLevel) {
    CMPMsgFilterLevelReplace,//屏蔽，***替换
    CMPMsgFilterLevelIntercept,//拦截，不发送
};

@interface CMPMsgFilter : CMPObject

@property (nonatomic,assign) CMPMsgFilterLevel level;
@property (nonatomic,copy) NSString * matchVal;
@property (nonatomic,copy) NSString * replaceVal;

@end

@interface CMPMsgFilterResult : CMPObject

@property (nonatomic,strong) CMPMsgFilter * filter;
@property (nonatomic,copy) NSString * ori;
@property (nonatomic,copy) NSString * rslt;

@end

NS_ASSUME_NONNULL_END
