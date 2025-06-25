//
//  CMPDesktopPlugin.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/22.
//
//

#import "CMPDesktopAppLinkPlugin.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/HTTPServer.h>
#import <CMPLib/DDLog.h>
#import <CMPLib/DDTTYLogger.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/JSON.h>
#import <CMPLib/CMPCore.h>

@interface CMPDesktopAppLinkPlugin ()
{
    HTTPServer *_httpServer;
    
}
@property (nonatomic, copy)NSString *callbackId;
@property (nonatomic,copy) NSString  *webRootDir;
@property (nonatomic,copy) NSString *mainPage;
@end

//static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@implementation CMPDesktopAppLinkPlugin

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SY_RELEASE_SAFELY(_webRootDir);
    SY_RELEASE_SAFELY(_mainPage);
    SY_RELEASE_SAFELY(_httpServer);
    SY_RELEASE_SAFELY(_callbackId);
    [super dealloc];
}

- (void)createDesktopLinkApp:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    [self setupBaseInfo];
    NSDictionary *arguments = [command.arguments firstObject];
    [self createLinkWithDict:arguments];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)getOpenDesktopLinkAppOptions:(CDVInvokedUrlCommand*)command
{
    NSDictionary *value = [CMPCore sharedInstance].openDesktopAppData;
    CDVPluginResult *result = nil;
    if (value) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:value];
    }
    else {
         NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:13001],@"code",SY_STRING(@"desktop_errorParameter"),@"message",@"",@"detail", nil];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    }
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    [CMPCore sharedInstance].openDesktopAppData = nil;
}

- (void)setupBaseInfo
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    //启动本地httpSever和服务器首页页面
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = paths[0];
    self.webRootDir = nil;
    self.webRootDir = [documentsPath stringByAppendingPathComponent:@"web"];
    BOOL isDirectory = YES;
    BOOL exsit = [[NSFileManager defaultManager] fileExistsAtPath:_webRootDir isDirectory:&isDirectory];
    if(!exsit){
        [[NSFileManager defaultManager] createDirectoryAtPath:_webRootDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.mainPage= nil;
    self.mainPage = [NSString stringWithFormat:@"%@/web/index.html",documentsPath];
    
    NSMutableString *htmlStr = [NSMutableString string];
    [htmlStr appendString:@"<html><head><title>just test</title></head></html>"];
    
    NSData *data = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:_mainPage atomically:YES];
    
    SY_RELEASE_SAFELY(_httpServer);
    _httpServer = [[HTTPServer alloc] init];
    [_httpServer setType:@"_http._tcp."];
    
    [_httpServer setDocumentRoot:_webRootDir];
    
    NSError *error;
    if([_httpServer start:&error]){
        DDLogInfo(@"Started HTTP Server on port %hu", [_httpServer listeningPort]);
    }
    else{
        DDLogError(@"Error starting HTTP Server: %@", error);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if([[UIDevice currentDevice].systemVersion integerValue] >= 6.0){
        sleep(1);
    }else {
        sleep(2);
    }
    [_httpServer stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSError *error;
    if(![_httpServer isRunning]){
        if([_httpServer start:&error]) {
            DDLogInfo(@"Started HTTP Server on port %hu", [_httpServer listeningPort]);
        }
        else {
            DDLogError(@"Error starting HTTP Server: %@", error);
        }
    }
}

- (void)createLinkWithDict:(NSDictionary *)dict
{
    NSString *displayName = [dict objectForKey:@"displayName"];
    NSString *iconBase64Data = [dict objectForKey:@"iconBase64Data"];
    NSString *urlScheme = @"cmpDemoDesktop://";
    
    NSMutableString *htmlStr = [[NSMutableString alloc] init];
    [htmlStr appendString:@"<html><head>"];
    [htmlStr appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
    
    NSMutableString *taragerUrl = [NSMutableString stringWithFormat:@"0;url=data:text/html;charset=UTF-8,<html><head><meta content=\"yes\" name=\"apple-mobile-web-app-capable\" /><meta content=\"text/html; charset=UTF-8\" http-equiv=\"Content-Type\" /><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=no\" /><title>%@</title></head><body bgcolor=\"#ffffff\">", displayName];
    
    NSString *htmlUrlScheme = [NSString stringWithFormat:@"<a href=\"%@",urlScheme];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mDict removeObjectForKey:@"iconBase64Data"];
    NSString *value = [mDict JSONRepresentation];
    value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *dataUrlStr = nil;
    dataUrlStr =  [NSString stringWithFormat:@"%@\" id=\"qbt\" style=\"display: none;\"></a>", value];
    
    NSString *imageUrlStr = [NSString stringWithFormat:@"<span id=\"msg\"></span></body><script>if (window.navigator.standalone == true) {    var lnk = document.getElementById(\"qbt\");    var evt = document.createEvent('MouseEvent');    evt.initMouseEvent('click');    lnk.dispatchEvent(evt);}else{    var addObj=document.createElement(\"link\");    addObj.setAttribute('rel','apple-touch-icon-precomposed');    addObj.setAttribute('href','%@');", iconBase64Data];
    
    NSString *lastHtmlStr = [NSString stringWithFormat:@"document.getElementsByTagName(\"head\")[0].appendChild(addObj);    document.getElementById(\"msg\").innerHTML='<div style=\"font-size:12px;\">%@ <img id=\"i\" src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAMAAAC6V+0/AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6OTU1NEJDMzMwQTBFMTFFM0FDQTA4REMyNUE4RkExNkEiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6OTU1NEJDMzQwQTBFMTFFM0FDQTA4REMyNUE4RkExNkEiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo5NTU0QkMzMTBBMEUxMUUzQUNBMDhEQzI1QThGQTE2QSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo5NTU0QkMzMjBBMEUxMUUzQUNBMDhEQzI1QThGQTE2QSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PlMy2ugAAAAbUExUReXy/yaS/4nE/67W//n8/+n0/0yl/wB//////1m3cVcAAAAJdFJOU///////////AFNPeBIAAABDSURBVHjaxNA7DgAgCAPQoiLc/8T+EgV1p0ubxwb0E+xR8SBICBcyJUnEHktW0VwOykivvSaus6kA1CD0sZ+3aQIMAJIgC+S9X9jmAAAAAElFTkSuQmCC\"> %@</div>';}</script></html>",@"点击页面下方的 + 或",@"按钮，在弹出的菜单中选择［添加至主屏幕］，即可将选定的功能添加到主屏幕作为快捷方式。"];
    
    [taragerUrl appendString:htmlUrlScheme];
    [taragerUrl appendString:dataUrlStr];
    NSString *dataUrlEncode = [taragerUrl urlUTF8Encoded];
    
    NSString *imageUrlEncode = [imageUrlStr urlUTF8Encoded];
    NSString *lastHtmlStrEncode = [lastHtmlStr urlCFEncoded];
    
    
    [htmlStr appendFormat:@"<meta http-equiv=\"REFRESH\" content=\"%@%@%@\">",dataUrlEncode,imageUrlEncode,lastHtmlStrEncode];
    [htmlStr appendString:@"</head></html>"];
    
    NSData *data = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
    SY_RELEASE_SAFELY(htmlStr);
    [data writeToFile:_mainPage atomically:YES];
    
    NSString *urlStrWithPort = [NSString stringWithFormat:@"http://127.0.0.1:%d",[_httpServer listeningPort]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStrWithPort]];
   
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

@end
