//
//  XYPhotoTableDataSource.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import Foundation;
@import UIKit;
@import Photos;

NS_ASSUME_NONNULL_BEGIN

@class XYPhotoTableDataSource;

@protocol XYPhotoTableDataSourceDelegate <NSObject>

- (void)assetTableDataSource:(XYPhotoTableDataSource *)dataSource selectedAssetCollection:(PHAssetCollection *)assetCollection;

@end


@interface XYPhotoTableDataSource : NSObject

@property (nullable, nonatomic, weak) id<XYPhotoTableDataSourceDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableView;
- (instancetype)init __attribute__((unavailable("此方法已弃用,请使用initWithCollectionView:fetchResult方法")));
+ (instancetype)new __attribute__((unavailable("此方法已弃用,请使用initWithCollectionView:fetchResult方法")));

@end

NS_ASSUME_NONNULL_END
