//
//  CMPMessageMultipleForwardView.h
//  M3
//
//  Created by Shoujian Rao on 2023/9/6.
//

#import <UIKit/UIKit.h>
#import <CMPLib/CMPFaceView.h>
#import <CMPLib/CMPBaseView.h>


@interface CMPMessageMultipleForwardView : CMPBaseView<UITextFieldDelegate>

/* 是否显示 允许流程外人员查看 view */
@property (assign, nonatomic) BOOL allowCheckedOutside;
/* 文件个数 */
@property (assign, nonatomic) NSInteger fileCount;
/* 是否是文件助手 */
@property (assign, nonatomic) BOOL isFileAssitance;

@property (strong, nonatomic) NSArray *targetArr;

@property(nonatomic, copy) void (^selectedBlock)(NSString *content,BOOL isCheck);
@property(nonatomic, copy) void (^cancelBlock)(void);

- (void)setHeadIcon:(SyFaceDownloadObj*)chatId;
- (void)setLocalIcon:(UIImage *)localIcon;
- (void)setContent:(NSString*)str;
- (void)setName:(NSString*)name;
- (void)setThumbnailImage:(UIImage*)thumbnailImage fileSize:(NSString *)size;
- (NSString*)getContentFieldText;
- (BOOL)isContentFieldEditing;
- (id)initWithFrame:(CGRect)frame withTargetArr:(NSArray *)targetArr;


@end

