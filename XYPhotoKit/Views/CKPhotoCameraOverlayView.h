//
//  CKPhotoCameraOverlayView.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 11/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CKPhotoSelectedAssetPreviewView.h"

@import Photos;

@class CKPhotoCameraOverlayView;
@protocol CKPhotoCameraOverlayViewDelegate<CKPhotoSelectedAssetPreviewViewDelegate>

/**
 快门按键点击

 @param sender 快门按钮
 */
- (void)cameraOverlayView:(CKPhotoCameraOverlayView *)overlayView didShutted:(UIButton *)sender;

/**
 摄像头翻转切换前后镜头
 @param cameraDeivce 前后镜头枚举
 */
- (void)cameraOverlayView:(CKPhotoCameraOverlayView *)overlayView didSwitchedCameraDeivce:(UIImagePickerControllerCameraDevice)cameraDeivce;

/**
 闪光灯控制，自动、开、关
 注意：关闭则照相时是都不会开启软件硬件闪光灯（软件指的6s以后的闪屏补光）
 @param flashMode 闪光灯枚举
 */
- (void)cameraOverlayView:(CKPhotoCameraOverlayView *)overlayView didSwitchedFlashMode:(UIImagePickerControllerCameraFlashMode)flashMode;

/**
 取消，关闭照相取图
 */
- (void)canceledCameraOverlayView:(CKPhotoCameraOverlayView *)overlayView;

/**
 完成照相去相片
 */
- (void)finishedCameraOverlayView:(CKPhotoCameraOverlayView *)overlayView;

@end

@interface CKPhotoCameraOverlayView : UIView

/**
 实现 UI 元素交互响应的代理方法
 */
@property (nonatomic, weak) id<CKPhotoCameraOverlayViewDelegate> delegate;

/**
 默认选中的asset
 */
@property (nonatomic, strong) NSArray <PHAsset *> *defaultAssetArray;

/**
 default: UIImagePickerControllerCameraFlashModeAuto
 */
@property (nonatomic, assign) UIImagePickerControllerCameraFlashMode flashMode;

/**
 default: UIImagePickerControllerCameraDeviceRear
 */
@property (nonatomic, assign) UIImagePickerControllerCameraDevice cameraDeivce;

@end
