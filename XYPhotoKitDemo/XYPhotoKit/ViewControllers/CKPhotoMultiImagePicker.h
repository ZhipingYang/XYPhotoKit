//
//  XYPhotoKitDemo.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import UIKit;
@import Photos;

typedef NS_ENUM(NSInteger, CLPhotoMultiPickerStartPosition){
	// 展示相册列表 tableView，可以push到collectionView
    CLPhotoMultiPickerStartPositionAlbums,
	// 展示全部照片 collectionView，可以pop到 tableview
    CLPhotoMultiPickerStartPositionCameraRoll,
};

@class CKPhotoMultiImagePicker;
@protocol CKPhotoMultiImagePickerDelegate <NSObject>

@required

/**
 代理完成选择Asset
 
 @param multiImagePicker 导航栏控制器
 @param assets 已选中的Asset
 */
- (void)multiImagePicker:(CKPhotoMultiImagePicker *)multiImagePicker selectedAssets:(NSArray<PHAsset *> *)assets;

@optional

/**
 选择Asset的时候，如果delegate有定义此方法，则导航栏右侧点击cancel时回调此函数
 **注意:** 需要对 `CKPhotoSelectedAssetManager` 进行 resetManager 操作
 可以选择不实现该函数，则自动完成dimiss和resetManager
 
 @param multiImagePicker 导航栏控制器
 */
- (void)multiImagePickerDidCancel:(CKPhotoMultiImagePicker *)multiImagePicker;
@end

@protocol CKPhotoMultiImagePickerDataSource <NSObject>

/**
 提前载入预设选中的Asset

 @return 已选中的Asset
 */
- (NSArray<PHAsset *> *)multiImagePickerLoadPresetSelectedAssets;
@end

@interface CKPhotoMultiImagePicker : UINavigationController

/**
 代理回调已选中的asset
 */
@property (nonatomic, weak) id<CKPhotoMultiImagePickerDelegate> pickerDelegate;

/**
 传入默认的初始化资源
 */
@property (nonatomic, weak) id<CKPhotoMultiImagePickerDataSource> pickerDataSource;

/**
 *  PHAssetMediaTypeUnknown - 全部展示.
 *  PHAssetMediaTypeImage - 只展示图片.
 *  PHAssetMediaTypeVideo - 只展示视频.
 *  PHAssetMediaTypeAudio - 只展示音频.
 */
@property (nonatomic) PHAssetMediaType mediaType;

/**
 是否允许网络请求从iCloud下载
 Default NO
 */
@property (nonatomic) BOOL allowNetRequestIfiCloud;

/**
 两种选择，一种直接选择照片，一种进入相册集列表再选择
 */
@property (nonatomic) CLPhotoMultiPickerStartPosition startPosition;

/**
 collectionView一行的collectionCell数量
 Default 3.
 */
@property (nonatomic) NSInteger assetCollectionViewColumnCount;

/**
 最大选择数量
 Defaults 0
 */
@property (nonatomic) NSUInteger maxNumberOfAssets;

//+ (void)showImagePickerWithConfiger:(void(^)(CKPhotoMultiImagePicker *picker))configer successBlock:(void(^)(NSArray <PHAsset *> *selectedAsset))successBlock;

@end


