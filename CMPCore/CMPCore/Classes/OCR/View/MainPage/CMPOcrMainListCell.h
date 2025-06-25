//
//  CMPOcrMainListCell.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/5.
//

#import <UIKit/UIKit.h>
@class CMPOcrPackageModel;

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrMainListCell : UITableViewCell

@property (nonatomic,copy) void(^actBlk)(NSInteger act,id ext);
@property (nonatomic, assign) NSInteger fromPage;//0为首页，1为我的
-(void)setItem:(CMPOcrPackageModel *)item;

@end

NS_ASSUME_NONNULL_END
