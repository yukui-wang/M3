//
//  SyOfflineFilesViewCell.h
//  M1IPad
//
//  Created by chenquanwei on 14-3-10.
//  Copyright (c) 2014年 北京致远协创软件有限公司. All rights reserved.
//

#import <CMPLib/SyBaseTableViewCell.h>
#import <CMPLib/CMPOfflineFileRecord.h>
@protocol SyOfflineFilesViewCellDelegate;

@interface SyOfflineFilesViewCell : SyBaseTableViewCell{
    UIImageView     *_archiveImageView;
    UIView          *_grayColorView;
    UILabel         *_titleLabel;
    UILabel         *_sizeLabel;
    UILabel         *_timeLabel;
    UILabel         *_nameLabel;
    @public
    UIView          *_separatorLine;
//    UIImageView *_selectedBkImageView;
}
@property (nonatomic, assign)BOOL isSelecte;
@property (nonatomic, assign)BOOL isLongPress;
@property (nonatomic, retain)CMPOfflineFileRecord *downloadFile;
@property (nonatomic, assign)id<SyOfflineFilesViewCellDelegate> delegate;



- (void)setOfflineFilesListItem:(CMPOfflineFileRecord *)downloadFile;
-(void)setSelectedCell:(BOOL)selected animated:(BOOL)animated;

@end

@protocol SyOfflineFilesViewCellDelegate <NSObject>

- (void)offlineFilesSelecte:(SyOfflineFilesViewCell*)aCell;

@end
