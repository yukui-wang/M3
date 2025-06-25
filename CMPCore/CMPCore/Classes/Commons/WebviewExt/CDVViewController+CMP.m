//
//  CDVViewController+CMP.m
//  M3
//
//  Created by Kaku Songu on 9/15/23.
//

#import "CDVViewController+CMP.h"
#import <CMPLib/CMPCore.h>

@implementation CDVViewController (CMP)

-(BOOL)isUseCMPWebviewEngine:(NSURL *)url
{
    if ([CMPCore sharedInstance].needHandleUrlScheme) {
        return YES;
    }
    return NO;
}

@end
