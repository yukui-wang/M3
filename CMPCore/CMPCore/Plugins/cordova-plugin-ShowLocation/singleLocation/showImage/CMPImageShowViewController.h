//
//  SyImageShowViewController.h
//  M1Core
//
//  Created by Aries on 14-3-10.
//
//

#import <CMPLib/CMPBannerViewController.h>
#import "CMPImageShowView.h"
@interface CMPImageShowViewController : CMPBannerViewController<UIScrollViewDelegate>
{
    CMPImageShowView *_imageShowView;
}
@property (nonatomic, retain) NSArray *attachmentList;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) NSInteger pageIndex;
@end
