//
//  XYPhotoAlbumDetailController.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import Photos;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface XYPhotoAlbumDetailController : UIViewController

@property (nonatomic, readonly) UICollectionView *collectionView;

- (instancetype)initWithFetchResult:(PHFetchResult *)fetchResult;

- (instancetype)init __attribute__((unavailable("此方法已弃用,请使用initWithFetchResult方法")));
+ (instancetype)new __attribute__((unavailable("此方法已弃用,请使用initWithFetchResult方法")));

@end

NS_ASSUME_NONNULL_END
