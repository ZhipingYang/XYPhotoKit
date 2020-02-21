//
//  XYPhotoCollectionDataSource.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//



@import Foundation;
@import UIKit;
@import Photos;

NS_ASSUME_NONNULL_BEGIN

@class XYPhotoCollectionDataSource;
@protocol XYPhotoCollectionDataSourceDelegate <NSObject>

- (void)assetCollectionDataSource:(XYPhotoCollectionDataSource *)dataSource selectedIndex:(NSInteger)selectedIndex inFetchResult:(PHFetchResult *)fetchResult;

@end


@interface XYPhotoCollectionDataSource : NSObject

@property (nullable, nonatomic, weak) id<XYPhotoCollectionDataSourceDelegate> delegate;
@property (nullable, nonatomic, copy) NSArray <PHAsset *> *assets;
@property (nonatomic) BOOL shouldCache;

- (instancetype)init __attribute__((unavailable("此方法已弃用,请使用initWithCollectionView:fetchResult方法")));
+ (instancetype)new __attribute__((unavailable("此方法已弃用,请使用initWithCollectionView:fetchResult方法")));
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView fetchResult:(PHFetchResult *)fetchResult;

@end

NS_ASSUME_NONNULL_END
