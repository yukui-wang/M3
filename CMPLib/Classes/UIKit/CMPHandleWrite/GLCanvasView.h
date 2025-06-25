//
//  GLCanvasView.h
//  SyCanvasViewTest
//
//  Created by admin on 12-3-30.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define kCanvasTypeGraffiti        1  // 涂鸦板（默认）
#define kCanvasTypeHandPaint       2  // 手写

#import <UIKit/UIKit.h>

@protocol GLCanvasViewDelegage; 

@interface GLCanvasView : UIView {
    id<GLCanvasViewDelegage>    delegate_;
    NSMutableArray  *strokes_;
	NSMutableArray  *abandonedStrokes_;
	UIColor         *currentBrushColor_;    // 画刷颜色
	CGFloat         currentBrushSize_;      // 画刷大小
	UIImage         *backgroundImage_;      // 背景图片(涂鸦)
	UIImage         *screenImage_;          // 屏幕图片
    CGSize          imgeSize_;              // 图片大小
    NSUInteger      canvasType_;            // 画布类型
    CGRect          contentFrame_;
}

@property (nonatomic, assign)id<GLCanvasViewDelegage>   delegate;
@property (nonatomic, retain)NSMutableArray *strokes;
@property (nonatomic, retain)NSMutableArray *abandonedStrokes;
@property (nonatomic, retain)UIColor        *currentBrushColor;
@property (nonatomic, assign)CGFloat        currentBrushSize;
@property (nonatomic, retain)UIImage        *backgroundImage;
@property (nonatomic, retain)UIImage        *screenImage;
@property (nonatomic, assign)CGSize         imgeSize;
@property (nonatomic, assign)NSUInteger     canvasType;
@property (nonatomic, assign)CGRect         contentFrame;

@property (nonatomic, assign)CGRect visibleFrame;

- (void)initData;

- (void)addStroke:(CGPoint)point;

- (void)refreshContentFrame:(CGPoint)point;

- (IBAction)clearCanvas;

- (BOOL)isTap;

- (void)didFinishDraw;

- (IBAction)undo;

- (IBAction)redo;

@end

@protocol GLCanvasViewDelegage <NSObject>
- (void)canvasViewDidStartDraw:(GLCanvasView *)aCanvasView;
- (void)canvasViewDidFinishDraw:(GLCanvasView *)aCanvasView;
- (void)canvasView:(GLCanvasView *)aCanvasView didFinishDrawWithStrokes:(NSArray *)aImage;

- (void)canvasView:(GLCanvasView *)aCanvasView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
