//
//  CMPServerListView.h
//  M3
//
//  Created by CRMO on 2017/10/30.
//

#import <UIKit/UIKit.h>
#import "CMPServerEditTableView.h"

@interface CMPServerListNewView : UIView

@property (nonatomic, strong) void (^saveAction)(void);
@property (nonatomic, strong) CMPServerEditTableView *table;

@end
