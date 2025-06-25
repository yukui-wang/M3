//
//  SyHandPaintView.h
//  SyCanvasViewTest
//  手写板
//  Created by guoyl on 12-3-30.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLCanvasView.h"

@class GLCursorView;
@class SyColorPickerView;

@protocol SyHandWriteViewDelegate;

@interface SyHandWriteView : UIView<GLCanvasViewDelegage> 
{
    id<SyHandWriteViewDelegate>  delegate_;
    GLCanvasView        *canvasView_;
    GLCursorView        *cursorView_;
    
    NSMutableDictionary *subViewsDict_;
  
    BOOL                shouldContinueBlinking_;    // 是否需要闪烁光标
    BOOL                shouldDrawLine_;
    
    NSInteger           rowCount_; 
    NSInteger           columnCount_;
    
    NSInteger           currentRow_;
    NSInteger           currentColumn_;
    
    CGFloat             rowHeight_;   // 行高度
    CGFloat             columnWidth_; // 列宽度
    UIColor             *textColor_;  // 字体颜色
    CGFloat             textSize_;    // 字体大小
    NSMutableArray      *imageViews_;
    CGFloat             currentX_;     // 行x坐标
    NSInteger           currentIndex_; // 行索引值
    id                  touchesBeganTime_;
    UIView              *moveView_;
    CGPoint             touchPoint_;
    NSMutableArray      *subViews_;
    NSMutableArray      *removedSubViews_;
    NSInteger           textCount;
    UIImageView         *textHelpView_;
    UIImageView         *imageHelpView_;
    NSString            *uniqueId_;
    UIView              *touchView_;
}

@property (nonatomic, assign)id<SyHandWriteViewDelegate> delegate;

@property (nonatomic, assign) CGFloat    rowHeight;
@property (nonatomic, assign) CGFloat    columnWidth;

@property (nonatomic, assign) UIColor    *textColor;
@property (nonatomic, assign) CGFloat    textSize;
@property (nonatomic, assign) NSInteger  currentRow;
@property (nonatomic, retain) id         touchesBeganTime;
@property (nonatomic, assign) UIView     *moveView;
@property (nonatomic, assign) CGPoint    touchPoint;
@property (nonatomic, assign) BOOL       shouldTextHelp;
@property (nonatomic, assign) BOOL       shouldImageHelp;
@property (nonatomic, retain) UIImageView *textHelpView;
@property (nonatomic, retain) UIImageView *imageHelpView;
@property (nonatomic, copy)   NSString    *uniqueId;
@property (nonatomic, assign) BOOL    touchedVisible;

- (void)setupWithInitSize:(CGSize )aInitSize;

// 添加后布局字体
- (void)layoutViewForAdd:(NSInteger)aRow index:(NSInteger)aIndex distance:(CGFloat)distance;

// 删除后布局字体
- (void)layoutViewForDelete:(NSInteger)aRow index:(NSInteger)aIndex distance:(CGFloat)distance;

// 刷新光标位置
- (void)refreshCursorView;

- (NSString *)getRowKey:(NSInteger)aRow;

// 添加图片
- (void)addImage:(UIImage *)aImage;

// 删除图片
- (IBAction)deleteImage;

// 删除全部图片
- (IBAction)deleteAllImages;

// 删除光标前的字体
- (IBAction)deleteText;

// 删除全部字体
- (IBAction)deleteAllText;

// 清空所有字体、图片
- (void)clear;

// 获取屏幕图片
- (UIImage *)getScreenImage;

- (CGRect)getContentFrame;

- (void)correctCurrentIndex;

// 获取当前坐标点上view
- (UIView *)findViewByPoint:(CGPoint )aPoint;

- (void)blinkAnimation:(NSString *)animationId finished:(BOOL)finished target:(UIView *)target;

// 开始光标动画
- (void)startBlinkAnimation;

// 停止光标动画
- (void)stopBlinkAnimation;

// 撤销操作
- (IBAction)undo;

// 取消撤销(未完善)
- (IBAction)redo;

// 显示文本输入帮助窗体
- (void)showTextHelpView;

// 显示图片添加帮助窗体
- (void)showImageHelpView;

@end

@protocol SyHandWriteViewDelegate <NSObject>

- (void)handWriteView:(SyHandWriteView *)aHandWriteView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)handWriteViewDidStartDraw:(SyHandWriteView *)aHandWriteView;
- (void)handWriteViewDidFinishDraw:(SyHandWriteView *)aHandWriteView;

@end
