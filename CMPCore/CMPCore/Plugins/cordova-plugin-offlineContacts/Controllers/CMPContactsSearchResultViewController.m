//
//  CMPOfflineContractSearchResultViewController.m
//  CMPCore
//
//  Created by yang on 2017/2/23.
//
//

#import "CMPContactsSearchResultViewController.h"
#import "CMPOfflineContactCell.h"
#import <CMPLib/CMPPersonInfoUtils.h>
#import "CMPContactsSearchMemberProvider.h"
#import "CMPContactsSearchResultView.h"
#import "CMPContactsSearchResultController.h"
#import "CMPContactsManager.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/NSObject+CMPHUDView.h>

@interface CMPContactsSearchResultViewController ()<CMPContactsSearchResultControllerDelegate>



@end

@implementation CMPContactsSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchResultManager = [[CMPContactsSearchResultController alloc] initWithFrame:self.view.frame
                                                                          showSearchBar:NO
                                                                       isMultipleSelect:self.isMultipleSelect
                                                                                isScope:NO
                                                                             businessID:nil
                                                                        searchBarHeight:50
                                                                               delegate:self];
    [self.view addSubview:self.searchResultManager.mainView];
    [self.searchResultManager loadAllMember];
}

- (void)viewWillLayoutSubviews {
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && IS_IPHONE_X_UNIVERSAL) {
        [self.searchResultManager.mainView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view).inset(64);
            make.top.bottom.equalTo(self.view);
        }];
    } else {
        [self.searchResultManager.mainView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

#pragma mark-
#pragma mark-Getter & Setter

- (void)setSearchKeyword:(NSString *)searchKeyword {
    [self.searchResultManager searchWithKeyWord:searchKeyword];
}

#pragma mark-
#pragma mark-CMPContactsSearchResultManagerDelegate

- (void)searchResultWillBeginDragging:(CMPContactsSearchResultController *)manager {
    [self.searchBar resignFirstResponder];
}

- (void)searchResultWillLoadData:(CMPContactsSearchResultController *)manager {
    [self cmp_showProgressHUD];
}

- (void)searchResultDidLoadData:(CMPContactsSearchResultController *)manager {
    [self cmp_hideProgressHUD];
}

- (void)searchResultFailLoadData:(CMPContactsSearchResultController *)manager {
    [self cmp_showHUDWithText:SY_STRING(@"contacts_downloadFail")];
}

@end
