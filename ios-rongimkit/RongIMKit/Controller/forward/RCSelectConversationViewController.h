//
//  RCSelectConversationViewController.h
//  RongCallKit
//
//  Created by 岑裕 on 16/3/12.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RCStatusDefine.h>
#import <RongIMLib/RCConversation.h>

@interface RCSelectConversationViewController : UIViewController

- (instancetype)initSelectConversationViewControllerCompleted:
    (void (^)(NSArray<RCConversation *> *conversationList))completedBlock;

@end
