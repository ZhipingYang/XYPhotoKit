//
//  XYPhotoMultiCameraPicker.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 08/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import Photos;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class XYPhotoMultiCameraPicker;
@protocol XYPhotoMultiCameraPickerDelegate <NSObject>

@required
/**
 代理完成选择Asset
 
 @param multiImagePicker 导航栏控制器
 @param assets 已选中的Asset
 */
- (void)multiCameraPicker:(XYPhotoMultiCameraPicker *)multiImagePicker selectedAssets:(NSArray<PHAsset *> *)assets;

@optional
/**
 选择Asset的时候，如果delegate有定义此方法，则导航栏右侧点击cancel时回调此函数
 **注意:** 需要对 `XYPhotoSelectedAssetManager` 进行 resetManager 操作
 可以选择不实现该函数，则自动完成dimiss和resetManager
 
 @param multiImagePicker 导航栏控制器
 */
- (void)multiCameraPickerDidCancel:(XYPhotoMultiCameraPicker *)multiImagePicker;

@end

@protocol XYPhotoMultiCameraPickerDataSource <NSObject>

/**
 提前载入预设选中的Asset
 
 @return 已选中的Asset
 */
- (nullable NSArray<PHAsset *> *)multiCameraPickerLoadPresetSelectedAssets;
@end


@interface XYPhotoMultiCameraPicker : UINavigationController

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

@property (nonatomic, weak, nullable) id<XYPhotoMultiCameraPickerDataSource>pickerDataSource;
@property (nonatomic, weak, nullable) id<XYPhotoMultiCameraPickerDelegate>pickerDelegate;

@end

NS_ASSUME_NONNULL_END

