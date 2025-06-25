//
//  XZTextInfoModel.h
//  M3
//
//  Created by wujiansheng on 2017/12/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface XZTextInfoModel : NSObject
@property (nonatomic, retain) id  info;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, retain) NSMutableArray *tapModel;
@property (nonatomic, copy) void (^reloadTextBlock)(void);

@end
