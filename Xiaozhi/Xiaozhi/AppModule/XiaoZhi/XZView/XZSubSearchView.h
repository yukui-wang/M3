//
//  XZSubSearchView.h
//  M3
//
//  Created by wujiansheng on 2017/11/13.
//

#import "XZBaseView.h"
#import "XZViewDelegate.h"

@protocol XZSubSearchViewDelegate <NSObject>
- (void)subSearchViewClickText:(NSString *)text;
@end

@interface XZSubSearchView : XZBaseView

@property(nonatomic,assign)id<XZViewDelegate> delegate;//老版本用pre
@property(nonatomic,assign)id<XZSubSearchViewDelegate> viewDelegate;//新版本用

@end

