//
//  XYPhotoBottomPreviewCell.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 01/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoBottomPreviewCell.h"
#import "XYPhotoKitHelper.h"
#import "XYPhotoSelectedAssetManager.h"
#import "XYPhotoDataCategory.h"

@interface XYPhotoBottomPreviewCell()
{
    PHImageRequestID _imageRequestId;
}
@property (nonatomic, strong) PHImageManager *imageManager;
@end

@implementation XYPhotoBottomPreviewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.image = [UIImage xy_imageWithName:@"cl_photokit_placeholder"];
        _imageView.clipsToBounds = YES;
        if (@available(iOS 13.0, *)) {
            _imageView.backgroundColor = [UIColor systemBackgroundColor];
        } else {
            _imageView.backgroundColor = [UIColor whiteColor];
        }
        [self.contentView addSubview:_imageView];
        
        self.imageManager = [[PHCachingImageManager alloc] init];
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.0/[UIScreen mainScreen].scale;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.contentView.bounds;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.highlighted = NO;
    self.imageView.image = [UIImage xy_imageWithName:@"cl_photokit_placeholder"];
    if (_imageRequestId!=0) {
        [self.imageManager cancelImageRequest:_imageRequestId];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.layer.borderColor = highlighted ? [UIColor blueColor].CGColor : [UIColor lightGrayColor].CGColor;
}

- (void)setAsset:(PHAsset *)asset indexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView
{
    _asset = asset;
    
    UICollectionViewLayoutAttributes *cellAttributes = [collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    
    // 防止复用时加载延时图片展示多次
    if (_imageRequestId!=0) {
        [self.imageManager cancelImageRequest:_imageRequestId];
    }
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = [XYPhotoSelectedAssetManager sharedManager].allowNetRequestIfiCloud;
    
    _imageRequestId = [self.imageManager requestImageForAsset:_asset
                                                   targetSize:CGSizeScale(cellAttributes.size, [UIScreen mainScreen].scale)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:options
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
        NSInteger imageRequestId = [[info objectForKey:PHImageResultRequestIDKey] integerValue];
        if (imageRequestId>0) {
            self->_imageRequestId = 0;
        }
        self->_imageView.image = result ?: [UIImage xy_imageWithName:@"cl_photokit_placeholder"];
    }];
}

@end

