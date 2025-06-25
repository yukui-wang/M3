//
//  WTRecorderWave.m
//  WTEnjoyVoice
//
//  Created by zeb on 17/2/14.
//  Copyright © 2017年 zeb. All rights reserved.
//

#import "XZRecorderWave.h"
#import "XZWaves.h"

@interface XZRecorderWave () {
   
}
@property (nonatomic,retain)XZWaves *ware_1;
@property (nonatomic,retain)XZWaves *ware_2;
@property (nonatomic,retain)XZWaves *ware_3;
@property (nonatomic,retain)XZWaves *ware_4;

//@property (nonatomic,retain)XZSecondWaves *secondWare;
@end


@implementation XZRecorderWave

- (void)dealloc
{
    [self.ware_1 stop];
    [self.ware_2 stop];
    [self.ware_3 stop];
    [self.ware_4 stop];
    self.ware_1 = nil;
    self.ware_2 = nil;
    self.ware_3 = nil;
    self.ware_4 = nil;
}

- (void)setup
{
    self.backgroundColor = UIColorFromRGB(0xf2f5f7);
    UIColor *color = UIColorFromRGB(0x3aafb);
    //第一个波浪
    if (!_ware_1) {
        _ware_1 = [[XZWaves alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        self.ware_1.wavesColor = color;
        [self addSubview:self.ware_1];
    }
    if (!_ware_2) {
        _ware_2 = [[XZWaves alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        self.ware_2.wavesColor = color;
        [self addSubview:self.ware_2];
    }
    if (!_ware_3) {
        _ware_3 = [[XZWaves alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        self.ware_3.wavesColor = color;
        [self addSubview:self.ware_3];
    }
    if (!_ware_4) {
        _ware_4 = [[XZWaves alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        self.ware_4.wavesColor = color;
        [self addSubview:self.ware_4];
    }
    
    self.ware_1.alpha= 0.2;
    self.ware_2.alpha= 0.3;
    self.ware_3.alpha= 0.4;
    self.ware_4.alpha= 0.5;
   
    self.ware_1.sin = YES;
    self.ware_3.sin = YES;
    
    self.ware_3.wavesSpeed = self.ware_1.wavesSpeed *2;
    self.ware_4.wavesSpeed = self.ware_2.wavesSpeed *2;

    [self.ware_1 show];
    [self.ware_2 show];
    [self.ware_3 show];
    [self.ware_4 show];

}

- (void)customLayoutSubviews {
    self.ware_1.frame = CGRectMake(0, 0, self.width, self.height);
    self.ware_2.frame = CGRectMake(0, 0, self.width, self.height);
    self.ware_3.frame = CGRectMake(0, 0, self.width, self.height);
    self.ware_4.frame = CGRectMake(0, 0, self.width, self.height);
}


@end
