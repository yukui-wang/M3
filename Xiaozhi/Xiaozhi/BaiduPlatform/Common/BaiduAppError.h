//
//  BaiduAppError.h
//  M3
//
//  Created by wujiansheng on 2019/2/27.
//

#import <Foundation/Foundation.h>

@interface BaiduAppError : NSObject
@property(nonatomic, assign) NSInteger code;
@property(nonatomic, copy) NSString *message;
- (id)initWithError:(NSDictionary *)error;
@end
