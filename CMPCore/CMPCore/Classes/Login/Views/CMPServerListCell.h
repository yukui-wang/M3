//
//  CMPServerListCell.h
//  M3
//
//  Created by CRMO on 2017/10/31.
//

#import <UIKit/UIKit.h>
#import <CMPLib/CMPServerModel.h>

@interface CMPServerListCell : UITableViewCell

/**  点击编辑地址按钮点击事件 **/
@property (nonatomic,copy) void(^tapEditAction)(void);
/** 数据模型 **/
@property (nonatomic, strong) CMPServerModel *model;
@property (nonatomic, assign) BOOL isSelected;

/**
 隐藏分割线
 */
- (void)hideBottomLine;
- (void)setupWithModel:(CMPServerModel *)model;


@end
