//
//  CKPhotoHorizontalScrollItemView.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 07/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CKPhotoHorizontalScrollView.h"

@class CKPhotoHorizontalScrollItemView;
@protocol CKPhotoHorizontalScrollItemViewDelegate <NSObject>
@optional
- (void)didTapped:(CKPhotoHorizontalScrollItemView *)scrollItemView;
@end

@import Photos;
@interface CKPhotoHorizontalScrollItemView : UIScrollView <CKHorizontalScrollItemInterface>

@property (nonatomic) int index;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) id<CKPhotoHorizontalScrollItemViewDelegate> photokitDelegate;

@end
