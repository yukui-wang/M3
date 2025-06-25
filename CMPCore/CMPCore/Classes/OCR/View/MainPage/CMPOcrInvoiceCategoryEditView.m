//
//  CMPOcrInvoiceCategoryEditView.m
//  M3
//
//  Created by Kaku Songu on 12/20/21.
//

#import "CMPOcrInvoiceCategoryEditView.h"
#import <CMPLib/CMPThemeManager.h>
@interface CMPOcrInvoiceCategoryEditView()
{
    CMPOcrModulesManageCollectionView *_collectionView;
    UIButton *_funcBtn;
}
@end

@implementation CMPOcrInvoiceCategoryEditView

-(void)setup
{
    [super setup];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    
    _collectionView = [[CMPOcrModulesManageCollectionView alloc] init];
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.bottom.offset(-15);
        make.left.offset(20);
        make.right.offset(-20);
    }];
    
    _funcBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_funcBtn setTitle:@"编辑" forState:UIControlStateNormal];
    _funcBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_funcBtn setTitleColor:[UIColor cmp_specColorWithName:@"theme-bgc"] forState:UIControlStateNormal];
    [_funcBtn addTarget:self action:@selector(_funcBtnAct:) forControlEvents:UIControlEventTouchUpInside];
    [_funcBtn sizeToFit];
    [_collectionView addSubview:_funcBtn];
    [_funcBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(8);
        make.right.offset(0);
    }];
}

-(CMPOcrModulesManageCollectionView *)collectionView
{
    return _collectionView;
}

-(void)_funcBtnAct:(UIButton *)btn
{
    BOOL isNowEdit = _collectionView.edit;
    [_funcBtn setTitle:isNowEdit?@"编辑":@"完成" forState:UIControlStateNormal];
    [_collectionView setEdit:!isNowEdit];
}

@end
