//
//  CMPMultiLoginManageView.h
//  M3
//
//  Created by 程昆 on 2019/9/10.
//

#import <CMPLib/CMPBaseView.h>
@class CMPOnlineDevModel;

@interface CMPMultiLoginManageView : CMPBaseView

@property (nonatomic, copy) void (^closeButtonAction)(void);
@property (nonatomic, copy) void (^muteButtonAction)(void);
@property (nonatomic, copy) void (^fileAssistantButtonAction)(void);
@property (nonatomic, copy) void (^exitOtherDeviceButtonAction)(void);

- (void)setTipText:(NSString *)text;
- (void)setMuteButtonSelectedStatus:(BOOL)status;
- (void)updateDataWithModel:(CMPOnlineDevModel *)model;

@end


