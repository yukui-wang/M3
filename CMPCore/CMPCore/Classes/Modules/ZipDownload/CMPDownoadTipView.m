//
//  CMPDownoadTipView.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2024/1/3.
//

#import "CMPDownoadTipView.h"
#import <CMPLib/KSLabel.h>

@interface CMPDownoadTipView()
{
    UIEdgeInsets _tipEdge;
}
@property (nonatomic,strong)KSLabel *tipLb;
@property (nonatomic,strong) UIImageView *directionView;
@end

@implementation CMPDownoadTipView

-(instancetype)init
{
    if (self = [super init]) {
        _basePoint = CGPointMake(CMP_SCREEN_WIDTH/2, CMP_SCREEN_HEIGHT/2);
        _tipEdge = UIEdgeInsetsMake(8, 6, 8, 6);
        _tipLb = [[KSLabel alloc] init];
        _tipLb.textColor = [UIColor whiteColor];
        _tipLb.backgroundColor = [UIColor cmp_colorWithName:@"dark-bgc2"];
        _tipLb.layer.cornerRadius = 4;
        _tipLb.layer.masksToBounds = YES;
        _tipLb.font = [UIFont systemFontOfSize:14];
        _tipLb.edgeInsets = _tipEdge;
        _tipLb.numberOfLines = 0;
        _tipLb.textAlignment = NSTextAlignmentCenter;
        [_tipLb sizeToFit];
        [self addSubview:_tipLb];
        
        _directionView = [[UIImageView alloc] init];
        [self addSubview:_directionView];
        self.direction = 0;
        
        self.alpha = 0;
    }
    return self;
}

-(void)showInfo:(NSString *)info
{
    if (!info || info.length == 0) return;
    _tipLb.text = info;
    [_tipLb sizeToFit];
    self.alpha = 1;
    self.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    });
}

-(void)setDirection:(NSInteger)direction{
    _direction = direction;
    switch (_direction) {
        case 1:
            [_directionView setImage:[UIImage cmp_autoImageNamed:@"arr_2"]];
            break;
            
        default:
            [_directionView setImage:[UIImage cmp_autoImageNamed:@"arr_1"]];
            break;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat w = _maxWidth>0&&_maxWidth<CMP_SCREEN_WIDTH ? _maxWidth : CMP_SCREEN_WIDTH;
    CGSize fitsize = [_tipLb.text sizeWithFontSize:[UIFont systemFontOfSize:14] defaultSize:CGSizeMake(w-_tipEdge.left-_tipEdge.right, MAXFLOAT)];
    CGSize tipS = CGSizeMake(fitsize.width+_tipEdge.left+_tipEdge.right, fitsize.height+_tipEdge.top+_tipEdge.bottom);
    
    switch (_direction) {
        case 1:{
            CGFloat botSpc = 0;
            CGSize arrS = CGSizeMake(6, 10);
            CGRect f = CGRectMake(_basePoint.x+botSpc, _basePoint.y-tipS.height/2, tipS.width+arrS.width, tipS.height);
            self.frame = f;
            _tipLb.frame = CGRectMake(arrS.width, 0, tipS.width, tipS.height);
            _directionView.frame = CGRectMake(0, (f.size.height-arrS.height)/2, arrS.width, arrS.height);
        }
            break;

        default:{
            CGFloat botSpc = 0;
            CGSize arrS = CGSizeMake(10, 6);
            CGRect f = CGRectMake(_basePoint.x - w/2, _basePoint.y-botSpc-arrS.height-tipS.height, w, botSpc+arrS.height+tipS.height);
            self.frame = f;
            _tipLb.frame = CGRectMake(f.size.width/2-tipS.width/2, 0, tipS.width, tipS.height);
            _directionView.frame = CGRectMake(f.size.width/2-arrS.width/2, f.size.height-arrS.height-botSpc, arrS.width, arrS.height);
        }
            break;
    }
    
}


//-(void)drawRect:(CGRect)rect
//{
//    [[[UIColor whiteColor] colorWithAlphaComponent:0.1] setFill];
//    UIRectFill(rect);
//
//    CGFloat w = 20,h = 10,centerX = self.bounds.size.width/2,selfH = self.bounds.size.height;
//    UIColor *fillColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.9];
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(centerX, selfH)];
//    [path addLineToPoint:CGPointMake(centerX+w/2, selfH-h)];
//    [path addLineToPoint:CGPointMake(centerX-w/2, selfH-h)];
//    [path closePath];
//
//    path.lineWidth = 1.5;
//
//    [fillColor set];
//    [path fill];
//
//    UIColor *strokeColor = fillColor;
//    [strokeColor set];
//
//    [path stroke];
//}

@end
