//
//  CMPTabBarItemAttribute.h
//  CMPCore
//
//  Created by yang on 2017/2/13.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CMPTabBarItemAttributeDataSource) {
    CMPTabBarItemAttributeFromZip = 0, // 从zip获取
    CMPTabBarItemAttributeFromNetwork, // 从网络获取
};

@interface CMPTabBarItemAttribute : NSObject

/** 数据源 **/
@property (nonatomic, assign) CMPTabBarItemAttributeDataSource dataSource;
@property (nonatomic,copy) NSString *appAddress;
@property (nonatomic,copy) NSString *appID;
@property (nonatomic,copy) NSString *appKey;
@property (nonatomic,copy) NSString *version;
@property (nonatomic,copy) NSString *chTitle;
@property (nonatomic,copy) NSString *enTitle;
@property (nonatomic,copy) NSString *chHansTitle;
@property (nonatomic,copy) NSString *normalImage;
@property (nonatomic,copy) NSString *selectedImage;
@property (nonatomic,copy) NSString *normalImageUrl;
@property (nonatomic,copy) NSString *selectedImageUrl;
@property (nonatomic,copy) NSDictionary *app;
@property (nonatomic,copy) NSNumber *sortNum;
/** V7.1新增字段，item是否展示。低版本服务器默认展示。 **/
@property (assign, nonatomic) BOOL isShow;
@property (assign, nonatomic) BOOL isVisible;
/** V7.1新增字段，应用唯一ID **/
@property (copy, nonatomic) NSString *appUniqueId;

- (UIImage *)normalImg;
- (UIImage *)selectedImg;

@end

@interface CMPTabBarItemAttributeList : NSObject

@property (nonatomic, copy) NSArray<CMPTabBarItemAttribute *> *navBarList;
@property (nonatomic, copy) NSArray<CMPTabBarItemAttribute *> *expandNavBarList;

@end
