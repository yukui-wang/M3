//
//  SPSearchHelper.h
//  CMPCore
//
//  Created by CRMO on 2017/2/25.
//
//

#import <Foundation/Foundation.h>
#import "SPTools.h"
#import "SPSearchColModel.h"
#import "XZCellModel.h"
#import "SPWillDoneItemModel.h"
#import "SPSearchHelper.h"

@interface SPSearchColHelper : SPSearchHelper
@property(nonatomic, strong)NSDictionary *info;
@property(nonatomic, assign)NSInteger max;
@property(nonatomic, assign)BOOL isExpense;

@end
