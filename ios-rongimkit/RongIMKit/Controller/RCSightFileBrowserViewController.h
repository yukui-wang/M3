//
//  RCSightFileBrowserViewController.h
//  RongIMKit
//
//  Created by zhaobingdong on 2017/5/12.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCMessageModel;
@interface RCSightFileBrowserViewController : UITableViewController

- (instancetype)initWithMessageModel:(RCMessageModel *)model;

@end
