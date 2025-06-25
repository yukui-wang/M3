//
//  SyVisualizer.h
//  M1Core
//
//  Created by wujs on 13-1-15.
//
// 视图形象地显示了录音过程


#import "CMPBaseView.h"

@interface CMPVisualizer : CMPBaseView {
    NSMutableArray	*powers;		// 录音中的能量等级记录
    float			minPower;		// 最低的录音能量等级
}


// 设置powerLevel
- (void)setPower:(float)p;

// * 清空所有能量等级记录
- (void)clear;



@end
