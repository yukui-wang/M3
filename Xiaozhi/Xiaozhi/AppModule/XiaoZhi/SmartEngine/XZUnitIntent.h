//
//  XZUnitIntent.h
//  M3
//
//  Created by wujiansheng on 2018/12/27.
//

#import <CMPLib/CMPObject.h>


@interface XZUnitIntent : CMPObject
@property(nonatomic, strong) NSString *intentName ;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, assign) BOOL display;
@property(nonatomic, strong) NSArray *appIds;

- (id)initWithResult:(NSDictionary *)result;

@end


