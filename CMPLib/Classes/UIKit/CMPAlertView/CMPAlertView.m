//
//  CMPAlertView.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/21.
//
//

#import "CMPAlertView.h"
#import "CMPConstant.h"

@interface CMPAlertViewController()

@end

@implementation CMPAlertViewController

+(instancetype)alertControllerWithTitle:(NSString *)title
                                   html:(NSString *)html
                         preferredStyle:(UIAlertControllerStyle)preferredStyle
                                actions:(NSArray<UIAlertAction *> *)actions
{
    CMPAlertViewController *alert = [self alertControllerWithTitle:title message:@"" preferredStyle:preferredStyle];
    if (html && html.length) {
        NSData *htmlData = [html dataUsingEncoding:NSUnicodeStringEncoding];
        NSAttributedString *attStr = [[NSAttributedString alloc] initWithData:htmlData options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        [alert setValue:attStr forKey:@"attributedMessage"];
    }
    for (UIAlertAction *act in actions) {
        [alert addAction:act];
    }
    return alert;
}

@end

@interface CMPAlertView()<UIAlertViewDelegate>
@end

@implementation CMPAlertView

-(void)show
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AlertWillShow object:nil];
    [CMPAlertView dismissAll];
    [super show];
    [[CMPAlertViewRecorder shareInstance].alertViewArray addObject:self];
}


+(void)dismissAll
{
    NSMutableArray *arr = [CMPAlertViewRecorder shareInstance].alertViewArray;
    if (arr && arr.count>0) {
        for (id o in arr) {
            if ([o isKindOfClass:[self class]]) {
                [((CMPAlertView *)o) dismissWithClickedButtonIndex:[((CMPAlertView *)o) cancelButtonIndex] animated:NO];
            }
        }
    }
    [arr removeAllObjects];
}

-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles callback:(ClickedButtonBlock)callback
{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:NULL, nil];
    if (self) {
        
        if (otherButtonTitles && otherButtonTitles.count>0) {
            for (NSString *t in otherButtonTitles) {
                [self addButtonWithTitle:t];
            }
        }
        _clickedButtonBlock = nil;
        _clickedButtonBlock = [callback copy];
    }
    return self;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView && _clickedButtonBlock) {
        _clickedButtonBlock(buttonIndex);
        self.clickedButtonBlock = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AlertWillHide object:nil];
    }
}

@end


static CMPAlertViewRecorder *recoder = nil;

@implementation CMPAlertViewRecorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!_alertViewArray) {
            _alertViewArray = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

+(CMPAlertViewRecorder *)shareInstance
{
    @synchronized (self)
    {
        if (recoder == nil)
        {
            recoder =  [[self alloc] init];
            
        }
    }
    return recoder;
}

+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized (self) {
        if (recoder == nil) {
            recoder = [super allocWithZone:zone];
            return recoder;
        }
    }
    return nil;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

@end
