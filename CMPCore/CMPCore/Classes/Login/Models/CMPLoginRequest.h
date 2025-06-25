//
//  CMPLoginRequest.h
//  M3
//
//  Created by youlin on 2020/3/3.
//

#import <CMPLib/CMPDataRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPLoginRequest : CMPDataRequest

- (id)initWithDelegate:(id)deleagte param:(NSString *)aParam host:(NSString *)aHost serverVersion:(NSString *)aVersion serverContextPath:(NSString *)contextPath;
- (id)initWithDelegate:(id)deleagte param:(NSString *)aParam;

@end

NS_ASSUME_NONNULL_END
