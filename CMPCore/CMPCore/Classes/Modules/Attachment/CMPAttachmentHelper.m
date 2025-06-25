//
//  CMPAttachmentHelper.m
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2022/4/18.
//  Copyright © 2022 crmo. All rights reserved.
//

#import "CMPAttachmentHelper.h"
#import "CMPAttachmentDataProvider.h"
#import <CMPLib/CMPServerVersionUtils.h>

@interface CMPAttachmentHelper()
{
   __block NSString *_enableOnlineFlag;
    __block NSString *_canDownloadFlag;
}
@property(nonatomic,strong) CMPAttachmentDataProvider *dataProvider;
@property(nonatomic,strong) NSMutableArray *supportOnlineTypes;
@property(nonatomic,assign) BOOL isServerLater8_1SP2;

@end

@implementation CMPAttachmentHelper

static CMPAttachmentHelper *_instance;
static dispatch_once_t onceToken;

+(CMPAttachmentHelper *)shareManager
{
    dispatch_once(&onceToken, ^{
        _instance = [[CMPAttachmentHelper alloc] init];
    });
    return _instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _isServerLater8_1SP2 = [CMPServerVersionUtils serverIsLaterV8_1SP2];
    }
    return self;
}

-(void)_freeData
{
    _supportOnlineTypes = nil;
    _dataProvider = nil;
    _enableOnlineFlag = nil;
    _isServerLater8_1SP2 = NO;
}

+(void)free
{
    CMPAttachmentHelper *helper = [CMPAttachmentHelper shareManager];
    [helper _freeData];
}

-(BOOL)isServerLater8_1SP2
{
    if (_isServerLater8_1SP2) {
        return YES;
    }
    _isServerLater8_1SP2 = [CMPServerVersionUtils serverIsLaterV8_1SP2];
    return _isServerLater8_1SP2;
}

-(NSMutableArray *)supportOnlineTypes
{
    if (!_supportOnlineTypes) {
        _supportOnlineTypes = [NSMutableArray array];
    }
    return _supportOnlineTypes;
}

-(CMPAttachmentDataProvider *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[CMPAttachmentDataProvider alloc] init];
    }
    return _dataProvider;
}

-(BOOL)isSupportOnlinePreviewWithFileExtension:(NSString *)extention
{
    if (!extention || extention.length == 0) {
        return NO;
    }
    //todo 低版本校验
    if (!self.isServerLater8_1SP2) {
        return YES;//ks add -- 8.1sp2以前版本没有这个属性逻辑，默认支持，不然调用此方法的地方需要加oa版本判断，不然旧版本就都不支持了
    }
    if (_enableOnlineFlag) {
        if ([_enableOnlineFlag isEqualToString:@"0"]) {
            return NO;
        }else if ([_enableOnlineFlag isEqualToString:@"1"]) {
            return [self.supportOnlineTypes containsObject:extention.lowercaseString];
        }
    }
    return NO;
}
-(BOOL)isSupportOnlinePreviewDownload{
    if ([_canDownloadFlag isEqualToString:@"0"]) {
        return NO;
    }
    return YES;
}

-(void)updateAttaPreviewConfigWithCompletion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!self.isServerLater8_1SP2) {
        if (completion) {
            completion(nil,[NSError errorWithDomain:@"server version low" code:-1001 userInfo:nil],nil);
        }
        return;
    }
    __weak typeof(self) wSelf = self;
    [self.dataProvider fetchAttaPreviewConfigWithParams:nil completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error && respData) {
            
            self->_canDownloadFlag = [NSString stringWithFormat:@"%@",respData[@"canDownloadFile"]];
            self->_enableOnlineFlag = [NSString stringWithFormat:@"%@",respData[@"enableTrans"]];
            id types = respData[@"supportTransTypes"];
            if (types && [types isKindOfClass:NSArray.class]) {
                [wSelf.supportOnlineTypes removeAllObjects];
                [wSelf.supportOnlineTypes addObjectsFromArray:types];
            }
        }else{
            NSLog(@"ks log --- %s -- %@",__func__,error);
        }
        if (completion) {
            completion(respData,error,ext);
        }
    }];
}

-(void)fetchAttaPreviewUrlWithFileId:(NSString *)fileId completion:(void(^)(NSString *previewUrlStr,NSError *error,id ext))completion
{
    if (!completion) {
        return;
    }
    if (!self.isServerLater8_1SP2) {
        completion(nil,[NSError errorWithDomain:@"server version low" code:-1001 userInfo:nil],nil);
        return;
    }
    [self.dataProvider fetchAttaPreviewUrlWithParams:@{@"fileId":fileId} completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error && respData) {
            if ([respData isKindOfClass:NSString.class] && ((NSString *)respData).length) {
                NSString *aPath = [[CMPCore sharedInstance].serverurl stringByAppendingString:respData];
                completion(aPath,nil,ext);
            }else{
                completion(nil,nil,ext);
            }
            
        }else{
            completion(nil,error,ext);
        }
    }];
}


-(void)shareAttaActionLogType:(NSInteger)acttype withParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!self.isServerLater8_1SP2) {
        if (completion) {
            completion(nil,[NSError errorWithDomain:@"server version low" code:-1001 userInfo:nil],nil);
        }
        return;
    }
//    NSDictionary *pa = @{@"targetType":@(targetType),
//                         @"targetName":targetName?:@"",
//                         @"fileName":fileName?:@""
//    };
    [self.dataProvider shareAttaActionLogType:acttype withParams:params completion:completion];
}

@end
