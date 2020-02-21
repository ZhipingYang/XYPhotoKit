//
//  XYPhotoPreviewOverlayView.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 06/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoSelectedAssetPreviewView.h"

@class XYPhotoPreviewOverlayView;
@protocol XYPhotoPreviewOverlayViewDelegate<XYPhotoSelectedAssetPreviewViewDelegate>

@required
/**
 关闭预览大图
 @param barbuttonItem closeItem
 */
- (void)previewOverlayView:(XYPhotoPreviewOverlayView *)view closeBarButtonItemClick:(UIBarButtonItem *)barbuttonItem;

@end


@interface XYPhotoPreviewOverlayView : UIView

@property (nonatomic, weak) id<XYPhotoPreviewOverlayViewDelegate> delegate;

/**
 更新相关UI，如果当前asset的选中状态及滚动到当前asset对应的小图预览

 @param asset 当前asset需要更新
 */
- (void)updateSelectedAsset:(PHAsset *)asset;

/**
 更新头部标题

 @param index 当前展示的索引
 @param sum 全部asset个数
 */
- (void)updateTitleAtIndex:(NSInteger)index sum:(NSInteger)sum;

@end
