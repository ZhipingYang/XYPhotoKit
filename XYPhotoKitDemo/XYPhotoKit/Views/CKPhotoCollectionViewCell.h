//
//  CKPhotoCollectionViewCell.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import UIKit;
@import Photos;

NS_ASSUME_NONNULL_BEGIN

@interface CKPhotoCollectionViewCell : UICollectionViewCell

- (void)setAsset:(PHAsset *)asset atIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView withCacheManager:(PHCachingImageManager *)cacheManager;

@end

NS_ASSUME_NONNULL_END
