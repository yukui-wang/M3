//
//  CMPPrintTools.h
//  CMPLib
//
//  Created by youlin on 2019/7/3.
//  Copyright © 2019年 crmo. All rights reserved.
//

#import <CMPLib/CMPObject.h>
#import <UIKit/UIKit.h>

@interface CMPPrintTools : CMPObject

- (void)printWithFilePath:(NSString *)aFilePath webview:(UIView *)aWebview success:(void(^)(void))success fail:(void(^)(NSError *error))fail;
- (void)printWithData:(NSData *)aData success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

@end

