//
//  XZShortHandBar.h
//  M3
//
//  Created by wujiansheng on 2019/1/11.
//

#import <CMPLib/CMPBaseView.h>

@interface XZShortHandBar : CMPBaseView
@property(nonatomic, retain)UIButton *fontBtn;//字号大小
@property(nonatomic, retain)UIButton *boldBtn;//粗体
@property(nonatomic, retain)UIButton *italicBtn;//斜体
@property(nonatomic, retain)UIButton *pointBtn;//换行。
@property(nonatomic, retain)UIButton *numberBtn;//换行123
@property(nonatomic, retain)UIButton *replaceBtn;//替换
@property(nonatomic, retain)UIButton *voiceBtn;

@end

