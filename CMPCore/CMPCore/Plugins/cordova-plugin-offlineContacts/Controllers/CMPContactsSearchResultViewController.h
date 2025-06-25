//
//  CMPOfflineContractSearchResultViewController.h
//  CMPCore
//
//  Created by yang on 2017/2/23.
//
//

#import <CMPLib/CMPBaseViewController.h>
#import "CMPContactsSearchResultController.h"

@interface CMPContactsSearchResultViewController : CMPBaseViewController

@property (strong, nonatomic) CMPContactsSearchResultController *searchResultManager;
@property (weak, nonatomic) UISearchBar *searchBar;
@property (nonatomic, strong) NSString *searchKeyword;
@property (nonatomic, assign) CGFloat searchBarHeight;

@property (assign, nonatomic) BOOL isMultipleSelect;


@end
