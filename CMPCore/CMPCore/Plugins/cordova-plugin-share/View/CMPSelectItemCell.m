//
//  CMPSelectItemCell.m
//  M3
//
//  Created by MacBook on 2019/11/4.
//

#import "CMPSelectItemCell.h"
#import "CMPShareCellModel.h"

NSString * const CMPSelectItemCellId = @"CMPSelectItemCellId";

@interface CMPSelectItemCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *sepatatorLine;


@end

@implementation CMPSelectItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = UIColor.clearColor;
}

- (void)setModel:(CMPShareCellModel *)model {
    _model = model;
    
    self.titleLabel.text = model.title;
}
@end
