//
//  XYPhotoHorizontalScrollItemView.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 07/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoHorizontalScrollView.h"

@class XYPhotoHorizontalScrollItemView;
@protocol XYPhotoHorizontalScrollItemViewDelegate <NSObject>
@optional
- (void)didTapped:(XYPhotoHorizontalScrollItemView *)scrollItemView;
@end

@import Photos;
@interface XYPhotoHorizontalScrollItemView : UIScrollView <XYHorizontalScrollItemInterface>

@property (nonatomic) int index;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) id<XYPhotoHorizontalScrollItemViewDelegate> photokitDelegate;

@end
