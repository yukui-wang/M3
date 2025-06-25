//
//  GTMUtil.h
//  encode
//
//  Created by youlin guo on 14/12/26.
//  Copyright (c) 2014年 Seeyon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTMUtil : NSObject

+ (NSString*)encrypt:(NSString*)plainText;
+ (NSString*)decrypt:(NSString*)encryptText;

@end
