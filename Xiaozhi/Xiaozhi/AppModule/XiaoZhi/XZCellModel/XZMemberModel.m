//
//  XZMemberModel.m
//  M3
//
//  Created by wujiansheng on 2018/1/3.
//

#import "XZMemberModel.h"
#import "XZCore.h"
#import "XZMainProjectBridge.h"
#import "XZMemberDetailView.h"
@implementation XZMemberModel
- (void)dealloc{
    self.clickButtonBlock = nil;
    self.callBlock = nil;
    self.sendSMSBlock = nil;
    self.sendCollBlock = nil;
    self.sendIMMessageBlock = nil;
    self.member = nil;
}

- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZMemberTableViewCell";
        self.ideltifier = @"xzmembercardcell";
    }
    return self;
}

- (void)setMember:(CMPOfflineContactMember *)member {
    _member = nil;
    _member = member;
    self.canOperate = NO;
    self.hasPhone = [member mobilePhoneAvailable];
    self.canColl = [XZCore sharedInstance].privilege.hasColNewAuth;
    self.canIM = YES;
    if ([member.orgID isEqualToString:[XZCore userID]]) {
        self.canIM = NO;
    }
    else if ([XZMainProjectBridge unavailableCMPChatType]) {
        self.canIM = NO;
    }
    if (self.hasPhone || self.canColl || self.canIM) {
        self.canOperate = YES;
    }
   
}
- (void)setCanOperate:(BOOL)canOperate {
    if (!canOperate && _canOperate) {
        _cellHeight = 0;
    }
    _canOperate = canOperate;
}

- (CGFloat)cellHeight {
    if (![ self.cellClass isEqualToString:@"XZMemberTableViewCell"]) {
        return [XZMemberDetailView viewHeight:_canOperate] +20;
    }
    if (_cellHeight == 0) {
        CGFloat width = self.scellWidth-24 - 175;
        NSInteger height = 19;
        CGSize size = [_member.department sizeWithFontSize:FONTSYS(16) defaultSize:CGSizeMake(width, CGFLOAT_MAX)];
        height +=  size.height >FONTSYS(16).lineHeight*2 ? FONTSYS(16).lineHeight*2 +7 :size.height +7;//7 = 6 +1,6为间隔
        
//        size = [_member.postName sizeWithFontSize:FONTSYS(16) defaultSize:CGSizeMake(width, CGFLOAT_MAX)];
//        height += size.height >0 ? size.height +7 :size.height +7;//7 = 6 +1,6为间隔
        height += FONTSYS(16).lineHeight +1;
//        size = [_member.level sizeWithFontSize:FONTSYS(16) defaultSize:CGSizeMake(width, CGFLOAT_MAX)];
//        height +=  size.height >0 ? size.height +7 :size.height +7;//7 = 6 +1,6为间隔
        height += FONTSYS(16).lineHeight +1;
        
        height +=  FONTSYS(16).lineHeight +7;//7 = 6 +1,6为间隔
        height += 17;
        height += kXZCellSpace;
        if (self.canOperate) {
            height += 40;
        }
        _cellHeight = height;
    }
    return _cellHeight;
}

- (void)call {
    if(self.callBlock) {
        self.callBlock(self.member.mobilePhone);
    }
    self.canOperate = NO;
}

- (void)sendMessage {
    if(self.sendSMSBlock) {
        self.sendSMSBlock(self.member.mobilePhone);
    }
    self.canOperate = NO;
}
- (void)sendColl {
    if(self.sendCollBlock) {
        self.sendCollBlock(self.member);
    }
    self.canOperate = NO;
}
- (void)sendIMMessage {
    if(self.sendIMMessageBlock) {
        self.sendIMMessageBlock(self.member);
    }
    self.canOperate = NO;
}

- (void)disableOperate {
    self.canOperate = NO;
}

- (CGFloat)scellWidth {
    if (INTERFACE_IS_PHONE) {
        return [super scellWidth];
    }
    return 375;
}

@end
