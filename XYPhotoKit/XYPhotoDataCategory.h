//
//  CLPhotoDataCategory.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 30/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import UIKit;
@import Photos;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CLPhotoKit)

@property (nonatomic, readonly) BOOL xy_isEmpty;

@end

@interface NSIndexSet (CLPhotoKit)

- (NSArray<NSIndexPath *> *)xy_indexPathsFromIndexesWithSection:(NSUInteger)section;

@end

@interface PHFetchResult (CLPhotoKit)

+ (instancetype)xy_fetchResultWithAssetCollection:(PHAssetCollection *)assetCollection mediaType:(PHAssetMediaType)type;

+ (instancetype)xy_fetchResultWithAssetsOfType:(PHAssetMediaType)type;

@end


@interface UICollectionView (CLPhotoKit)

- (nullable NSArray<NSIndexPath *> *)xy_indexPathsForElementsInRect:(CGRect)rect;

@end

@interface UIImage (CLPhotoKit)

+ (nullable UIImage *)xy_imageWithName:(NSString *)imageName;

+ (UIImage *)xy_imageWithColor:(UIColor *)color;


@end

@interface UIAlertController (CLPhotoKit)

+ (BOOL)xy_showAlertPhotoSettingIfUnauthorized;

+ (BOOL)xy_showAlertCameraSettingIfUnauthorized;

+ (void)xy_showTitle:(nullable NSString *)title message:(nullable NSString *)msg;

@end

@interface UIApplication (CLPhotoKit)

@property (nonatomic, readonly, nullable) UIViewController *xy_topViewController;

@end


@interface PHAsset (CLPhotoKit)

+ (nullable PHAsset *)xy_getTheCloestAsset;

//
///**
// 同步请求指定大小图片
//
// @param size 目标尺寸
// @return 图片
// */
//- (UIImage *)xy_getSynchImageSize:(CGSize)size;
//
///**
// 同步请求指定大小缩略图
//
// @param size 目标尺寸
// @return 图片
// */
//- (UIImage *)xy_getSynchThumbnailWithSize:(CGSize)size;
//
///**
// 同步请求原图
// 
// @return 图片
// */
//- (UIImage *)xy_getSynchOriginImage;
//

@end

NS_ASSUME_NONNULL_END
