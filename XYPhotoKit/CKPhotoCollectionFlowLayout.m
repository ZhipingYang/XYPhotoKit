//
//  CKPhotoCollectionFlowLayout.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 30/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CKPhotoCollectionFlowLayout.h"

#import "CKPhotoSelectedAssetManager.h"

NSUInteger const CKPhotoCollectionFlowLayoutDefaultColumns = 3;

@interface CKPhotoCollectionFlowLayout ()

@property (nonatomic) NSUInteger numberOfColumns;

@end

@implementation CKPhotoCollectionFlowLayout

static CGFloat const CKPhotoCollectionFlowLayoutDefaultSpacing = 2.0f;

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
    _numberOfColumns = [CKPhotoSelectedAssetManager sharedManager].assetCollectionViewColumnCount;
	
    self.minimumInteritemSpacing = CKPhotoCollectionFlowLayoutDefaultSpacing;
    self.minimumLineSpacing = CKPhotoCollectionFlowLayoutDefaultSpacing;
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
	if (scrollDirection == UICollectionViewScrollDirectionVertical) {
		self.minimumInteritemSpacing = CKPhotoCollectionFlowLayoutDefaultSpacing;
		self.minimumLineSpacing = CKPhotoCollectionFlowLayoutDefaultSpacing;
	} else {
		self.minimumInteritemSpacing = 0;
		self.minimumLineSpacing = CKPhotoCollectionFlowLayoutDefaultSpacing*3;
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
