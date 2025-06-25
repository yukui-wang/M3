//
//  SyLbsImageShowTableViewCell.h
//  M1Core
//
//  Created by Aries on 14/12/16.
//
//

#import <UIKit/UIKit.h>

@protocol CMPLbsImageShowTableViewCellDelegate;
@interface CMPLbsImageShowTableViewCell : UITableViewCell
@property (nonatomic, assign) id<CMPLbsImageShowTableViewCellDelegate> delegate;
-(void)setCellWithAttachmentList:(NSArray *)list;
@end

@protocol CMPLbsImageShowTableViewCellDelegate <NSObject>

- (void)lbsImageShowTableViewCell:(CMPLbsImageShowTableViewCell *)cell imageIndex:(NSInteger)index attchmentList:(NSArray *)imageList;

@end