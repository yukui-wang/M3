//
//  RCBurnSightViewController.h
//  RongIMKit
//
//  Created by Zhaoqianyu on 2018/5/12.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCMessageModel;

@interface RCBurnSightViewController : UIViewController

/*!
 当前消息的数据模型
 */
@property (nonatomic, strong) RCMessageModel *messageModel;

@end
