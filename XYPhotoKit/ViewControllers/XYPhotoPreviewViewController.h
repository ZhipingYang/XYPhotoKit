//
//  XYPhotoPreviewViewController.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 31/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//


@import Photos;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface XYPhotoPreviewViewController : UIViewController

/**
 查看已选择的asset时，使用该方法
 */
@property (nonatomic, strong, nullable) NSArray <PHAsset *> *photos;

/**
 大图查看某个相册集时，使用该方法；
 同时，监听原生相册资源变化时更新fetchResult
 */
@property (nonatomic, strong, nullable) PHFetchResult *fetchResult;
// 横向scrollview的内容
@property (nonatomic, assign) NSInteger selectedIndex;

@end

NS_ASSUME_NONNULL_END
