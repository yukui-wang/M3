

#import <UIKit/UIKit.h>
#import "CMPScreenshotControlProtocol.h"

@interface CMPCameraViewController : UIViewController<CMPScreenshotControlProtocol>

/* 使用图片按钮点击  也就是发送 */
@property (copy, nonatomic) void(^usePhotoClicked)(UIImage *img,NSDictionary *videoInfo);

/* 使用图片按钮点击  也就是发送 */
@property (copy, nonatomic) void(^usePhoto1Clicked)(NSString *imgPath,NSDictionary *videoInfo);

@property (copy, nonatomic) void(^didDismissBlock)(void);


/* 是否不显示拍照功能，默认显示 */
@property (assign, nonatomic) BOOL isNotShowTakePhoto;
/* 是否不显示拍摄视频功能，默认显示 */
@property (assign, nonatomic) BOOL isNotShowTakeVideo;
/* 拍摄视频的最长时长 */
@property (assign, nonatomic) CGFloat videoMaxTime;

@end
