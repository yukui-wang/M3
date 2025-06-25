//
//  CMPFaceView.h
//  CMPCore
//
//  Created by wujiansheng on 16/9/6.
//
//

#import "CMPBaseView.h"

#import "CMPFaceImageView.h"
#import "SyFaceDownloadRecordObj.h"
@protocol CMPFaceViewDelegate;
@class MMemberIcon;

@interface CMPFaceView : CMPBaseView  {
    UIImageView *_backgroundImageView; // 背景图
    CMPFaceImageView     *faceImgView_;
    BOOL                isFetchCache;
}

@property (nonatomic, assign) id<CMPFaceViewDelegate> delegate;
@property (nonatomic, readonly) CMPFaceImageView     *imageView;
@property (nonatomic, retain) id userInfo; // 存放用户数据
@property (nonatomic, assign) BOOL backgroundImgViewHidden;
@property (nonatomic, retain) SyFaceDownloadObj *memberIcon;
@property (nonatomic, assign) BOOL loadImageLazily; // 懒加载图片 为yes的时候， 需要手动调用loadImage方法加载image，主要用于列表
@property (nonatomic, retain) UIImage *placeholdImage; // 占位图，不设置有默认图

- (void)loadImage; // 加载图片
- (void)setImage:(UIImage *)aImage;
- (void)showShadow:(BOOL)aShowShadow;
- (void)fetchImage;
- (void)setMemberIcon:(SyFaceDownloadObj *)memberIcon customImage:(NSString *)imageName;
- (void)addBackgroundImgViewWithImageName:(NSString *)imgName;

@end

@protocol CMPFaceViewDelegate <NSObject>
@optional
- (void)faceViewTouch:(CMPFaceView *)aFaceView;
- (void)faceViewTouch:(CMPFaceView *)aFaceView touches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)faceViewDraging:(CMPFaceView *)aFaceView touches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)faceViewDragEnded:(CMPFaceView *)aFaceView touches:(NSSet *)touches withEvent:(UIEvent *)event;

@end
