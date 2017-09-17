//
//  CKPhotoSelectedAssetManager.h
//  XYPhotoKitDemo-iOS
//
//  Created by XcodeYang on 30/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import Foundation;
@import Photos;

NS_ASSUME_NONNULL_BEGIN

@protocol CKPhotoSelectedAssetManagerDelegate<NSObject>
- (void)doneSelectingAssets;
@end

@interface CKPhotoSelectedAssetManager : NSObject

+ (instancetype)alloc __attribute__((unavailable("此方法已弃用,请使用 sharedManager")));
- (instancetype)init __attribute__((unavailable("此方法已弃用,请使用 sharedManager")));
+ (instancetype)new __attribute__((unavailable("此方法已弃用,请使用 sharedManager")));

+ (instancetype)sharedManager;

/**
 为了下次使用重置单例.
 */
- (void)resetManager;

/**
 代理回调，结束asset选择
 */
@property (nonatomic, weak, nullable) id<CKPhotoSelectedAssetManagerDelegate> delegate;

/**
 Unknown = 0,Image,Video,Audio
 */
@property (nonatomic) PHAssetMediaType mediaType;

/**
 是否允许网络请求从iCloud下载
 */
@property (nonatomic) BOOL allowNetRequestIfiCloud;

/**
 横向列数
 */
@property (nonatomic) NSInteger assetCollectionViewColumnCount;

/**
 Defaults=0，可以无限制选择asset个数
 */
@property (nonatomic) NSUInteger maxNumberOfAssets;

/**
 达到最大限制后的文案说明
 */
@property (nonatomic, copy, nullable) NSString *maxNumberLimitText;

/**
 添加资源，要求asset类型要匹配
 @param asset 添加的asset
 @return yes成功，no失败（根据最大个数和asset类型判断）
 */
- (BOOL)addSelectedAsset:(PHAsset *)asset;

/**
 删除资源，无限制
 @param asset 被删除asset
 */
- (void)removeSelectedAsset:(PHAsset *)asset;

/**
 重置已选中的asset
 */
- (void)resetSelectedAsset:(nullable NSArray <PHAsset *>*)assets;

/**
 已选择的asset列表
 @return 浅拷贝返回
 */
- (NSArray<PHAsset *> *)selectedAssets;

@end

NS_ASSUME_NONNULL_END
