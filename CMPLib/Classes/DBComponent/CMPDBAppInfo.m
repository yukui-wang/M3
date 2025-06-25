//
//  CMPDBAppItem.m
//  CMPLib
//
//  Created by youlin on 16/6/6.
//  Copyright © 2016年 CMPCore. All rights reserved.
//

#import "CMPDBAppInfo.h"

@implementation CMPDBAppInfo

- (id)initWithManifestDict:(NSDictionary *)aDict
{
    self = [super init];
    if (self) {
        NSString *appId = [aDict objectForKey:@"appId"];
        NSString *bundleIdentifier = [aDict objectForKey:@"bundleIdentifier"];
        NSString *bundleName = [aDict objectForKey:@"bundleName"];
        NSString *appName = [aDict objectForKey:@"appName"];
        NSString *appType = [aDict objectForKey:@"appType"];
        NSString *version = [aDict objectForKey:@"version"];
        NSString *team = [aDict objectForKey:@"team"];
        NSString *urlSchemes = [aDict objectForKey:@"urlSchemes"];
        
        self.appId = appId;
        self.bundle_identifier = bundleIdentifier;
        self.bundle_name = bundleName;
        self.bundle_display_name = appName;
//        self.path = @"";
        self.bundle_type = appType;
        self.version = version;
        self.team = team;
//        self.serverID = @"";
//        self.owerID = @"";
        self.url_schemes = urlSchemes;
    }
    return self;
}

- (void)dealloc
{
    [_appId release];
    [_bundle_identifier release];
    [_bundle_name release];
    [_bundle_display_name release];

    [_version release];
    
    [_team release];
    [_path release];
    [_bundle_type release];
    
    [_desc release];
    [_deployment_target release];
    [_compatible_version release];
    [_icon_files release];
    [_supported_platforms release];
    
    [_url_schemes release];
    [_serverID release];
    [_owerID release];
    
    [_downloadTime release];
    
    [_extend1 release];
    [_extend2 release];
    
    [_extend3 release];
    [_extend4 release];
    [_extend5 release];
    
    [_extend6 release];
    [_extend7 release];
    [_extend8 release];
    
    [_extend9 release];
    [_extend10 release];
    [_extend11 release];
    
    [_extend12 release];
    [_extend13 release];
    [_extend14 release];
    
    [_extend15 release];
   
    [super dealloc];
}

- (NSString *)finalPath {
    if ([NSString isNotNull:_extend2]) {
        return _extend2;
    }
    return _path;
}
@end
