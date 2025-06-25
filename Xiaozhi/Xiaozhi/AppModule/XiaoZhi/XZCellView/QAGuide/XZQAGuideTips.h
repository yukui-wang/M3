//
//  XZQAGuideTips.h
//  M3
//
//  Created by wujiansheng on 2018/11/19.
//

#import <CMPLib/CMPObject.h>

@interface XZQAGuideTips : CMPObject
@property(nonatomic, copy)NSString *tipsSetName;
@property(nonatomic, retain)NSArray *tips;
- (id)initWithResult:(NSDictionary *)result;
- (BOOL)showMore;
@end
