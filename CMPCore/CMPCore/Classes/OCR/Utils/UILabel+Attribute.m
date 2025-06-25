//
//  UILabel+Attribute.m
//  M3
//
//  Created by Shoujian Rao on 2022/1/13.
//

#import "UILabel+Attribute.h"
#import "objc/Runtime.h"
static NSString *paramKey = @"paramKey";
static NSString *rowNumKey = @"rowNum";

@implementation UILabel (Attribute)

- (NSDictionary *)param{
    return objc_getAssociatedObject(self, &paramKey);
}

- (void)setParam:(NSDictionary *)param{
    objc_setAssociatedObject(self, &paramKey, param,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)rowNum{
    return [objc_getAssociatedObject(self, &rowNumKey) integerValue];
}

- (void)setRowNum:(NSInteger)rowNum{
    objc_setAssociatedObject(self, &rowNumKey, @(rowNum),OBJC_ASSOCIATION_ASSIGN);
}

@end
