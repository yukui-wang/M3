//
//  CMPServerListView.h
//  M3
//
//  Created by CRMO on 2017/10/30.
//

#import <UIKit/UIKit.h>

@interface CMPServerListView : UIView

@property (nonatomic, strong) void (^saveAction)(void);
@property (nonatomic, strong) UITableView *table;

@end
