//
//  SyAttachment.h
//  M1Core
//
//  Created by guoyl on 13-1-17.
//  Copyright (c) 2013年 北京致远协创软件有限公司. All rights reserved.
//

#define kUserInfosKey_ArchiveID @"archiveID"

#import <Foundation/Foundation.h>
#import "MAttachmentBase.h"
@class SyAttachmentItemView;
@interface SyAttachment : NSObject

@property(nonatomic, copy)NSString *fileID;
@property(nonatomic, retain)MAttachmentBase *value; // any value
@property(nonatomic, copy)NSString *filePath;
@property(nonatomic, assign)BOOL hadUploaded;
@property(nonatomic, copy)NSString *fullName;
@property(nonatomic, assign)BOOL localFile; // 是否是本地文件
@property(nonatomic, assign)id uploadProgressDelegate;
@property(nonatomic, retain)NSDictionary *userInfos; // 存储自定义数据
@property(nonatomic, assign)BOOL encrypted;
@property(nonatomic, copy)NSString *downloadUrl; // 下载地址
@property(nonatomic, copy)NSString *downloadTime; // 下载时间
@property(nonatomic, assign)NSInteger type;
@property(nonatomic, assign)BOOL isDownload;
@property(nonatomic, assign)BOOL fromOpinion;//来自意见列表（震荡回复）

@property(nonatomic, copy)NSString *senderName; // 关联文档用
//@property(nonatomic, retain)MAttachmentParameter *attachmentParameter;
//
- (id)initWithMAttachmentBase:(MAttachmentBase *)aMAttachmentBase;
//
@end
