//
//  CMPFeatureSupportControl+V8_1.m
//  CMPLib
//
//  Created by Kaku Songu on 9/4/21.
//  Copyright © 2021 crmo. All rights reserved.
//

#import "CMPFeatureSupportControl+V8_1.h"
#import "CMPServerVersionUtils.h"

@implementation CMPFeatureSupportControl (V8_1)

+(BOOL)isSupportMessageQuote
{
    return [CMPServerVersionUtils serverIsLaterV8_1];
}

@end
