//
//  RCImageSlideController.h
//  RongIMKit
//
//  Created by liulin on 16/5/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "CMPRCBaseViewController.h"
#import "CMPRCImageMessageProgressView.h"
#import <UIKit/UIKit.h>
@class RCMessageModel;

@interface CMPRCImageSlideController : CMPRCBaseViewController

/*!
 当前图片消息的数据模型
 */
@property(nonatomic, strong) RCMessageModel *messageModel;

/*!
 图片消息进度的View
 @warning  **已废弃，请勿使用。**
 */
@property(nonatomic, strong) CMPRCImageMessageProgressView *rcImageProressView;

@end
