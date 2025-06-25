//
//  SyFaceDownloadRecordObj.h
//  M1Core
//
//  Created by guoyl on 13-5-2.
//  Copyright (c) 2013年 北京致远协创软件有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyFaceDownloadRecordObj : NSObject

@property(nonatomic, copy)NSString *extend1;
@property(nonatomic, copy)NSString *extend2;
@property(nonatomic, copy)NSString *extend3;
@property(nonatomic, copy)NSString *extend4;
@property(nonatomic, copy)NSString *extend5;

@property(nonatomic, copy)NSString *memberId;
@property(nonatomic, copy)NSString *serverId;
@property(nonatomic, copy)NSString *savePath;
@property(nonatomic, copy)NSString *downloadUrlMd5;

- (NSString *)fullSavePath;

@end

@interface SyFaceDownloadObj : NSObject
@property(nonatomic, copy)NSString *memberId;
@property(nonatomic, copy)NSString *serverId;
@property(nonatomic, copy)NSString *downloadUrl;

@end


@interface CMPImageBlockObj : NSObject

typedef void(^ImageBlock)(UIImage *aImage);
@property (nonatomic, copy)ImageBlock imageBlock;

@end

