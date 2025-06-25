//
//  SyImageView.h
//  M1Core
//
//  Created by youlin guo on 14-3-18.
//
//

#import <UIKit/UIKit.h>

@class MAttachment;

@interface CMPImageView : UIImageView

@property (nonatomic, retain)MAttachment *attachment;
@property (nonatomic, assign) BOOL loadImageLazily; // 懒加载图片 为yes的时候， 需要手动调用loadImage方法加载image，主要用于列表

- (void)loadImage; // 加载图片

@end
