//
//  CMPOfflineContractSearchResultViewController.h
//  CMPCore
//
//  Created by yang on 2017/2/23.
//
//

#import "CMPBaseViewController.h"

@interface CMPContactsSearchResultViewController : CMPBaseViewController
@property (nonatomic, strong) NSArray *allMembers;
@property (nonatomic, strong) NSString *searchKeyword;
@property (nonatomic, assign) CGFloat searchBarHeight;

@end
