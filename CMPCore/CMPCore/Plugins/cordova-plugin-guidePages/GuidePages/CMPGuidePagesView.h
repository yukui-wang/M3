//
//  CMPGuidePagesView.h
//  CMPCore
//
//  Created by wujiansheng on 16/8/19.
//
//

#import <CMPLib/CMPBaseView.h>

@protocol CMPGuidePagesViewDelegate;

@interface CMPGuidePagesView : CMPBaseView
@property(nonatomic,assign)id<CMPGuidePagesViewDelegate> delegate;
- (void)fillImageByInfoArray:(NSArray *)aImageInfoArray;

@end


@protocol CMPGuidePagesViewDelegate <NSObject>

- (void)guidePagesView:(CMPGuidePagesView *)welcomeView buttonTag:(NSInteger)tag;

@end
