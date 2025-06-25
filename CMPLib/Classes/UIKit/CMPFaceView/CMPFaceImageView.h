//
//  CMPFaceImageView.h
//  CMPCore
//
//  Created by wujiansheng on 16/9/6.
//
//

#import <UIKit/UIKit.h>

@interface CMPFaceImageView : UIImageView{
    NSString    *memberId_;
    NSInteger   type;
}

@property(nonatomic,copy)NSString		*memberId;
@property(nonatomic,assign)NSInteger    type;
@property(nonatomic, retain)UIColor     *circularColor;


@end
