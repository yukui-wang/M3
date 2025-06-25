//
//  CMPExitAppPlugin.m
//  CMPCore
//
//  Created by youlin on 2016/11/3.
//
//

#import "CMPExitAppPlugin.h"

@implementation CMPExitAppPlugin

- (void)exitApp:(CDVInvokedUrlCommand*)command
{
    exit(0);
}

@end
