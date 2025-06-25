//
//  NSString+SHA256.h
//  FaceIDFaceAuth
//
//  Created by Megvii on 2021/12/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SHA256)

- (NSString *)sha256;

- (NSString*)hmacForSecret:(NSString*)secret;

@end

NS_ASSUME_NONNULL_END
