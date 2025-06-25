//
//  CMPCopDrawerModel.h
//  M3
//
//  Created by Shoujian Rao on 2023/12/13.
//

#import <Foundation/Foundation.h>


@interface CMPCopDrawerModel : NSObject

@property (copy, nonatomic) NSString *thumbImage;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *img;
@property (copy, nonatomic) NSString *type;

@property (assign, nonatomic) BOOL secondFloor;//是否已添加到二楼

@property (copy, nonatomic) NSString *localPath;//应用包图片地址

@property (copy, nonatomic) NSString *statusText;
@property (copy, nonatomic) NSString *statusTextColor;

@property (copy, nonatomic) NSDictionary *param;

@property (assign, nonatomic)BOOL stayIn;

- (void)mapModel;
@end

