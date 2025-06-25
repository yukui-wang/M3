//
//  DES3Util.h
//  CMPLib
//
//  Created by youlin on 2016/9/14.
//  Copyright © 2016年 CMPCore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DES3Util : NSObject

/*解密数据forAES128*/
+ (NSString *)decryptDataAES128:(NSString *)str passwordKey:(NSString *)aKey;

@end
