//
//  CMPChatChooseMemberViewController.h
//  CMPCore
//
//  Created by wujiansheng on 16/8/19.
//
//

//#import <CMPLib/CMPBannerWebViewController.h>
//
//@interface CMPChatPersionViewController : CMPBannerWebViewController
//
//@end



#import <CMPLib/CMPBannerWebViewController.h>


@protocol CMPChatChooseMemberViewControllerDelegate;

@interface CMPChatChooseMemberViewController : CMPBannerWebViewController

@property (nonatomic, assign)NSInteger maxSize;
@property (nonatomic, assign)NSInteger minSize;
@property (nonatomic, retain)NSArray *excludeData;
@property (nonatomic, retain)NSArray *fillBackData;
@property (nonatomic, assign)id<CMPChatChooseMemberViewControllerDelegate> delegate;

@end

@protocol CMPChatChooseMemberViewControllerDelegate <NSObject>

- (void)chatChooseMemberViewController:(CMPChatChooseMemberViewController *)controller didSelectMember:(NSArray *)members;

@end
