//
//  CMPShareImageView.h
//  M3
//
//  Created by MacBook on 2019/10/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPShareImageView : UIView

+ (instancetype)imageViewWithFrame:(CGRect)frame image:(NSString *)imagePath shareFileCount:(NSInteger)shareFileCount;

/* view点击 */
@property (copy, nonatomic) void(^viewClicked)(void);
/* 是否是video */
@property (assign, nonatomic) BOOL isVideo;


@end

NS_ASSUME_NONNULL_END
