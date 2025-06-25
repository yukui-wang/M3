//
//  RCCombineMsgFilePreviewViewController.h
//  RongIMKit
//
//  Created by Jue on 16/7/29.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RCStatusDefine.h>

@interface RCCombineMsgFilePreviewViewController : UIViewController

- (instancetype)initWithRemoteURL:(NSString *)remoteURL
                 conversationType:(RCConversationType)conversationType
                         targetId:(NSString *)targetId
                         fileSize:(long long)fileSize
                         fileName:(NSString *)fileName
                         fileType:(NSString *)fileType;

@end
