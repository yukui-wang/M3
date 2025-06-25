//
//  CMPContactsSearchResultView.h
//  M3
//
//  Created by CRMO on 2017/11/27.
//

#import <UIKit/UIKit.h>

@interface CMPContactsSearchResultView : UIView

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *noDataView;
@property (strong, nonatomic) UISearchBar *searchBar;

- (instancetype)initWithFrame:(CGRect)frame
                showSearchBar:(BOOL)showSearchBar
              searchBarHeight:(CGFloat)searchBarHeight;
- (instancetype)initWithFrame:(CGRect)frame
                showSearchBar:(BOOL)showSearchBar
              searchBarHeight:(CGFloat)searchBarHeight
             isMultipleSelect:(BOOL)isMultipleSelect
                     delegate:(id)delegate;
- (void)focusTextView;
- (void)unFocusTextView;
- (void)removeObserver;

@end
