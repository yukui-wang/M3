//
//  CMPShareFileView.h
//  M3
//
//  Created by MacBook on 2019/10/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPShareFileView : UIView

+ (instancetype)fileViewWithFrame:(CGRect)frame filePath:(NSString *)filePath shareFileCount:(NSInteger)shareFileCount;

/* type */
@property (copy, nonatomic) NSString *fileType;

@end

NS_ASSUME_NONNULL_END
