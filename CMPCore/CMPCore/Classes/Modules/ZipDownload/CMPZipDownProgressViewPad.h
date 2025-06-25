//
//  CMPZipDownProgressViewPad.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2024/1/10.
//

#import <CMPLib/CMPBaseView.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPZipDownProgressViewPad : CMPBaseView

@property(nonatomic,assign,readonly) NSInteger state;
-(void)setState:(NSInteger)state;//0下载。1完成 2失败
@end

NS_ASSUME_NONNULL_END
