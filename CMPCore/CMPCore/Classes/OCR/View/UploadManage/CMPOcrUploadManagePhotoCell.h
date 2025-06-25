//
//  CMPOcrUploadManagePhotoCell.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrUploadManagePhotoCell : UITableViewCell
+ (CGFloat)heightWithCount:(NSInteger)count;
- (void)reloadDataWith:(NSMutableArray*)photoArray completion:(void(^)(void))completion;
@property (nonatomic, copy) void(^ClickedAddPhotoCollectionCell)(void);
@property (nonatomic, copy) void(^ClickedPhotoCollectionCell)(id);
@end

NS_ASSUME_NONNULL_END
