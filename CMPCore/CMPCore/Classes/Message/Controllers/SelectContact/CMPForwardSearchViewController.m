//
//  CMPForwardSearchViewController.m
//  M3
//
//  Created by zengbixing on 2018/2/8.
//

#import "CMPForwardSearchViewController.h"
#import "CMPForwardSearchView.h"
#import "CMPSelContactListCell.h"
#import "CMPMessageObject.h"
#import <CMPLib/CMPOfflineContactMember.h>

@implementation CMPForwardSearchViewController
- (void)dealloc{
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

- (void)searchResultDidSelectMember:(CMPOfflineContactMember *)member {
    
    if (_delegate &&[_delegate respondsToSelector:@selector(selectRowAtIndexPath:)]) {
        CMPMessageObject *object = [[CMPMessageObject alloc] init];
        object.cId = member.orgID;//todo 这个一直么 ？
        object.appName = member.name;
        object.type = CMPMessageTypeRC;
        object.subtype = CMPRCConversationType_PRIVATE;
        [_delegate selectRowAtIndexPath:object];
        SY_RELEASE_SAFELY(object);
    }
}

@end
