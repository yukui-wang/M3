//
//  CMPShareCollectionViewCell.m
//  M3
//
//  Created by MacBook on 2019/10/28.
//

#import "CMPShareCollectionViewCell.h"
#import "CMPShareCellModel.h"
#import "CMPShareFileModel.h"

#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPThemeManager.h>


NSString * const CMPShareCollectionViewCellId = @"CMPShareCollectionViewCellId";

@interface CMPShareCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation CMPShareCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
}

- (void)setShareModel:(CMPShareCellModel *)shareModel {
    _shareModel = shareModel;
    
    self.imgView.image = [UIImage imageNamed:shareModel.icon];
    self.textLabel.text = SY_STRING(shareModel.title);
}

- (void)setShareBtnModel:(CMPShareBtnModel *)shareBtnModel {
    _shareBtnModel = shareBtnModel;
    
    self.imgView.image = [UIImage imageNamed:shareBtnModel.img];
    self.textLabel.text = shareBtnModel.title;
}

@end
