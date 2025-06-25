//
//  XZTextTapModel.h
//  M3
//
//  Created by wujiansheng on 2017/12/2.
//

typedef enum{
    XZTextTapTypeNormal = 0,
    XZTextTapTypeDownload = 1,
    XZTextTapTypeLink = 2,
    XZTextTapTypeAPP = 3,

}XZTextTapType;



#import <Foundation/Foundation.h>
@interface XZTextTapModel : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *valueStr;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) XZTextTapType tapType;
@end
