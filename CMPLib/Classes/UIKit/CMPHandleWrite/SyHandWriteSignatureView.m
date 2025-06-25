//
//  SyHandWriteSignatureView.m
//  M1IPhone
//
//  Created by guoyl on 13-5-7.
//  Copyright (c) 2013年 北京致远协创软件有限公司. All rights reserved.
//

#define kSyCanvasLocalColors        @"CanvasLocalColors"

#import "SyHandWriteSignatureView.h"
#import "SignatureUtils.h"

@interface SyHandWriteSignatureView ()<SyHandWriteViewDelegate, SyColorPickerViewDelegate> {
    
}

@property (nonatomic, copy) NSString  *picSignatureName;

- (SySegmentedItemAttribute *)createSegItemAttributeWithTitle:(NSString *)aTitle imageName:(NSString *)aImageName;
- (UIColor *)getLocalColorWithKey:(NSString *)key;
- (void)setColorToLocal:(UIColor *)aColor key:(NSString *)aKey;
- (void)layoutBottomSegControlItems;

@end

@implementation SyHandWriteSignatureView
@synthesize handWriteView = _handWriteView;
@synthesize picSignatureName = _picSignatureName;
@synthesize bottomSegControl = _bottomSegControl;
@synthesize deleteSignatureButtonHidden = _deleteSignatureButtonHidden;
@synthesize signatureButtonHidden = _signatureButtonHidden;

- (void)dealloc
{
    [_handWriteView release];
    _handWriteView = nil;
    
    [_colorPickerView release];
    _colorPickerView = nil;
    
    [_picSignatureName release];
    _picSignatureName = nil;
    [super dealloc];
}

- (void)setupWithInitSize:(CGSize )aInitSize
{
    if (!_handWriteView) {
        _handWriteView = [[SyHandWriteView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 40)];
        [_handWriteView setupWithInitSize:aInitSize];
        [_handWriteView setNeedsDisplay];
        _handWriteView.rowHeight = 60.0f;
        _handWriteView.columnWidth = 60.0f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            _handWriteView.rowHeight = 80.0f;
            _handWriteView.columnWidth = 80.0f;
        }
        _handWriteView.delegate = self;
        [self addSubview:_handWriteView];
    }
    if (!_bottomSegControl) {
        NSMutableArray *aAttributeList = [[NSMutableArray alloc] init];
        [aAttributeList addObject:[self createSegItemAttributeWithTitle:nil imageName:@"CMPHandleWrite.bundle/ic_pen_color_black.png"]];
        [aAttributeList addObject:[self createSegItemAttributeWithTitle:SY_STRING(@"common_repeal") imageName:@"ic_revocate.png"]];
        [aAttributeList addObject:[self createSegItemAttributeWithTitle:SY_STRING(@"coll_all_clean") imageName:@"ic_delete_all.png"]];
//        [aAttributeList addObject:[self createSegItemAttributeWithTitle:nil imageName:@"ic_delete_signature.png"]];
//        [aAttributeList addObject:[self createSegItemAttributeWithTitle:nil imageName:@"ic_signature.png"]];
        
        _bottomSegControl = [[SySegmentedControl alloc] initWithItemAttributes:aAttributeList];
        _bottomSegControl.disableSelectedSate = YES;
        _bottomSegControl.frame = CGRectMake(0, self.height - 40, self.width, 40);
        _bottomSegControl.contentSize = CGSizeMake(self.width, 42); 
        _bottomSegControl.backgroundImageEdgeInsets = UIEdgeInsetsMake(-2, 0, 0, 0);
        [self addSubview:_bottomSegControl];
        [_bottomSegControl setTitleFont:[UIFont systemFontOfSize:16.0f] selectedFont:[UIFont boldSystemFontOfSize:16.0f]];
        [aAttributeList release];
    }
    if (!_colorPickerView) {
        CGRect aFrame = CGRectMake(10.0f, 300.0f, 145, 60.0f);
        _colorPickerView = [[SyColorPickerView alloc] initWithFrame:aFrame];
        _colorPickerView.userInteractionEnabled = YES;
        _colorPickerView.delegate = self;
        
        NSString *sId = @"seeyon";//self.sySetting.serverIdentifier;
        long long uId = 11111;//self.currentUser.orgID;
        NSString *key = [NSString stringWithFormat:@"%@_%lld", sId, uId];
        _handWriteView.uniqueId = key;
        _handWriteView.textColor = [self getLocalColorWithKey:key];
        NSString *imgName = [_colorPickerView setCurrentColor:_handWriteView.textColor];
        [_bottomSegControl setImage:[UIImage imageNamed:imgName] forSegmentAtIndex:0];
    }
}

- (SySegmentedItemAttribute *)createSegItemAttributeWithTitle:(NSString *)aTitle imageName:(NSString *)aImageName
{
    SySegmentedItemAttribute *aAttribute = [[SySegmentedItemAttribute alloc] init];
    aAttribute.backgroundImage = nil;            
    aAttribute.title = aTitle;
    if ([aImageName isKindOfClass:[NSString class]] && [aImageName length] > 0) {
        aAttribute.image = [UIImage imageNamed:aImageName];
    }
    aAttribute.marginTitleAndImage = 3.5;
    return  [aAttribute autorelease];
}

- (void)showColorPickerView:(id)sender 
{
    if ([_colorPickerView superview]) {
        [_colorPickerView removeFromSuperview];
    }
    else {
        _colorPickerView.frame = CGRectMake(10.0f, _bottomSegControl.originY - 105, 145, 60);
        [self addSubview:_colorPickerView];
        [self bringSubviewToFront:_colorPickerView];
    }
}

- (void)customLayoutSubviews
{
    _handWriteView.frame = CGRectMake(0, 0, self.width, self.height - 40);
    [self layoutBottomSegControlItems];
    _colorPickerView.frame = CGRectMake(10.0f, _bottomSegControl.originY - _colorPickerView.height, 145, 60);
}

- (void)layoutHandWriteView:(CGSize )initSize
{
    CGFloat x = (self.width - initSize.width)/2;
    _handWriteView.frame = CGRectMake(x, 0, initSize.width, self.height - 40);
}

#pragma -mark SyColorPickerViewDelegate
- (void)colorPickerView:(SyColorPickerView *)aaColorPickerView didSelectedColor:(UIColor *)aColor colorImgName:(NSString *)imgName
{
    _handWriteView.textColor = aColor;
    [self setColorToLocal:aColor key:_handWriteView.uniqueId];
    [_bottomSegControl setImage:[UIImage imageNamed:imgName] forSegmentAtIndex:0];
    if ([_colorPickerView superview]) {
        [_colorPickerView removeFromSuperview];
    }
}

- (UIImage *) dataURL2Image: (NSString *) imgSrc
{
    NSURL *url = [NSURL URLWithString: imgSrc];
    NSData *data = [NSData dataWithContentsOfURL: url];
    UIImage *image = [UIImage imageWithData: data];
    
    return image;
}

- (void)addSignatureImageWithBase64Str:(NSString *)value
{
    [_handWriteView deleteAllImages];
    UIImage *aImage = [self dataURL2Image:value];
    [_handWriteView addImage:aImage];
    self.deleteSignatureButtonHidden = NO;
}

- (void)deleteSignatureImage
{
    [_handWriteView deleteAllImages];
    self.picSignatureName = nil;
    self.deleteSignatureButtonHidden = YES;
}

- (void)clear
{
    [_handWriteView deleteAllText];
    [self deleteSignatureImage];
}

- (UIColor *)getLocalColorWithKey:(NSString *)key 
{
    UIColor *color = [UIColor blackColor];
    NSString *value = nil;
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSyCanvasLocalColors];
    if (dict == nil) {
        dict = [NSDictionary dictionary];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kSyCanvasLocalColors];
    }
    value = [dict objectForKey:key];
    if (value) {
        NSArray *components = [value componentsSeparatedByString:@","];
        CGFloat r = [[components objectAtIndex:0] floatValue];
        CGFloat g = [[components objectAtIndex:1] floatValue];
        CGFloat b = [[components objectAtIndex:2] floatValue];
        CGFloat a = [[components objectAtIndex:3] floatValue];
        color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return color;
}

- (void)setColorToLocal:(UIColor *)aColor key:(NSString *)aKey 
{
    const CGFloat *components = CGColorGetComponents(aColor.CGColor);
    NSString *colorAsString = [NSString stringWithFormat:@"%f,%f,%f,%f", components[0], components[1], components[2], components[3]];
    if ([aColor isEqual:[UIColor blackColor]]) {
        colorAsString = @"0,0,0,1";
    }
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSyCanvasLocalColors];
    if (dict == nil) {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:colorAsString, aKey, nil];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kSyCanvasLocalColors];
    }
    else {
        NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [mDict setObject:colorAsString forKey:aKey];
        [[NSUserDefaults standardUserDefaults] setObject:mDict forKey:kSyCanvasLocalColors];
    }
}

+ (void)removeUserColorsRecord
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSyCanvasLocalColors];
}

- (void)setDeleteSignatureButtonHidden:(BOOL )aHidden
{
    _deleteSignatureButtonHidden = aHidden;
    SySegmentedItem *aItem = [_bottomSegControl segmentedItemWithTag:kSegmentedItemTag_DeleteSignatureButton];
    if (aItem && aHidden) {
        [_bottomSegControl removeSegmentedItem:aItem animated:YES];
        [self layoutBottomSegControlItems];
    }
    if (!aItem && !aHidden) {
        SySegmentedItemAttribute *aAttribute = [self createSegItemAttributeWithTitle:nil imageName:@"CMPHandleWrite.bundle/ic_delete_signature.png"];
        aAttribute.segmentedItemTag = kSegmentedItemTag_DeleteSignatureButton;
        if (_bottomSegControl.segmentsCount == 4) {
            [_bottomSegControl insertSegmentWithAttribute:aAttribute atIndex:3 animated:YES];
        }
        else {
            [_bottomSegControl addSegmentWithAttribute:aAttribute animated:YES];
        }
        [self layoutBottomSegControlItems];
    }
}

- (void)setSignatureButtonHidden:(BOOL )aHidden
{
    _signatureButtonHidden = aHidden;
    SySegmentedItem *aItem = [_bottomSegControl segmentedItemWithTag:kSegmentedItemTag_SignatureButton];
    if (aItem && aHidden) {
        [_bottomSegControl removeSegmentedItem:aItem animated:YES];
        [self layoutBottomSegControlItems];
    }
    if (!aItem && !aHidden) {
        SySegmentedItemAttribute *aAttribute = [self createSegItemAttributeWithTitle:nil imageName:@"CMPHandleWrite.bundle/ic_signature.png"];
        aAttribute.segmentedItemTag = kSegmentedItemTag_SignatureButton;
        [_bottomSegControl addSegmentWithAttribute:aAttribute animated:YES];
        [self layoutBottomSegControlItems];
    }
}

- (void)layoutBottomSegControlItems
{
    if (IS_IPHONE_X_UNIVERSAL) {
        _bottomSegControl.frame = CGRectMake(0, self.height - 40 - 34, self.width, 40 + 34);
    } else {
        _bottomSegControl.frame = CGRectMake(0, self.height - 40, self.width, 40);
    }
    if (_bottomSegControl.segmentsCount == 5) {
        [_bottomSegControl setWidth:45 forSegmentAtIndex:0];
        [_bottomSegControl setWidth:72 forSegmentAtIndex:1];
        [_bottomSegControl setWidth:self.width - 45*3 - 72 forSegmentAtIndex:2];
        [_bottomSegControl setWidth:45 forSegmentAtIndex:3];
        [_bottomSegControl setWidth:45 forSegmentAtIndex:4];
    }
    else if (_bottomSegControl.segmentsCount == 4) {
        [_bottomSegControl setWidth:72 forSegmentAtIndex:0];
        [_bottomSegControl setWidth:72 forSegmentAtIndex:1];
        [_bottomSegControl setWidth:self.width - 72*3 forSegmentAtIndex:2];
        [_bottomSegControl setWidth:72 forSegmentAtIndex:3];
    }
}

#pragma -mark SyHandWriteViewDelegate
- (void)handWriteView:(SyHandWriteView *)aHandWriteView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_colorPickerView superview]) {
        [_colorPickerView removeFromSuperview];
    }
}

- (void)handWriteViewDidStartDraw:(SyHandWriteView *)aHandWriteView {
    _bottomSegControl.userInteractionEnabled = NO;
}

- (void)handWriteViewDidFinishDraw:(SyHandWriteView *)aHandWriteView {
    _bottomSegControl.userInteractionEnabled = YES;
}

@end
