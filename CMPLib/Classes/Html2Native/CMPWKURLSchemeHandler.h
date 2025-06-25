//
//  CMPWKURLSchemeHandler.h
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2023/5/24.
//  Copyright © 2023 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CMPWKURLSchemeHandlerDelegate <NSObject>

-(NSData *)dataForRequestUrl:(NSURL *)reqUrl;

@end

@interface CMPWKURLSchemeHandler : NSObject<WKURLSchemeHandler>

@property (nonatomic,weak) id<CMPWKURLSchemeHandlerDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
