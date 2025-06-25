//
//  CMPIntercepter.h
//  M3
//
//  Created by Shoujian Rao on 2023/2/7.
//

#import <Foundation/Foundation.h>

#define kNoInterceptJumpNotification @"kNoInterceptJumpNotification"

@interface CMPIntercepter : NSObject
+ (CMPIntercepter*)sharedInstance;

-(BOOL)isRegister;
- (void)registerClass;
- (void)unregisterClass;

- (BOOL)interceptByUrl:(NSString *)url;
- (BOOL)needIntercept:(NSString *)url;

@end


