//
//  RCThreadSafeMutableDictionary.h
//  RongIMKit
//
//  Created by 岑裕 on 16/5/12.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMPRCThreadSafeMutableDictionary : NSMutableDictionary <NSLocking>

@end
