//
//  XZFormAppIntent.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/13.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZFormAppIntent.h"
#import "XZM3RequestManager.h"
@implementation XZFormAppIntent

- (id)initWithIntentName:(NSString *)intentName {
    if (self = [super init]) {
        self.intentName = intentName;
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.json",[SPTools localIntentFolderPath],intentName];
        NSString *jsonStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *data = [SPTools dictionaryWithJsonString:jsonStr];
        self.openType = [SPTools stringValue:data forKey:@"openType"];
        self.openApi = [SPTools stringValue:data forKey:@"openApi"];
        self.extData = [SPTools dicValue:data forKey:@"extData"];
        self.accountId = [SPTools stringValue:data forKey:@"accountId"];
        self.url = [SPTools stringValue:data forKey:@"url"];
        self.urlType = [SPTools stringValue:data forKey:@"urlType"];
        self.callParamsUrl = [SPTools stringValue:data forKey:@"callParamsUrl"];
        self.callParamsUrlType = [SPTools stringValue:data forKey:@"callParamsUrlType"];

    }
    return self;
}

- (void)handleNativeResult:(NSString *)result {
    
}

- (void)next {
    
}

- (NSDictionary *)request_params {
    return nil;
}

- (NSString *)request_url {
    
    return nil;
}

- (NSDictionary *)open_params {
     return nil;
}

- (NSString *)open_url {
    return nil;
}
- (BOOL)useUnit {
    return NO;
}



@end
