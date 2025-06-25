//
//  NSString+SHA256.m
//  FaceIDFaceAuth
//
//  Created by Megvii on 2021/12/4.
//

#import "NSString+SHA256.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (SHA256)

- (NSString *)sha256 {
    const char *str = [self UTF8String];

    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for (int i = 0; i< CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    ret = (NSMutableString *)[ret lowercaseString];
    return ret;
}

- (NSString*)hmacForSecret:(NSString*)secret {
    
    const char *cKey  = [secret UTF8String];
    const char *cData = [self UTF8String];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
        
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for (int i = 0; i< CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", cHMAC[i]];
    }
    hash = (NSMutableString *)[hash lowercaseString];
    
    return hash;
}


@end
