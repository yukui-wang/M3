//
//  CMPOcrUploadManagePhotoCell.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/5.
//

#import "CMPOcrUploadManagePhotoCell.h"
#import "CMPOcrUploadManagePhotoCollectionCell.h"
#import "CMPOcrUploadManagePhotoCollectionAddCell.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>
#import "CMPOcrFileModel.h"
#import <CMPLib/UIImageView+WebCache.h>

static NSString *kCMPOcrUploadManagePhotoCollectionCell = @"CMPOcrUploadManagePhotoCollectionCell";
static NSString *kCMPOcrUploadManagePhotoCollectionAddCell = @"CMPOcrUploadManagePhotoCollectionAddCell";
@interface CMPOcrUploadManagePhotoCell()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *fileArray;
@property (nonatomic, copy) void(^ReloadTableViewBlock)(void);

@end
@implementation CMPOcrUploadManagePhotoCell

//cell 大小
+ (CGFloat)CellWidth{
    CGFloat verticalMargin = 8;
    CGFloat w = floor((UIScreen.mainScreen.bounds.size.width - 14*2 - 2*verticalMargin)/3);
    return w;
}

+ (CGFloat)heightWithCount:(NSInteger)count{
    CGFloat verticalMargin = 8;
    CGFloat h = [self.class CellWidth];
    NSInteger row = count/3 + (count%3>0?1:0);
    CGFloat collectionViewH = row * h + (row - 1)*verticalMargin;
    CGFloat top = 14+20+10;
    CGFloat bot = 10+10;
    CGFloat totalH = top + collectionViewH + bot;
    return totalH;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setup];
    }
    return self;
}

- (void)setup{
    //bg
    UIView *bgView = [UIView new];
    bgView.backgroundColor = UIColor.whiteColor;
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-10);
    }];
    //label
    UILabel *label = [UILabel new];
    label.text = @"点击文件可查看详情";
    label.textColor = [UIColor cmp_specColorWithName:@"desc-fc"];
    label.font = [UIFont systemFontOfSize:14];
    [bgView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.height.mas_equalTo(20);
    }];
    //collectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 8;
    layout.minimumInteritemSpacing = 4;
    CGFloat w = [self.class CellWidth];
    layout.itemSize = CGSizeMake(w, w);
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.whiteColor;
    [_collectionView registerNib:[UINib nibWithNibName:kCMPOcrUploadManagePhotoCollectionCell bundle:nil] forCellWithReuseIdentifier:kCMPOcrUploadManagePhotoCollectionCell];
    [_collectionView registerNib:[UINib nibWithNibName:kCMPOcrUploadManagePhotoCollectionAddCell bundle:nil] forCellWithReuseIdentifier:kCMPOcrUploadManagePhotoCollectionAddCell];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [bgView addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.equalTo(label.mas_bottom).offset(10);
        make.right.mas_equalTo(-14);
        make.bottom.mas_equalTo(-10);
    }];
}

- (void)reloadDataWith:(NSMutableArray*)fileArray completion:(nonnull void (^)(void))completion{
    _fileArray = fileArray;
    _ReloadTableViewBlock = completion;
    [_collectionView reloadData];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.item;
    if (index == _fileArray.count) {//add photo
        CMPOcrUploadManagePhotoCollectionAddCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCMPOcrUploadManagePhotoCollectionAddCell forIndexPath:indexPath];
        return cell;
    }else{
        CMPOcrUploadManagePhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCMPOcrUploadManagePhotoCollectionCell forIndexPath:indexPath];
        id obj = _fileArray[indexPath.item];
        if ([obj isKindOfClass:CMPOcrFileModel.class]) {
            CMPOcrFileModel *file = obj;
            if (file.image) {//显示相册图片
                cell.imageView.image = file.image;
            }else if(file.localUrl.length>0){//显示本地文件
                if ([file.fileType isEqual:@"pdf"]) {
                    cell.imageView.image = [UIImage imageNamed:@"ocr_card_pdf_placeholder"];
                }else{
                    cell.imageView.image = [UIImage imageWithContentsOfFile:file.localUrl];
                }
            }else if(file.fileId.length>0){
                if ([file.fileType isEqual:@"pdf"]) {//pdf
                    cell.imageView.image = [UIImage imageNamed:@"ocr_card_pdf_placeholder"];
                }else{
//                    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/commonImage/showImage?size=source&id=%@", file.fileId];
                    NSString *url = [CMPCore fullUrlForPathFormat:@"/commonimage.do?method=showImage&id=%@&createDate=&size=custom&w=60&h=60&igonregif=1&option.n_a_s=1",file.fileId];
                    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"ocr_card_image_placeholder"]];
                }
            }else {
                cell.imageView.image = [UIImage imageNamed:@"ocr_card_image_placeholder"];
            }
        }
        
        __weak typeof(self) weakSelf = self;
        cell.DeleteBtnBlock = ^{
            [weakSelf.fileArray removeObjectAtIndex:indexPath.item];
            [weakSelf.collectionView reloadData];
            if (weakSelf.ReloadTableViewBlock) {
                weakSelf.ReloadTableViewBlock();
            }
        };
        
        return cell;
    }
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _fileArray.count + 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == _fileArray.count) {//点击继续添加图片
        if (_ClickedAddPhotoCollectionCell) {
            _ClickedAddPhotoCollectionCell();
        }
    }else{
        if (_ClickedPhotoCollectionCell) {
            id obj = _fileArray[indexPath.item];
            if ([obj isKindOfClass:CMPOcrFileModel.class]) {
                CMPOcrFileModel *file = obj;
                _ClickedPhotoCollectionCell(file);
            }            
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];    
}



@end
