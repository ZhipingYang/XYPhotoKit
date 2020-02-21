//
//  XYPhotoTableCell.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 30/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import Photos;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const XYPhotoTableCellReuseIdentifier;

static CGFloat const CLPhotoCollectionCellRowHeight = 86.0f;

@interface XYPhotoTableCell : UITableViewCell

@property (nonatomic, strong) PHAssetCollection *collection;

@end

NS_ASSUME_NONNULL_END
