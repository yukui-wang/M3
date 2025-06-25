//
//  CMPSelContactListFileAssistantTypeCell.h
//  M3
//
//  Created by 程昆 on 2020/5/20.
//

#import <UIKit/UIKit.h>

@class CMPMessageObject;

NS_ASSUME_NONNULL_BEGIN

@interface CMPSelContactListFileAssistantTypeCell : UITableViewCell

- (void)setDataModel:(CMPMessageObject *)dataModel;
@property (nonatomic, assign) BOOL selectCell;
- (void)setSelectImageConfig;
@end

NS_ASSUME_NONNULL_END
