//
//  CMPAppViewItem.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/1/11.
//

#import <CMPLib/CMPBaseView.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPAppModel : CMPObject

@property(nonatomic, copy) NSString *iconUrl;
@property(nonatomic, copy) NSString *appId;
@property(nonatomic, copy) NSString *appName;
@property(nonatomic, copy) NSString *gotoParam;
@property(nonatomic, assign) NSInteger unread;
@property(nonatomic, assign) NSInteger sort;
@property(nonatomic,strong) id ext;
@property(nonatomic, copy) NSString *iconBgColor;

-(BOOL)isScanCodeApp;

@end

@protocol CMPAppViewItemDelegate;
@interface CMPAppViewItem : CMPBaseView

@property (strong, nonatomic) UIView *iconBgView;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *badgeLabel;

@property (nonatomic,assign) id<CMPAppViewItemDelegate> delegate;
@property (nonatomic,strong) CMPAppModel *model;

-(void)updateTheme:(NSInteger)theme;//1:light   2:dark

@end

@protocol CMPAppViewItemDelegate <NSObject>

-(void)cmpAppViewItem:(CMPAppViewItem *)appView didAction:(NSInteger)action model:(CMPAppModel *)model ext:(id)ext;

@end

NS_ASSUME_NONNULL_END
