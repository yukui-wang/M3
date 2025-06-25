//
//  CMPOcrTipTool.m
//  CMPCore
//
//  Created by Shoujian Rao on 2021/12/23.
//

#import "CMPOcrTipTool.h"
#import <UIKit/UIKit.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>
@implementation CMPOcrTipTool

//是否显示无数据UI
- (void)showNoDataView:(BOOL)show toView:(UIView *)view{
    if (!show) {
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag == 110011) {
                [obj removeFromSuperview];
            }
        }];
        return;
    }
    UIView *noDataView = UIView.new;
    noDataView.userInteractionEnabled = NO;
    noDataView.tag = 110011;
    [view addSubview:noDataView];
    [noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIImageView *tipImageView = [[UIImageView alloc]init];
    tipImageView.image = [UIImage imageNamed:@"ocr_card_package_list_no_data"];
    [noDataView addSubview:tipImageView];
    [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(noDataView).offset(0);
        make.top.mas_equalTo(76);
    }];
    
    UILabel *label = UILabel.new;
    label.text = @"还没有发票哦~";
    label.textColor = [UIColor cmp_specColorWithName:@"desc-fc"];
    label.font = [UIFont systemFontOfSize:12];
    [noDataView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipImageView.mas_bottom).offset(20);
        make.centerX.equalTo(noDataView).offset(0);
    }];
    
}

//我的-无moudle缺省
- (void)showNoMoudleDataView:(BOOL)show toView:(UIView *)view{
    [self tipWithString:@"暂无历史报销" show:show toView:view];
}

- (void)showNoAssociateDataView:(BOOL)show toView:(UIView *)view{
    [self tipWithString:@"无可关联发票" show:show toView:view];
}

- (void)showNoMoudleMainPage:(BOOL)show toView:(UIView *)view {
    if (!show) {
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag == 110016) {
                [obj removeFromSuperview];
            }
        }];
        return;
    }
    UIView *noDataView = UIView.new;
    noDataView.userInteractionEnabled = NO;
    noDataView.tag = 110016;
    [view addSubview:noDataView];
    [noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIImageView *tipImageView = [[UIImageView alloc]init];
    tipImageView.image = [UIImage imageNamed:@"ocr_card_check_list_no_data"];
    [noDataView addSubview:tipImageView];
    [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(noDataView);
        make.top.mas_equalTo(noDataView).offset(0);
    }];
    
    UILabel *label = UILabel.new;
    label.text = @"暂无授权表单";
    label.textColor = [UIColor cmp_specColorWithName:@"desc-fc"];
    label.font = [UIFont systemFontOfSize:12];
    [noDataView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipImageView.mas_bottom).offset(0);
        make.centerX.equalTo(noDataView).offset(0);
    }];
}
- (void)tipWithString:(NSString *)tipStr show:(BOOL)show toView:(UIView *)view{
    if (!show) {
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag == 110012) {
                [obj removeFromSuperview];
            }
        }];
        return;
    }
    UIView *noDataView = UIView.new;
    noDataView.userInteractionEnabled = NO;
    noDataView.tag = 110012;
    [view addSubview:noDataView];
    [noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIImageView *tipImageView = [[UIImageView alloc]init];
    tipImageView.image = [UIImage imageNamed:@"ocr_card_check_list_no_data"];
    [noDataView addSubview:tipImageView];
    [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(noDataView);
        make.centerX.mas_equalTo(noDataView);
        make.centerY.mas_equalTo(noDataView).offset(-20);
    }];
    
    UILabel *label = UILabel.new;
    label.text = tipStr;
    label.textColor = [UIColor cmp_specColorWithName:@"desc-fc"];
    label.font = [UIFont systemFontOfSize:12];
    [noDataView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipImageView.mas_bottom).offset(0);
        make.centerX.equalTo(noDataView).offset(0);
    }];
}

//识别页面-无数据缺省
- (void)showNoCheckDataView:(BOOL)show toView:(UIView *)view{
    [self tipWithString:@"暂无识别任务" show:show toView:view];
}
@end
