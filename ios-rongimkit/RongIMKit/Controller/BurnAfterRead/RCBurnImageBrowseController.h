//
//  RCBurnImageBrowseController.h
//  RongIMKit
//
//  Created by Zhaoqianyu on 2018/5/14.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCMessageModel;

@interface RCBurnImageBrowseController : UIViewController

/*!
 当前图片消息的数据模型
 */
@property (nonatomic, strong) RCMessageModel *messageModel;

@end
