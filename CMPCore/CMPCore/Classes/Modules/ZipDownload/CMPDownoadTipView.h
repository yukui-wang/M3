//
//  CMPDownoadTipView.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2024/1/3.
//

#import <CMPLib/CMPBaseView.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPDownoadTipView : CMPBaseView
@property(nonatomic,assign) CGPoint basePoint;
@property(nonatomic,assign) CGFloat maxWidth;
@property(nonatomic,assign) NSInteger direction;//默认0向下 1向左
-(void)showInfo:(NSString *)info;

@end

NS_ASSUME_NONNULL_END
