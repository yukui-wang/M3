//
//  CMPOcrPackageDetailHeaderView.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/20.
//

#import <CMPLib/CMPBaseView.h>
#import "CustomCircleSearchBar.h"
@interface CMPOcrPackageDetailHeaderView : CMPBaseView
@property (nonatomic, strong) CustomCircleSearchBar *searchBar;
@property (nonatomic, copy) void(^AddInvoiceBtnAction)(void);
@property (nonatomic, copy) void(^SubmitInvoiceBtnAction)(void);

- (instancetype)initByControl:(BOOL)canControl;

@end

