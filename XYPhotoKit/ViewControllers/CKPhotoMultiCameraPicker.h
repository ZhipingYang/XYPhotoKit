//
//  CKPhotoMultiCameraPicker.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 08/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import Photos;

NS_ASSUME_NONNULL_BEGIN

@class CKPhotoMultiCameraPicker;
@protocol CKPhotoMultiCameraPickerDelegate <NSObject>

@required
/**
 代理完成选择Asset
 
 @param multiImagePicker 导航栏控制器
 @param assets 已选中的Asset
 */
- (void)multiCameraPicker:(CKPhotoMultiCameraPicker *)multiImagePicker selectedAssets:(NSArray<PHAsset *> *)assets;

@optional
/**
 选择Asset的时候，如果delegate有定义此方法，则导航栏右侧点击cancel时回调此函数
 **注意:** 需要对 `CKPhotoSelectedAssetManager` 进行 resetManager 操作
 可以选择不实现该函数，则自动完成dimiss和resetManager
 
 @param multiImagePicker 导航栏控制器
 */
- (void)multiCameraPickerDidCancel:(CKPhotoMultiCameraPicker *)multiImagePicker;

@end

@protocol CKPhotoMultiCameraPickerDataSource <NSObject>

/**
 提前载入预设选中的Asset
 
 @return 已选中的Asset
 */
- (nullable NSArray<PHAsset *> *)multiCameraPickerLoadPresetSelectedAssets;
@end


@interface CKPhotoMultiCameraPicker : UINavigationController

/**
 最大选择数量
 Defaults 0
 */
@property (nonatomic) NSUInteger maxNumberOfAssets;

/**
 是否允许网络请求从iCloud下载
 Default NO
 */
@property (nonatomic) BOOL allowNetRequestIfiCloud;

@property (nonatomic, weak, nullable) id<CKPhotoMultiCameraPickerDataSource>pickerDataSource;
@property (nonatomic, weak, nullable) id<CKPhotoMultiCameraPickerDelegate>pickerDelegate;

@end

NS_ASSUME_NONNULL_END

