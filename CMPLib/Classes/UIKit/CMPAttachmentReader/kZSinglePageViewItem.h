//
//  kZPageViewItem.h
//  测试ShowPhoto
//
//  Created by lin on 14-9-29.
//  Copyright (c) 2014年 lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface kZSinglePageViewItem : UIScrollView<UIScrollViewDelegate>

@property (nonatomic,retain) UILabel *pageIndexLabel;
@property (nonatomic,retain) UIImageView *imageView;

-(void)disPlayWithImage:(UIImage *)aImage;
//旋转屏幕时，重新设置ImageView位置
-(void)setImageViewFrame;
@end
