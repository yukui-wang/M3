//
//  CMPPasteboardPlugin.m
//  CMPCore
//
//  Created by youlin on 2017/7/3.
//
//

#import "CMPPasteboardPlugin.h"

@implementation CMPPasteboardPlugin

- (void)setString:(CDVInvokedUrlCommand *)command
{
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *aStr = [argumentsMap objectForKey:@"value"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:aStr];
}

@end
