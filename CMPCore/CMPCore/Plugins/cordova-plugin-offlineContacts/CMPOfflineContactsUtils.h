//
//  CMPOfflineContactsUtils.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/17.
//
//

#import <CMPLib/CMPObject.h>

@interface CMPOfflineContactsUtils : CMPObject

+ (BOOL)showOrganizationView:(UIViewController *)parentViewController;
+ (BOOL)showProjectTeamView:(UIViewController *)parentViewController;
+ (BOOL)showGroupChatView:(UIViewController *)parentViewController;
+ (BOOL)showFrequentContactsView:(UIViewController *)parentViewController;
+ (BOOL)showSearchView:(UIViewController *)parentViewController;
+ (BOOL)showRelatedView:(UIViewController *)parentViewController;

@end
