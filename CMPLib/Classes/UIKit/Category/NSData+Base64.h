//
//  NSData+Base64.h
//  HelloCordova
//
//  Created by lin on 15/8/21.
//
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)

+ (NSData*) base64Decode:(NSString *)string;
+ (NSString*) base64Encode:(NSData *)data;
@end
