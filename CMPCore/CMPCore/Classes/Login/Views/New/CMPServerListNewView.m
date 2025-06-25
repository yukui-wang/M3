//
//  CMPServerListView.m
//  M3
//
//  Created by CRMO on 2017/10/30.
//

#import "CMPServerListNewView.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPThemeManager.h>

static NSString * const kBackgroundColor = @"F8F9FB";

@interface CMPServerListNewView()

@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation CMPServerListNewView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)dealloc {
    
}

#pragma mark - UI布局

- (void)initView {
    [self addSubview:self.table];
    [self addSubview:self.saveButton];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self.saveButton mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0,*)) {
            make.leading.trailing.equalTo(self.mas_safeAreaLayoutGuide).inset(0);
            make.bottom.equalTo(self.mas_bottom).inset(30.f);
        } else {
            make.leading.trailing.equalTo(self).inset(0);
            make.bottom.equalTo(self.mas_bottom).inset(30.f);
        }
        make.height.equalTo(@40.f);
    }];
    
    [self.table mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.bottom.equalTo(self.saveButton.mas_top);
    }];
    
    [super updateConstraints];
}

#pragma mark - 按钮点击事件

- (void)tapSaveButton {
    if (self.saveAction) {
        self.saveAction();
    }
}

#pragma mark - Getter & Setter

- (CMPServerEditTableView *)table {
    if (!_table) {
        _table = [[CMPServerEditTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.backgroundColor = UIColor.clearColor;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _table;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setTitle:SY_STRING(@"common_save") forState:UIControlStateNormal];
        UIImage *image = [[UIImage imageWithName:@"login_server_save" type:@"png" inBundle:@"CMPLogin"] cmp_imageWithTintColor:[CMPThemeManager sharedManager].themeColor];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5, image.size.width * 0.5, image.size.height * 0.5, image.size.width * 0.5)];
        UIImage *highlightedImage = [image imageByApplyingAlpha:0.7];
        highlightedImage = [highlightedImage resizableImageWithCapInsets:UIEdgeInsetsMake(highlightedImage.size.height * 0.5, highlightedImage.size.width * 0.5, highlightedImage.size.height * 0.5, highlightedImage.size.width * 0.5)];
        [_saveButton setBackgroundImage:image forState:UIControlStateNormal];
        [_saveButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        [_saveButton addTarget:self action:@selector(tapSaveButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

@end
