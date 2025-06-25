//
//  CMPProgressView.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2024/1/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPZipDownProgressView : UIProgressView
@property(nonatomic,assign,readonly) NSInteger state;
-(void)setState:(NSInteger)state;
@end

NS_ASSUME_NONNULL_END
