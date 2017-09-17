//
//  CKPhotoSelectedAssetPreviewView.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 30/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import UIKit;
@import Photos;

@class CKPhotoSelectedAssetPreviewView;

@protocol CKPhotoSelectedAssetPreviewViewDelegate  <NSObject>

/**
 preview 被点击回调

 @param previewView self
 @param index 被点击的asset索引位置
 @param asset 被点击的asset
 */
- (void)assetsSelectedPreviewView:(CKPhotoSelectedAssetPreviewView *)previewView didClickWithIndex:(NSInteger)index asset:(PHAsset *)asset;

@end


@interface CKPhotoSelectedAssetPreviewView : UIView

/**
 已选择的asset数组，并reload collectionView，监听系统的添加删除已选择的asset并做修改
 default: [CKPhotoSelectedAssetManager sharedManager].selectedAssets
 */
@property (nonatomic, strong) NSArray <PHAsset *> *assetArray;
@property (nonatomic, weak) id<CKPhotoSelectedAssetPreviewViewDelegate> delegate;

/**
 隐藏右侧完成按钮及徽标
 default:NO
 */
@property (nonatomic, assign) BOOL hideControls;

/**
 滚动到指定的asset，如果已选中的asset数组没有包含asset则不滚动

 @param asset 滚动到指定的照片asset
 */
- (void)scrollToAssetIfNeed:(PHAsset *)asset;

@end
