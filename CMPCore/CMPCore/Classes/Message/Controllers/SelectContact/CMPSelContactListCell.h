//
//  CMPSelContactListCell.h
//  M3
//
//  Created by youlin guo on 2018/2/2.
//

#import <CMPLib/CMPBaseTableViewCell.h>
#import <CMPLib/CMPFaceView.h>

@interface CMPSelContactListCell : CMPBaseTableViewCell

@property (nonatomic, readonly) CMPFaceView *faceView;
@property (nonatomic, readonly) UILabel *userNameLabel;
@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, assign) BOOL selectCell;
@property (nonatomic, strong) UIImageView *adminImageView;
@property (nonatomic, strong) UILabel *departmentLabel;



+ (CGFloat)height;

//添加选择视图
- (void)setSelectImageConfig;
//管理员图标
- (void)setAdminImageConfig:(BOOL)show;
//部门群标识
- (void)setDepartment:(NSString *)text;

@end
