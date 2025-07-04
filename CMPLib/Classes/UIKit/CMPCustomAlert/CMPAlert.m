//
//  CMPAlert.m
//  CMPCustomAlertViewDemo
//
//  Created by yaowei on 2018/8/27.
//  Copyright © 2018年 yaowei. All rights reserved.
//

static const float kLineTitleTag = 10000;

static const float btnHeight = 54;
static const float kBtnLineHeight = 16;

static const float KAlterWidth = 315;
static const float KAlterMinHeight = 158;
static const float KAlterMaxHeight = 407;
static const float KAlterMinBodyHeight = KAlterMinHeight - btnHeight;
static const float KAlterMaxBodyHeight = KAlterMaxHeight - btnHeight;

#import "CMPAlert.h"
#import "UIView+Autolayout.h"
#import "CMPContainerViewController.h"
#import "CMPCustomAlertViewHelper.h"
#import "UIImage+CMP.h"

@interface CMPAlert ()
{
    CGFloat _alterWidth;
    //装lineView的集合(包括所有的lineView)
    NSMutableArray *_lineList;
    //装body上下的两个lineView;
    NSMutableArray *_bodyLineList;
//    alertView的背景view
    UIImageView *_backgroundAlterView;
    BOOL _isModal;
    UIColor *_backgroundColor;
    
    /** 0-默认，1-要重新更新约束，2-约束已经生效了 */
    NSInteger _setFrame;
    
    NSLayoutConstraint *_layAlertHeight;//方便后期扩展自定义高度

    NSString *_msg;//记录第一次初始化message，用判断是否加\r\n
    NSString *_title;//记录第一次初始化title，用判断是否加\r\n

}
//alter的容器
@property (nonatomic, strong) UIView *alertView;
//蒙层
@property (nonatomic, strong) UIView *maskView;
//高斯模糊的背景图
@property (nonatomic, strong) UIImageView *gaussianBlurOnMaskView;
//标题的view
@property (nonatomic, strong) UIView *titleView;
//标题
@property (nonatomic, strong) UILabel *titleLabel;
//描述的容器
@property (nonatomic, strong) UIView *messageContainerView;
//描述
@property (nonatomic, strong) UILabel *messageLabel;
//按钮的容器
@property (nonatomic, strong) UIView *btnContainerView;
//关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;
//取消按钮
@property (nonatomic, strong) UIButton *cancelBtn;
//按钮的集合
@property (nonatomic, strong) NSMutableArray *buttionList;

@property (nonatomic, copy) void(^handler)(NSInteger buttonIndex,id value);

@property (nonatomic, strong) UIView *logoContentView;

@property (nonatomic, strong) UIImageView *logoIV;

@property (nonatomic, strong) UIView *onView;

@end


@implementation CMPAlert

- (instancetype)initWithTitle:(nullable NSString *)title
                      message:(nullable NSString *)message
                     delegate:(id<CMPCustomAlertViewDelegate>)delegate
                    footStyle:(CMPAlertPublicFootStyle)footStyle
                    bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
            otherButtonTitles:(nullable NSArray <NSString *> *)otherButtonTitles
                      handler:(nullable void(^)(NSInteger buttonIndex,
                                                id value))handler{
    return [self initWithTitle:title message:message delegate:delegate footStyle:footStyle bodyStyle:bodyStyle cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles handler:handler onView:nil];
}

- (instancetype)initWithTitle:(nullable NSString *)title
                      message:(nullable NSString *)message
                     delegate:(id<CMPCustomAlertViewDelegate>)delegate
                    footStyle:(CMPAlertPublicFootStyle)footStyle
                    bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
            otherButtonTitles:(nullable NSArray <NSString *> *)otherButtonTitles
                      handler:(nullable void(^)(NSInteger buttonIndex,
                                                 id value))handler onView:(UIView * _Nullable)onView{
    
    self.onView = onView;
    UIView *currentView = (self.onView && [self.onView isKindOfClass:UIView.class]) ? self.onView : [CMPCustomAlertViewHelper currentViewController].view;
    self = [super initWithFrame:currentView.frame];
    
    if (!self) {
        return nil;
    }
    _lineList = @[].mutableCopy;
    _bodyLineList = @[].mutableCopy;
    _handler = handler;
    _footStyle = footStyle;
    _bodyStyle = bodyStyle;
    _delegate = delegate;
    _msg = message;
    _title = title;
    _backgroundColor = DefaultTranslucenceColor;
//    if (IS_PAD) {
//        _alterWidth = 300;
//    }else{//其他做iPhone处理
//        if (kDevice_Is_iPhone6Plus) {
//            _alterWidth = 290;
//        }else if (kDevice_Is_iPhoneX){
//            _alterWidth = 280;
//        }else if (kDevice_Is_iPhone6){
//            _alterWidth = 270;
//        }else{
//            _alterWidth = 260;
//        }
//    }
     _alterWidth = KAlterWidth;
    self.maskView.frame = currentView.frame;
    [self addSubview:_maskView];
    self.gaussianBlurOnMaskView.frame = currentView.frame;
    [_maskView addSubview:self.gaussianBlurOnMaskView];
    
    [self onPrepareTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
//    [self createLogoView];
    return self;
}
/**
 配合懒加载，即时即地show的时候，回调
 
 @param handler 回调
 */
- (void)showWindowWithHandler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler{
    _handler = handler;
    [self show];
}
//MARK:-- 显示
- (void)show{
    
    UIView *keyWindows = (self.onView && [self.onView isKindOfClass:UIView.class]) ? self.onView : [CMPCustomAlertViewHelper getWindow];
    [keyWindows addSubview:self];
    [self addConstraint:NSLayoutAttributeLeft equalTo:keyWindows offset:0];
    [self addConstraint:NSLayoutAttributeRight equalTo:keyWindows offset:0];
    [self addConstraint:NSLayoutAttributeTop equalTo:keyWindows offset:0];
    [self addConstraint:NSLayoutAttributeBottom equalTo:keyWindows offset:0];
    _isModal = NO;
    if (_setFrame == 0) {
        [self layoutIfNeeded];
    }else if (_setFrame == 1){
        
    }else if (_setFrame ==2){
        
    }
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.maskView.alpha = 1;
        weakSelf.alertView.alpha = 1;
    }];
    
}
- (void)showOnViewController{
    self.maskView.alpha = 1;
    self.alertView.alpha = 1;
    _isModal = YES;
    CMPContainerViewController *conVC = [CMPContainerViewController new];
    conVC.alertView = self;
    conVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    conVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[CMPCustomAlertViewHelper currentViewController] presentViewController:conVC animated:YES completion:nil];
}
- (void)hiddenAlertView{
    __weak typeof(self)weakSelf = self;
    
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.8 options:0 animations:^{
        weakSelf.maskView.alpha = 0.0f;
        weakSelf.alertView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}
//MARK: ------- ------------- buttion_Action ---------------------
- (void)buttionClick:(UIButton *)btn{
    [self hiddenAlertView];
    if (_isModal) {
        [[CMPCustomAlertViewHelper currentViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    if (_handler) {
        _handler(btn.tag - 100,btn.titleLabel.text);
    }
    if (_delegate &&
        [_delegate respondsToSelector:@selector(didClickAlertView:value:)]) {
        [_delegate didClickAlertView:btn.tag - 100 value:btn.titleLabel.text];
    }
}

//MARK: --------------------- private method ------------------------
//准备布局
- (void)onPrepareTitle:(nullable NSString *)title
                 message:(nullable NSString *)message
       cancelButtonTitle:(nullable NSString *)cancelButtonTitle
       otherButtonTitles:(nullable NSArray <NSString *> *)otherButtonTitles{
    
    CGFloat x = (CMPAlertScreenW - _alterWidth)/2;
    UIView *alert = [[UIView alloc] initWithFrame:CGRectMake(x, (CMPAlertScreenH-300)/2, _alterWidth , 300)];
    alert.backgroundColor = DefaultTranslucenceColor;
    alert.layer.cornerRadius = 6.0f;
    alert.layer.masksToBounds = YES;
    [self addSubview:alert];
    _alertView = alert;

    UIImageView *bgIV = [UIImageView new];
    bgIV.contentMode = UIViewContentModeScaleAspectFill;
    bgIV.backgroundColor = [UIColor redColor];
    bgIV.hidden = YES;
    [alert addSubview:bgIV];
    _backgroundAlterView = bgIV;

    // titleView
    UIView *titleView = self.titleView;
    [alert addSubview:titleView];
    
    [titleView addConstraint:NSLayoutAttributeLeft equalTo:alert offset:0];
    [titleView addConstraint:NSLayoutAttributeRight equalTo:alert offset:0];
    [titleView addConstraint:NSLayoutAttributeTop equalTo:alert offset:0];

    if (title && title.length > 0) {
        
        [titleView addSubview:self.titleLabel];
        self.titleLabel.text = title;
        
        [self getDefalutTitle:titleView offset:15];

        [titleView addSubview:self.closeBtn];
        [self.closeBtn addConstraint:NSLayoutAttributeRight equalTo:_titleView offset:-10];
        [self.closeBtn addConstraint:NSLayoutAttributeCenterY equalTo:_titleView offset:0];
        [self.closeBtn addConstraint:NSLayoutAttributeHeight equalTo:nil offset:20];
        [self.closeBtn addConstraint:NSLayoutAttributeWidth equalTo:nil offset:20];
        
        UIView *lineTitle = ({
            lineTitle = [UIView new];
            lineTitle.backgroundColor = DefaultLineTranslucenceColor;
            lineTitle.tag = kLineTitleTag;
            [titleView addSubview:lineTitle];
            lineTitle;
        });
        [_bodyLineList addObject:lineTitle];
        
        [lineTitle addConstraint:NSLayoutAttributeLeft equalTo:titleView offset:0];
        [lineTitle addConstraint:NSLayoutAttributeRight equalTo:titleView offset:0];
        [lineTitle addConstraint:NSLayoutAttributeBottom equalTo:titleView offset:0];
        [lineTitle addConstraint:NSLayoutAttributeHeight equalTo:nil offset:1];
        
        
        [titleView addConstraint:NSLayoutAttributeHeight equalTo:self.titleLabel offset:31];

    }else{
        
        [titleView addSubview:self.titleLabel];
        
        [self getDefalutTitle:titleView offset:0];
        
        UIView *lineTitle = ({
            lineTitle = [UIView new];
            lineTitle.backgroundColor = [UIColor clearColor];
            lineTitle.tag = kLineTitleTag;
            [titleView addSubview:lineTitle];
            lineTitle;
        });
        [_bodyLineList addObject:lineTitle];

        [lineTitle addConstraint:NSLayoutAttributeLeft equalTo:titleView offset:0];
        [lineTitle addConstraint:NSLayoutAttributeRight equalTo:titleView offset:0];
        [lineTitle addConstraint:NSLayoutAttributeBottom equalTo:titleView offset:0];
        [lineTitle addConstraint:NSLayoutAttributeHeight equalTo:nil offset:1];
        
        
        [titleView addConstraint:NSLayoutAttributeHeight equalTo:self.titleLabel offset:1];

        
    }
    

    // BodyView
    UIView *bodyView = [[UIView alloc] init];
    bodyView.backgroundColor = DefaultTranslucenceColor;
    [alert addSubview:bodyView];
    _messageContainerView = bodyView;
    
    [bodyView addConstraint:NSLayoutAttributeLeft equalTo:alert offset:0];
    [bodyView addConstraint:NSLayoutAttributeRight equalTo:alert offset:0];
    [bodyView addConstraint:NSLayoutAttributeTop equalTo:titleView toAttribute:NSLayoutAttributeBottom  offset:0];
    
  if (_bodyStyle == CMPAlertPublicBodyStyleCustom){
        UIView *lineBoad = ({
            lineBoad = [UIView new];
            lineBoad.backgroundColor = DefaultLineTranslucenceColor;
            [bodyView addSubview:lineBoad];
            lineBoad;
        });
        [_bodyLineList addObject:lineBoad];
        
        [lineBoad addConstraint:NSLayoutAttributeLeft equalTo:bodyView offset:0];
        [lineBoad addConstraint:NSLayoutAttributeRight equalTo:bodyView offset:0];
        [lineBoad addConstraint:NSLayoutAttributeBottom equalTo:bodyView offset:0];
        [lineBoad addConstraint:NSLayoutAttributeHeight equalTo:nil offset:1];
        
  }  else {//其他情况均做默认情况处理
      if (message && message.length > 0) {
          
          UIView *lineBoad = ({
              lineBoad = [UIView new];
              lineBoad.backgroundColor = DefaultLineTranslucenceColor;
              [bodyView addSubview:lineBoad];
              lineBoad;
          });
          [_bodyLineList addObject:lineBoad];
          
          [lineBoad addConstraint:NSLayoutAttributeLeft equalTo:bodyView offset:0];
          [lineBoad addConstraint:NSLayoutAttributeRight equalTo:bodyView offset:0];
          [lineBoad addConstraint:NSLayoutAttributeBottom equalTo:bodyView offset:0];
          [lineBoad addConstraint:NSLayoutAttributeHeight equalTo:nil offset:1];
          
          
          if (!title || title.length <= 0) {

              [self getDefalutBody:bodyView text:message value:18];

              [bodyView addConstraint:NSLayoutAttributeHeight equalTo:nil toAttribute:NSLayoutAttributeHeight offset:KAlterMinBodyHeight relatedBy:NSLayoutRelationGreaterThanOrEqual multiplier:1.0];
              [bodyView addConstraint:NSLayoutAttributeHeight equalTo:nil toAttribute:NSLayoutAttributeHeight offset:KAlterMaxBodyHeight relatedBy:NSLayoutRelationLessThanOrEqual multiplier:1.0];
              
          }else{
              [self getDefalutBody:bodyView text:message value:10];
              [bodyView addConstraint:NSLayoutAttributeHeight equalTo:self.messageLabel offset:20 + 1];
          }
          
      }else{
          //测试代码
          [self getDefalutBody:bodyView text:message value:0];
          [bodyView addConstraint:NSLayoutAttributeHeight equalTo:self.messageLabel offset:0];

      }
      
  }
    
    
    // BodyView
    UIView *btnView = [[UIView alloc] init];
    btnView.backgroundColor = DefaultTranslucenceColor;

    [alert addSubview:btnView];
    _btnContainerView = btnView;
    
    [btnView addConstraint:NSLayoutAttributeLeft equalTo:alert offset:0];
    [btnView addConstraint:NSLayoutAttributeRight equalTo:alert offset:0];
    [btnView addConstraint:NSLayoutAttributeTop equalTo:bodyView toAttribute:NSLayoutAttributeBottom offset:0];
    switch (_footStyle) {
        case CMPAlertPublicFootStyleDefalut:
            [self getDefalutFootView:otherButtonTitles cancelButtonTitle:cancelButtonTitle];
            break;
        case CMPAlertPublicFootStyleVertical:
            [self getVerticalFootView:otherButtonTitles cancelButtonTitle:cancelButtonTitle];
            break;
        case CMPAlertPublicFootStyleSegmentation:
            [self getSegmentationFootView:otherButtonTitles cancelButtonTitle:cancelButtonTitle];
            break;
        default:
            [self getDefalutFootView:otherButtonTitles cancelButtonTitle:cancelButtonTitle];
            break;
    }
    
    [_backgroundAlterView addConstraint:NSLayoutAttributeTop equalTo:self.alertView offset:0];
    [_backgroundAlterView addConstraint:NSLayoutAttributeBottom equalTo:self.alertView offset:0];
    [_backgroundAlterView addConstraint:NSLayoutAttributeLeft equalTo:self.alertView offset:0];
    [_backgroundAlterView addConstraint:NSLayoutAttributeRight equalTo:self.alertView offset:0];

   
  
}
- (void)getDefalutTitle:(UIView *)titleView offset:(CGFloat)offset{
    
    [self.titleLabel addConstraint:NSLayoutAttributeTop equalTo:titleView toAttribute:NSLayoutAttributeTop offset:offset];
    [self.titleLabel addConstraint:NSLayoutAttributeLeft equalTo:titleView offset:10];
    [self.titleLabel addConstraint:NSLayoutAttributeRight equalTo:titleView offset:-10];
    
}
- (void)getDefalutBody:(UIView *)bodyView
                  text:(NSString *)text
                  value:(CGFloat)value{
    self.messageLabel.text = text;
    [bodyView addSubview:self.messageLabel];

//    [self.messageLabel addConstraint:NSLayoutAttributeTop equalTo:bodyView toAttribute:NSLayoutAttributeTop offset:value];
    [self.messageLabel addConstraint:NSLayoutAttributeCenterX equalTo:bodyView toAttribute:NSLayoutAttributeCenterX offset:0];
    [self.messageLabel addConstraint:NSLayoutAttributeCenterY equalTo:bodyView toAttribute:NSLayoutAttributeCenterY offset:0];
    [self.messageLabel addConstraint:NSLayoutAttributeTop equalTo:bodyView toAttribute:NSLayoutAttributeTop offset:20 relatedBy:NSLayoutRelationGreaterThanOrEqual multiplier:1.0];
    [self.messageLabel addConstraint:NSLayoutAttributeBottom equalTo:bodyView toAttribute:NSLayoutAttributeBottom offset:-20 relatedBy:NSLayoutRelationGreaterThanOrEqual multiplier:1.0];
    [self.messageLabel addConstraint:NSLayoutAttributeLeft equalTo:bodyView offset:30];
    [self.messageLabel addConstraint:NSLayoutAttributeRight equalTo:bodyView offset:-30];
}


- (void)getSegmentationFootView:(NSArray <NSString *>*)otherButtonTitles
          cancelButtonTitle:(NSString *)cancelButtonTitle{
    
    int count = (int)otherButtonTitles.count;
    
    if ((cancelButtonTitle && cancelButtonTitle.length > 0) || otherButtonTitles.count > 0) {
        
        [_btnContainerView addConstraint:NSLayoutAttributeHeight equalTo:nil offset:btnHeight + 10];

        CGFloat startValue = 30;
        CGFloat middleValue = 20;
        if (cancelButtonTitle && cancelButtonTitle.length > 0) {
            UIButton *cancelBtn = self.cancelBtn;
            [cancelBtn setTitle:cancelButtonTitle forState:UIControlStateNormal];
            [_btnContainerView addSubview:cancelBtn];
            [self.buttionList addObject:cancelBtn];
            cancelBtn.backgroundColor = [UIColor redColor];
            [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            cancelBtn.clipsToBounds = YES;
            cancelBtn.layer.cornerRadius = 8;

            if (otherButtonTitles.count > 0) {
                CGFloat w = (_alterWidth -  count * middleValue - startValue * 2)/(count+1);
                cancelBtn.frame = CGRectMake(startValue, 5, w, btnHeight);
                [self createSpectOtherBtn:otherButtonTitles originX:CGRectGetMaxX(cancelBtn.frame) + middleValue width:w height:btnHeight value:middleValue];
            }else{
                cancelBtn.frame = CGRectMake(startValue, 5, _alterWidth, btnHeight);
            }
        }else{
            CGFloat w = (_alterWidth -  (count - 1) * middleValue - startValue * 2)/count;
            [self createSpectOtherBtn:otherButtonTitles originX:startValue width:w height:btnHeight  value:middleValue];
        }
        
    }else{
        [_btnContainerView addConstraint:NSLayoutAttributeHeight equalTo:nil offset:0];
        [_btnContainerView layoutIfNeeded];
    }
    
}
/**
 CMPAlertPublicStyleVertical的footView

 @param otherButtonTitles 按钮集合
 @param cancelButtonTitle 取消的按钮名称
 */
- (void)getVerticalFootView:(NSArray <NSString *>*)otherButtonTitles
          cancelButtonTitle:(NSString *)cancelButtonTitle{
    
    if ((cancelButtonTitle && cancelButtonTitle.length > 0) || otherButtonTitles.count > 0) {
        
        CGFloat origin = [self createVerticalOtherBtn:otherButtonTitles height:btnHeight];
        
        if (cancelButtonTitle && cancelButtonTitle.length > 0) {
            UIButton *cancelBtn = self.cancelBtn;
            [self.buttionList addObject:cancelBtn];
            if (origin != 0) {
                UIView *lineView = [UIView new];
                lineView.backgroundColor = DefaultLineTranslucenceColor;
                lineView.frame = CGRectMake(0, origin, _alterWidth, 1);
                [_btnContainerView addSubview:lineView];
                [_lineList addObject:lineView];
                cancelBtn.frame = CGRectMake(0, CGRectGetMaxY(lineView.frame), _alterWidth, btnHeight);
                origin = origin + 1 + btnHeight;
            }else{
                cancelBtn.frame = CGRectMake(0, 0, _alterWidth, btnHeight);
                origin = origin + btnHeight;
            }
            [cancelBtn setTitle:cancelButtonTitle forState:UIControlStateNormal];
            [_btnContainerView addSubview:cancelBtn];
        }
        [_btnContainerView addConstraint:NSLayoutAttributeHeight equalTo:nil offset:origin];
    }else{
        [_btnContainerView addConstraint:NSLayoutAttributeHeight equalTo:nil offset:0];
    }

}
- (CGFloat)createVerticalOtherBtn:(NSArray <NSString *>*)otherButtonTitles
                           height:(CGFloat)height{
    int i = 0;
    CGFloat width = _alterWidth;
    CGFloat originY = 0;
    for (NSString *btnTitle in otherButtonTitles) {
        UIButton *otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        otherBtn.tag = 101 + i;
        otherBtn.frame = CGRectMake(0, i * (height + 1), width, height);
        otherBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [otherBtn setTitle:btnTitle forState:UIControlStateNormal];
        [otherBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [otherBtn addTarget:self action:@selector(buttionClick:) forControlEvents:UIControlEventTouchUpInside];
        [_btnContainerView addSubview:otherBtn];
        [self.buttionList addObject:otherBtn];
        if (i < otherButtonTitles.count - 1) {
            UIView *lineView = [UIView new];
            lineView.frame = CGRectMake(0, CGRectGetMaxY(otherBtn.frame), width, 1);
            lineView.backgroundColor = DefaultLineTranslucenceColor;
            [_btnContainerView addSubview:lineView];
            [_lineList addObject:lineView];
        }else{
            originY = CGRectGetMaxY(otherBtn.frame);
        }
        i ++;
    }
    return originY;
}
/**
 获取默认的footView(横排的一组buttion)

 @param otherButtonTitles buttion集合
 @param cancelButtonTitle 取消buttion的title
 */
- (void)getDefalutFootView:(NSArray <NSString *>*)otherButtonTitles
         cancelButtonTitle:(NSString *)cancelButtonTitle{
    
    int count = (int)otherButtonTitles.count;
    
    if ((cancelButtonTitle && cancelButtonTitle.length > 0) || otherButtonTitles.count > 0) {
        
        [_btnContainerView addConstraint:NSLayoutAttributeHeight equalTo:nil offset:btnHeight];
        
        if (cancelButtonTitle && cancelButtonTitle.length > 0) {
            UIButton *cancelBtn = self.cancelBtn;
            [cancelBtn setTitle:cancelButtonTitle forState:UIControlStateNormal];
            [_btnContainerView addSubview:cancelBtn];
            [self.buttionList addObject:cancelBtn];
            if (otherButtonTitles.count > 0) {
                CGFloat w = (_alterWidth -  count)/(count+1);
                cancelBtn.frame = CGRectMake(0, 0, w, btnHeight);
                UIView *lineView = [UIView new];
                lineView.backgroundColor = DefaultLineTranslucenceColor;
                lineView.frame = CGRectMake(CGRectGetMaxX(cancelBtn.frame), (btnHeight - kBtnLineHeight) * 0.5 , 1, kBtnLineHeight);
                [_btnContainerView addSubview:lineView];
                [_lineList addObject:lineView];
                [self createDefalutOtherBtn:otherButtonTitles originX:CGRectGetMaxX(lineView.frame) width:w height:btnHeight];
                
            }else{
                cancelBtn.frame = CGRectMake(0, 0, _alterWidth, btnHeight);
            }
            
        }else{
            CGFloat w = (_alterWidth -  (count - 1))/count;
            [self createDefalutOtherBtn:otherButtonTitles originX:0 width:w height:btnHeight];
        }
        
    }else{
        [_btnContainerView addConstraint:NSLayoutAttributeHeight equalTo:nil offset:0];
    }
    
}
//MARK: --- 创建一排的按钮
- (void)createDefalutOtherBtn:(NSArray <NSString *>*)otherButtonTitles
               originX:(CGFloat)x
                 width:(CGFloat)width
                       height:(CGFloat)height{
    int i = 0;
    for (NSString *btnTitle in otherButtonTitles) {
        UIButton *otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        otherBtn.tag = 101 + i;
        otherBtn.frame = CGRectMake(x + (i*(width+1)), 0, width, height);
        otherBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [otherBtn setTitle:btnTitle forState:UIControlStateNormal];
        [otherBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [otherBtn addTarget:self action:@selector(buttionClick:) forControlEvents:UIControlEventTouchUpInside];
        [_btnContainerView addSubview:otherBtn];
        [self.buttionList addObject:otherBtn];

        if (i < otherButtonTitles.count - 1) {
            UIView *lineView = [UIView new];
            lineView.frame = CGRectMake(CGRectGetMaxX(otherBtn.frame), 0, 1, height);
            lineView.backgroundColor = DefaultLineTranslucenceColor;
            [_btnContainerView addSubview:lineView];
            [_lineList addObject:lineView];

        }
        i ++;
    }
}
- (void)createSpectOtherBtn:(NSArray <NSString *>*)otherButtonTitles
                    originX:(CGFloat)x
                    width:(CGFloat)width
                     height:(CGFloat)height
                      value:(CGFloat)value{
    int i = 0;
    for (NSString *btnTitle in otherButtonTitles) {
        UIButton *otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        otherBtn.tag = 101 + i;
        otherBtn.frame = CGRectMake(x + (i*(width+value)), 5, width, height);
        otherBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [otherBtn setTitle:btnTitle forState:UIControlStateNormal];
        otherBtn.backgroundColor = [UIColor blueColor];
        otherBtn.clipsToBounds = YES;
        otherBtn.layer.cornerRadius = 8;
        [otherBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [otherBtn addTarget:self action:@selector(buttionClick:) forControlEvents:UIControlEventTouchUpInside];
        [_btnContainerView addSubview:otherBtn];
        [self.buttionList addObject:otherBtn];
        i ++;
    }
}
- (void)setAlertViewFrame{
    
    [self.titleView layoutIfNeeded];
    [self.messageContainerView layoutIfNeeded];
    [self.btnContainerView layoutIfNeeded];
    
    //更新alert内部布局约束
    CGFloat alertHeight = CGRectGetHeight(self.titleView.frame) + CGRectGetHeight(self.messageContainerView.frame) + CGRectGetHeight(self.btnContainerView.frame);
    
    if (_layAlertHeight) {
        _layAlertHeight.constant = alertHeight;
        [self.alertView setNeedsUpdateConstraints];
    }else{
        [self.alertView addConstraint:NSLayoutAttributeCenterX equalTo:self offset:0];
        [self.alertView addConstraint:NSLayoutAttributeCenterY equalTo:self offset:0];
        //    [self.alertView addConstraint:NSLayoutAttributeHeight equalTo:nil offset:alertHeight];
        [self.alertView addConstraint:NSLayoutAttributeWidth equalTo:nil offset:_alterWidth];
        _layAlertHeight = [self.alertView addConstraintAndReturn:NSLayoutAttributeHeight equalTo:nil toAttribute:NSLayoutAttributeHeight offset:alertHeight];
    }
    _setFrame = 2;
}
- (void)createLogoView{
    self.logoContentView.backgroundColor = [UIColor clearColor];
    self.logoContentView.clipsToBounds = YES;
    self.logoContentView.layer.cornerRadius = 25;
    self.logoIV.backgroundColor = [UIColor clearColor];
    [self addSubview:self.logoContentView];
    [self.logoContentView addSubview:self.logoIV];
    
    [self.logoContentView addConstraint:NSLayoutAttributeCenterX equalTo:self toAttribute:NSLayoutAttributeCenterX offset:0];
    [self.logoContentView addConstraint:NSLayoutAttributeBottom equalTo:self.alertView toAttribute:NSLayoutAttributeTop offset:20];
    [self.logoContentView addConstraint:NSLayoutAttributeWidth equalTo:nil toAttribute:NSLayoutAttributeWidth offset:50];
    [self.logoContentView addConstraint:NSLayoutAttributeHeight equalTo:nil toAttribute:NSLayoutAttributeHeight offset:50];
    
    [self.logoIV addConstraint:NSLayoutAttributeCenterX equalTo:self.logoContentView toAttribute:NSLayoutAttributeCenterX offset:0];
    [self.logoIV addConstraint:NSLayoutAttributeCenterY equalTo:self.logoContentView toAttribute:NSLayoutAttributeCenterY offset:0];
    [self.logoIV addConstraint:NSLayoutAttributeWidth equalTo:nil toAttribute:NSLayoutAttributeWidth offset:50];
    [self.logoIV addConstraint:NSLayoutAttributeHeight equalTo:nil toAttribute:NSLayoutAttributeHeight offset:50];

}
//MARK: ------------------------ 配置信息 -------------------------------
- (void)setAlertViewBackgroundColor:(UIColor *)color{
    _backgroundColor = color;
    self.alertView.backgroundColor = _backgroundColor;
    self.titleView.backgroundColor = _backgroundColor;
    self.messageContainerView.backgroundColor = _backgroundColor;
    self.btnContainerView.backgroundColor = _backgroundColor;
}
- (void)showCloseOnTitleView{
    if([UIScreen mainScreen].scale == 2.0) {
        [self.closeBtn setImage:[UIImage getImageOnBundle:@"cmp_alter_close@2x" ofType:@"png" forClass:[self class]] forState:UIControlStateNormal];
    }else if ([UIScreen mainScreen].scale == 3.0){
        [self.closeBtn setImage:[UIImage getImageOnBundle:@"cmp_alter_close@3x" ofType:@"png" forClass:[self class]] forState:UIControlStateNormal];
    }else{
        [self.closeBtn setImage:[UIImage getImageOnBundle:@"cmp_alter_close@2x" ofType:@"png" forClass:[self class]] forState:UIControlStateNormal];
    }
    self.closeBtn.hidden = NO;
}
- (void)hiddenAllLineView{
    for (UIView *line in _lineList) {
        line.backgroundColor = _backgroundColor;
    }
    [self hiddenBodyLineView];
}
- (void)hiddenBodyLineView{
    for (UIView *line in _bodyLineList) {
        line.backgroundColor = _backgroundColor;
    }
}
- (void)setTitleViewBackColor:(UIColor *)color{
    self.titleView.backgroundColor = color;
}
- (void)setTitleViewTitleColor:(UIColor *)color{
    self.titleLabel.textColor = color;
}
- (void)setMessageTitleColor:(UIColor *)color{
    self.messageLabel.textColor = color;
}
- (void)setAllButtionTitleColor:(UIColor *)color{
    for (UIButton *btn in self.buttionList) {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
}
- (void)setAllButtionTitleFont:(UIFont *)font{
    for (UIButton *btn in self.buttionList) {
        btn.titleLabel.font = font;
    }
}
- (void)setAllBodyLineColor:(UIColor *)color{
    NSString *title = self.titleLabel.text;
    for (UIView *line in _bodyLineList) {
        line.backgroundColor = color;
        if (line.tag == kLineTitleTag) {
            if (title && title.length > 0) {
                line.backgroundColor = color;
            } else {
                line.backgroundColor = [UIColor clearColor];
            }
        }
    }
}

- (void)setButtonLineColor:(UIColor *)color{
    for (UIView *line in _lineList) {
        line.backgroundColor = color;
    }
}

- (void)setButtionTitleColor:(UIColor *)color index:(NSInteger)index{
    UIButton *btn = [self.btnContainerView viewWithTag:100+index];
    if (btn) {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
}
- (void)setButtionTitleFontWithName:(NSString *)name
                               size:(CGFloat)size
                              index:(NSInteger)index{
    UIButton *btn = [self.btnContainerView viewWithTag:100+index];
    if (btn) {
        btn.titleLabel.font = [UIFont fontWithName:name size:size];
    }
}
- (void)setTitleFontWithName:(NSString *)name size:(CGFloat)size{
    if (name) {
        self.titleLabel.font = [UIFont fontWithName:name size:size];
    }else{
        self.titleLabel.font = [UIFont systemFontOfSize:size];
    }
}
- (void)setMessageFontWithName:(NSString *)name size:(CGFloat)size{
    if (name) {
        self.messageLabel.font = [UIFont fontWithName:name size:size];
    }else{
        self.messageLabel.font = [UIFont systemFontOfSize:size weight:UIFontWeightSemibold];
    }
}
- (void)setAlertBackgroundView:(UIImage *)image articulation:(CGFloat)articulation{
    _backgroundAlterView.hidden = NO;
    _backgroundAlterView.image = image;

    UIColor *newColor = [_backgroundColor colorWithAlphaComponent:articulation];
    self.titleView.backgroundColor = newColor;
    self.messageContainerView.backgroundColor = newColor;
    self.btnContainerView.backgroundColor = newColor;
    
}
/**
 设置蒙版的背景图
 
 @param image 蒙版的背景图（可使用高斯的image）
 */
- (void)setGaussianBlurImage:(UIImage *)image{
    self.gaussianBlurOnMaskView.hidden = NO;
    self.gaussianBlurOnMaskView.image = image;
}

/**
 设置蒙版的背景色
 
 @param color 蒙版的背景色
 */
- (void)setMaskViewBackgroundColor:(UIColor *)color{
    self.maskView.backgroundColor = color;
}

/**
 修改tiele（因为考虑到title,一般文字不是很多，所以高度不会变化，默认40）
 
 @param title 提示名称
 */
- (void)resetAlertTitle:(NSString *)title{
    if (!_title) {//测试代码
        NSString *msg = [NSString stringWithFormat:@"\r\n%@\r\n",title];
        self.titleLabel.text = msg;
        for (UIView *line in _bodyLineList) {
            if (line.tag == kLineTitleTag) {
                if (title && title.length > 0) {
                    line.backgroundColor = DefaultLineTranslucenceColor;
                } else {
                    line.backgroundColor = [UIColor clearColor];
                }
            }
        }
    }else{
        self.titleLabel.text = title;
        for (UIView *line in _bodyLineList) {
            if (line.tag == kLineTitleTag) {
                if (title && title.length > 0) {
                    line.backgroundColor = DefaultLineTranslucenceColor;
                } else {
                    line.backgroundColor = [UIColor clearColor];
                }
            }
        }
    }
    _setFrame = 1;
    [self setNeedsLayout];
}
//MARK:  ------------  专属协议方法（协议的私有方法）-----------------
- (void)setCustomBodyView:(UIView *)bodyView height:(CGFloat)height{
    [self.messageContainerView addSubview:bodyView];
    [bodyView addConstraint:NSLayoutAttributeTop equalTo:self.messageContainerView offset:0];
    [bodyView addConstraint:NSLayoutAttributeLeft equalTo:self.messageContainerView offset:5];
    [bodyView addConstraint:NSLayoutAttributeRight equalTo:self.messageContainerView offset:-5];
    [bodyView addConstraint:NSLayoutAttributeHeight equalTo:nil offset:height];
    [self.messageContainerView addConstraint:NSLayoutAttributeBottom equalTo:bodyView offset:1];
}
/**
 修改message信息，高度也会跟着适配
 
 @param message 信息
 */
- (void)resetAlertMessage:(NSString *)message{
    if (_bodyStyle != CMPAlertPublicBodyStyleCustom) {
        if (!_msg) {//测试代码
            NSString *msg = [NSString stringWithFormat:@"\r\n%@\r\n",message];
            self.messageLabel.text = msg;
        }else{
            self.messageLabel.text = message;
        }
        _setFrame = 1;
        [self setNeedsLayout];
    }
}
//MARK:  --------------- 统一参数配置/主题 ---------------------
- (void)setTheme:(id<CMPCustomAlertViewThemeProtocol>)theme{
   
    if ([theme respondsToSelector:@selector(alertBackgroundView)]) {
        UIImage *img = [theme alertBackgroundView];
        if (img) {
            CGFloat alp = 0;
            if ([theme respondsToSelector:@selector(alterBackgroundViewArticulation)]) {
               alp = [theme alterBackgroundViewArticulation];
            }
            [self setAlertBackgroundView:img articulation:alp];
        }
    }
    if ([theme respondsToSelector:@selector(alertTitleViewColor)]) {
        UIColor *titleColor = [theme alertTitleViewColor];
        if (titleColor) {
            self.titleLabel.textColor = titleColor;
        }
    }
    if ([theme respondsToSelector:@selector(alertAllButtonTitleColor)]) {
        [self setAllButtionTitleColor:[theme alertAllButtonTitleColor]];
    }
    if ([theme respondsToSelector:@selector(alertAllButtionTitleFont)]) {
        [self setAllButtionTitleFont:[theme alertAllButtionTitleFont]];
    }
    if ([theme respondsToSelector:@selector(alertAllBodyLineColor)]) {
        [self setAllBodyLineColor:[theme alertAllBodyLineColor]];
    }
    if ([theme respondsToSelector:@selector(alertButtonLineColor)]) {
        [self setButtonLineColor:[theme alertButtonLineColor]];
    }
    if ([theme respondsToSelector:@selector(alertCancelColor)]) {
       UIColor *cancelColor = [theme alertCancelColor];
        if (cancelColor) {
            [self.cancelBtn setTitleColor:cancelColor forState:UIControlStateNormal];
        }
    }
    if ([theme respondsToSelector:@selector(alertBackgroundColor)]) {
         UIColor *backgroundColor = [theme alertBackgroundColor];
        [self setAlertViewBackgroundColor:backgroundColor];
    }
    
    CGFloat alp1 = 16;
    if ([theme respondsToSelector:@selector(alertTitleFont)]) {
        alp1 = [theme alertTitleFont];
    }
    if ([theme respondsToSelector:@selector(alertTitleFontWithName)]) {
        [self setTitleFontWithName:[theme alertTitleFontWithName] size:alp1];
    }else{
        [self setTitleFontWithName:nil size:alp1];
    }
    CGFloat alp2 = 14;
    if ([theme respondsToSelector:@selector(alertMessageFont)]) {
        alp2 = [theme alertMessageFont];
    }
    if ([theme respondsToSelector:@selector(alertMessageFontWithName)]) {
        [self setMessageFontWithName:[theme alertMessageFontWithName] size:alp2];
    }else{
        [self setMessageFontWithName:nil size:alp2];
    }
    if ([theme respondsToSelector:@selector(maskViewBackgroundColor)]) {
        [self setMaskViewBackgroundColor:[theme maskViewBackgroundColor]];
    }

}

//MARK: ----------------------- getter & setter --------------------
- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.tag = 100;
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [_cancelBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(buttionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}
- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
       _maskView.backgroundColor =  [UIColor colorWithRed:10 / 255.0 green:10 / 255.0 blue:10 / 255.0 alpha:0.4];
       _maskView.alpha = 0;
    }
    return _maskView;
}
- (UIImageView *)gaussianBlurOnMaskView{
    if (!_gaussianBlurOnMaskView) {
        _gaussianBlurOnMaskView = [UIImageView new];
        _gaussianBlurOnMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _gaussianBlurOnMaskView.hidden = YES;
    }
    return _gaussianBlurOnMaskView;
}

- (UIView *)titleView{
    if (!_titleView) {
        _titleView = [UIView new];
        _titleView.backgroundColor = DefaultTranslucenceColor;
    }
    return _titleView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}
- (UILabel *)messageLabel{
    if (!_messageLabel) {
        _messageLabel = [UILabel new];
        [_messageLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont systemFontOfSize:15];
    }
    return _messageLabel;
}
- (UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn addTarget:self action:@selector(hiddenAlertView) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.hidden = YES;
    }
    return _closeBtn;
}
- (UIView *)logoContentView{
    if (!_logoContentView) {
        _logoContentView = [UIView new];
    }
    return _logoContentView;
}
- (UIImageView *)logoIV{
    if (!_logoIV) {
        _logoIV = [UIImageView new];
    }
    return _logoIV;
}

- (NSMutableArray *)buttionList{
    if (!_buttionList) {
        _buttionList = [NSMutableArray new];
    }
    return _buttionList;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [self setAlertViewFrame];
    self.maskView.frame = self.bounds;
    self.gaussianBlurOnMaskView.frame = self.maskView.bounds;
    NSLog(@"%s",__func__);
}

- (void)dealloc{
    NSLog(@"%s",__func__);
    _lineList = nil;
    _bodyLineList = nil;
    _maskView = nil;
    _alertView = nil;
    _gaussianBlurOnMaskView = nil;
    _titleView = nil;
    _titleLabel = nil;
    _messageContainerView = nil;
    _messageLabel = nil;
    _btnContainerView = nil;
    _closeBtn = nil;
    _cancelBtn = nil;
    _buttionList = nil;
    _backgroundAlterView = nil;
    _backgroundColor = nil;
}
@synthesize onView;

@end
