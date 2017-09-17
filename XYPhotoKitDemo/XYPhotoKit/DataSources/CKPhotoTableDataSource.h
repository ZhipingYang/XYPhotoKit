//
//  CKPhotoTableDataSource.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import Foundation;
@import Photos;

NS_ASSUME_NONNULL_BEGIN

@class CKPhotoTableDataSource;

@protocol CKPhotoTableDataSourceDelegate <NSObject>

- (void)assetTableDataSource:(CKPhotoTableDataSource *)dataSource selectedAssetCollection:(PHAssetCollection *)assetCollection;

@end


@interface CKPhotoTableDataSource : NSObject

@property (nullable, nonatomic, weak) id<CKPhotoTableDataSourceDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableView;
- (instancetype)init __attribute__((unavailable("此方法已弃用,请使用initWithCollectionView:fetchResult方法")));
+ (instancetype)new __attribute__((unavailable("此方法已弃用,请使用initWithCollectionView:fetchResult方法")));

@end

NS_ASSUME_NONNULL_END
