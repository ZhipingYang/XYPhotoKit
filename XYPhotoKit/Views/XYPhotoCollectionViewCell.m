//
//  XYPhotoCollectionViewCell.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoCollectionViewCell.h"
#import "XYPhotoDataCategory.h"
#import "XYPhotoKitHelper.h"
#import "XYPhotoSelectedAssetManager.h"

@interface XYPhotoCollectionViewCell ()

@property (nonatomic) PHImageRequestID imageRequestId;

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) UIImageView *imageView;

// 是否选中
@property (nonatomic, strong) UIButton *markIconButon;

@end

@implementation XYPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
		
		if ([XYPhotoSelectedAssetManager sharedManager].maxNumberOfAssets != 1) {
			_markIconButon = [UIButton buttonWithType:UIButtonTypeCustom];
			[_markIconButon setImage:[UIImage xy_imageWithName:@"cl_photo_picker_unpicked"] forState:UIControlStateNormal];
			[_markIconButon setImage:[UIImage xy_imageWithName:@"cl_photo_picker_picked"] forState:UIControlStateSelected];
			_markIconButon.imageView.contentMode = UIViewContentModeCenter;
			_markIconButon.selected = NO;
			[_markIconButon addTarget:self action:@selector(markButtonClick) forControlEvents:UIControlEventTouchUpInside];
			[self.contentView addSubview:_markIconButon];
		}
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	_markIconButon.frame = CGRectMake(self.contentView.frame.size.width-35, 0, 35, 35);
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	_markIconButon.selected = NO;
    self.imageView.image = nil;
}

- (void)setAsset:(PHAsset *)asset atIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView withCacheManager:(PHCachingImageManager *)cacheManager
{
	_asset = asset;
	
	_markIconButon.selected = [[XYPhotoSelectedAssetManager sharedManager].selectedAssets containsObject:asset];
	
	CGSize itemSize = [(UICollectionViewFlowLayout *)collectionView.collectionViewLayout itemSize];
	
	// 防止复用时加载延时图片展示多次
	if (_imageRequestId!=0) {
		[cacheManager cancelImageRequest:_imageRequestId];
	}
	
	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = [XYPhotoSelectedAssetManager sharedManager].allowNetRequestIfiCloud;

	_imageRequestId = [cacheManager requestImageForAsset:asset
											  targetSize:CGSizeScale(itemSize, [UIScreen mainScreen].scale)
											 contentMode:PHImageContentModeAspectFill
												 options:options
										   resultHandler:^(UIImage *result, NSDictionary *info) {
											   self.imageView.image = result;
										   }];
}

- (void)markButtonClick
{
	if (_markIconButon.selected) {
		[[XYPhotoSelectedAssetManager sharedManager] removeSelectedAsset:_asset];
		_markIconButon.selected = NO;
	} else if ([[XYPhotoSelectedAssetManager sharedManager] addSelectedAsset:_asset]) {
		_markIconButon.selected = YES;
	}
}

@end
