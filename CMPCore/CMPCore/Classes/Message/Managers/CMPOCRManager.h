//
//  CMPOCRManager.h
//  M3
//
//  Created by zengbixing on 2017/12/21.
//

#import <Foundation/Foundation.h>

@interface CMPOCRManager : NSObject

+ (CMPOCRManager*)sharedManager;

- (void)sendRecognizeImg:(NSData*)imgData;

@end
