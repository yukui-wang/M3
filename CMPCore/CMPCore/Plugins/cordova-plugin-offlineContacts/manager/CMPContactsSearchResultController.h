//
//  CMPContactsSearchResultManager.h
//  M3
//
//  Created by CRMO on 2017/11/27.
//

#import <CMPLib/CMPObject.h>
#import "CMPContactsSearchResultView.h"

@protocol CMPContactsSearchResultControllerDelegate;

@interface CMPContactsSearchResultController : CMPObject

@property (strong, nonatomic) CMPContactsSearchResultView *mainView;
@property (weak, nonatomic) id<CMPContactsSearchResultControllerDelegate> delegate;

/**
 必须调用该方法初始化

 @param frame CMPContactsSearchResultView的frame
 @param showSearchBar 是否显示搜索框
 @param scope 是否是多维组织搜索
 @param businessID 多维组织搜索ID
 @param searchBarHeight 搜索框高度
 @return
 */
- (instancetype)initWithFrame:(CGRect)frame
                showSearchBar:(BOOL)showSearchBar
                      isScope:(BOOL)scope
                   businessID:(NSString *)businessID
              searchBarHeight:(CGFloat)searchBarHeight
                     delegate:(id<CMPContactsSearchResultControllerDelegate>)delegate;
- (instancetype)initWithFrame:(CGRect)frame
                showSearchBar:(BOOL)showSearchBar
             isMultipleSelect:(BOOL)isMultipleSelect
                      isScope:(BOOL)scope
                   businessID:(NSString *)businessID
              searchBarHeight:(CGFloat)searchBarHeight
                     delegate:(id<CMPContactsSearchResultControllerDelegate>)delegate;
/**
 开始加载离线数据
 */
- (void)loadAllMember;

/**
 根据关键词搜索
 */
- (void)searchWithKeyWord:(NSString *)keyword;

@end

@protocol CMPContactsSearchResultControllerDelegate <NSObject>

@optional

/**
 将要开始加载数据
 */
- (void)searchResultWillLoadData:(CMPContactsSearchResultController *)manager;

/**
 加载数据成功
 */
- (void)searchResultDidLoadData:(CMPContactsSearchResultController *)manager;

/**
 加载数据失败
 */
- (void)searchResultFailLoadData:(CMPContactsSearchResultController *)manager;

/**
 用户点击取消按钮
 */
- (void)searchResultDidCacel:(CMPContactsSearchResultController *)manager;

/**
 用户点击搜索按钮
 */
- (void)searchResultDidSearch:(CMPContactsSearchResultController *)manager;


/**
 用户开始拖动
 */
- (void)searchResultWillBeginDragging:(CMPContactsSearchResultController *)manager;

/**
 用于点击搜索结果的列表，如致信转发搜索等
 */
- (void)searchResultDidSelectMember:(NSObject *)member;

@end


