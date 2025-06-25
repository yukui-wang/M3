//
//  SyLocalOfflineFilesListViewCell.h
//  M1Core
//
//  Created by chenquanwei on 14-3-14.
//
//

#import <CMPLib/SyBaseTableViewCell.h>
#import <CMPLib/CMPOfflineFileRecord.h>

@protocol SyLocalOfflineFilesListViewCellDelegate ;
@interface SyLocalOfflineFilesListViewCell : SyBaseTableViewCell
{
    UIImageView     *_archiveImageView;
    UIImageView     *_attachmentImageView;
    UILabel         *_titleLabel;
    UILabel         *_sizeLabel;
    UILabel         *_timeLabel;
    UILabel         *_nameLabel;
    //    UIImageView *_selectedBkImageView;
}

@property (nonatomic, retain)CMPOfflineFileRecord *downloadFile;
@property (nonatomic, readonly) UIButton  *attachmentButton;
@property (nonatomic, assign) id <SyLocalOfflineFilesListViewCellDelegate> delegate;


- (void)setOfflineFilesListItem:(CMPOfflineFileRecord *)downloadFile;
@end

@protocol SyLocalOfflineFilesListViewCellDelegate <NSObject>

- (void)attachmentButtonAction:(CMPOfflineFileRecord *)downloadFile;
@end
