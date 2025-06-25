//
//  CMPForwardSearchViewController.h
//  M3
//
//  Created by zengbixing on 2018/2/8.
//

#import <CMPLib/CMPBaseViewController.h>
#import "CMPContactsSearchResultViewController.h"
@protocol CMPForwardSearchDelegate <NSObject>

@optional

- (void)selectRowAtIndexPath:(NSObject *)object;

@end

/*因为与通讯录一直，直接继承 CMPContactsSearchResultViewController*/
@interface CMPForwardSearchViewController : CMPContactsSearchResultViewController

@property (nonatomic , assign) id<CMPForwardSearchDelegate> delegate;

@end
