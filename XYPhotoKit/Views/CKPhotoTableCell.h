//
//  CKPhotoTableCell.h
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 30/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import Photos;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const CKPhotoTableCellReuseIdentifier;

static CGFloat const CLPhotoCollectionCellRowHeight = 86.0f;

@interface CKPhotoTableCell : UITableViewCell

@property (nonatomic, strong) PHAssetCollection *collection;

@end

NS_ASSUME_NONNULL_END
