//
//  CMPMsgFilterResult.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/4/13.
//

#import "CMPMsgFilterResult.h"

@implementation CMPMsgFilter
+(NSDictionary *)modelCustomPropertyMapper
{
    return @{@"matchVal":@"word",
             @"replaceVal":@"replaceWord",
             @"level":@"type"
    };
}
@end

@implementation CMPMsgFilterResult

@end
