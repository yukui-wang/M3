//
//  MegFaceEENotification.h
//  MegFaceEE
//
//  Created by Megvii on 2023/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegFaceEENotification : NSObject

@property (nonatomic, strong) NSString *notificationId;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, assign) NSInteger expiresIn;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *site;
@property (nonatomic, strong) NSString *endpoint;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, assign) NSInteger createdAt;

@end

NS_ASSUME_NONNULL_END
