//
//  SvUDIDTools+Ext.m
//  M3
//
//  Created by youlin on 2019/6/28.
//

#import "SvUDIDTools+Ext.h"
#import "CMPCommonManager.h"

@implementation SvUDIDTools (Ext)

+ (NSString *)prefixAppID
{
    return [CMPCommonManager prefixAppID];
}

@end
