//
//  CMPOfflineContactFaceview.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/5.
//
//

#import <UIKit/UIKit.h>

//@interface CMPOfflineContactFaceview : UILabel
//- (void)layoutText:(NSString *)text;
//- (void)layoutBKColorWithIndex:(NSInteger)index;
//@end

#import "CMPFaceView.h"
@interface CMPOfflineContactFaceview : CMPFaceView
@property(nonatomic, copy)NSString *memberId;
@end
