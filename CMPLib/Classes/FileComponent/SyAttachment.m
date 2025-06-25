//
//  SyAttachment.m
//  M1Core
//
//  Created by guoyl on 13-1-17.
//  Copyright (c) 2013年 北京致远协创软件有限公司. All rights reserved.
//

#import "SyAttachment.h"
#import "MAttachment.h"
@implementation SyAttachment
@synthesize fileID = _fileID;
@synthesize filePath = _filePath;
@synthesize hadUploaded = _hadUploaded;
@synthesize fullName = _fullName;
@synthesize localFile = _localFile;
@synthesize uploadProgressDelegate = _uploadProgressDelegate;
@synthesize userInfos = _userInfos;
@synthesize encrypted = _encrypted;
@synthesize downloadUrl = _downloadUrl;
@synthesize downloadTime = _downloadTime;
@synthesize type = _type;
@synthesize isDownload = _isDownload;
@synthesize fromOpinion = _fromOpinion;
@synthesize senderName = _senderName;
//@synthesize attachmentParameter = _attachmentParameter;
- (void)dealloc {
    [_fileID release];
    [_filePath release];
    [_fullName release];
    [_downloadTime release];
    [_senderName release];
    _senderName = nil;
    self.userInfos = nil;
    [_value release];_value = nil;
    [_downloadUrl release];_downloadUrl = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _fromOpinion = NO;
    }
    return self;
}
- (id)initWithMAttachmentBase:(MAttachmentBase *)aMAttachmentBase {
    self = [self init];
    if (self) {
        [self setValue:aMAttachmentBase];
    }
    return self;
}

- (void)setValue:(MAttachmentBase *)aValue
{
    [_value release];
    _value = [aValue retain];
   if ([aValue isKindOfClass:[MAttachment class]]) {
        MAttachment *att = (MAttachment *)aValue;
        NSString *aSuffix = [NSString stringWithFormat:@".%@", att.suffix];
        if (att.suffix && ![att.name hasSuffix:aSuffix]) {
            self.fullName = [att.name stringByAppendingPathExtension:att.suffix];
        }
        else {
            self.fullName = att.name;
        }
    }
}


@end
