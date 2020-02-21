//
//  XYPhotoCollectionFlowLayout.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 30/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoCollectionFlowLayout.h"

#import "XYPhotoSelectedAssetManager.h"

NSUInteger const XYPhotoCollectionFlowLayoutDefaultColumns = 3;

@interface XYPhotoCollectionFlowLayout ()

@property (nonatomic) NSUInteger numberOfColumns;

@end

@implementation XYPhotoCollectionFlowLayout

static CGFloat const XYPhotoCollectionFlowLayoutDefaultSpacing = 2.0f;

- (instancetype)init
{
    if (self = [super init]) {
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
        [self setupDefaults];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupDefaults];
}

- (void)setupDefaults
{
    _numberOfColumns = [XYPhotoSelectedAssetManager sharedManager].assetCollectionViewColumnCount;
	
    self.minimumInteritemSpacing = XYPhotoCollectionFlowLayoutDefaultSpacing;
    self.minimumLineSpacing = XYPhotoCollectionFlowLayoutDefaultSpacing;
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
	if (scrollDirection == UICollectionViewScrollDirectionVertical) {
		self.minimumInteritemSpacing = XYPhotoCollectionFlowLayoutDefaultSpacing;
		self.minimumLineSpacing = XYPhotoCollectionFlowLayoutDefaultSpacing;
	} else {
		self.minimumInteritemSpacing = 0;
		self.minimumLineSpacing = XYPhotoCollectionFlowLayoutDefaultSpacing*3;
	}
	[super setScrollDirection:scrollDirection];
}

- (CGSize)itemSize
{
	if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
		CGFloat totalWidth = CGRectGetWidth(self.collectionView.frame);
		totalWidth -= (self.minimumInteritemSpacing * (self.numberOfColumns - 1));
		CGFloat cellDimension = totalWidth / self.numberOfColumns;
		return CGSizeMake(cellDimension, cellDimension);
	} else {
		CGFloat totalHeight = CGRectGetHeight(self.collectionView.frame);
		totalHeight -= self.minimumInteritemSpacing * 2;
		return CGSizeMake(totalHeight, totalHeight);
	}
}

@end
