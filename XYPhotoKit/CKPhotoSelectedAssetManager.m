//
//  CKPhotoSelectedAssetManager.m
//  XYPhotoKitDemo-iOS
//
//  Created by XcodeYang on 30/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CKPhotoSelectedAssetManager.h"
#import "CKPhotoDataCategory.h"
#import "CKPhotoCollectionViewCell.h"
#import "CKPhotoCollectionFlowLayout.h"
#import "CKPhotoKitHelper.h"

@interface CKPhotoSelectedAssetManager ()

@property (nonatomic) NSMutableArray *selectedAssetsMutableArray;

@end

@implementation CKPhotoSelectedAssetManager

+ (instancetype)sharedManager
{
    static CKPhotoSelectedAssetManager *SharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedManager = [[super alloc] initUniqueInstance];
        [SharedManager resetManager];
    });
    
    return SharedManager;
}

-(instancetype)initUniqueInstance;
{
	return [super init];
}

- (void)resetManager
{
    self.selectedAssetsMutableArray = [NSMutableArray array];
    self.mediaType = PHAssetMediaTypeUnknown;
    self.assetCollectionViewColumnCount = CKPhotoCollectionFlowLayoutDefaultColumns;
    self.maxNumberOfAssets = 0;
}

- (BOOL)addSelectedAsset:(PHAsset *)asset
{
    if ([self assetIsInMediaType:asset] && [self canAddMoreAssets]) {
        if (![self.selectedAssetsMutableArray containsObject:asset]) {
            [self.selectedAssetsMutableArray addObject:asset];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CKPhotoMultiImagePickerNotifications.assetsChanged object:asset];
        return YES;
    }
    return NO;
}

- (BOOL)canAddMoreAssets
{
    if (self.maxNumberOfAssets == 0) {
        return YES;
    } else if (self.selectedAssetsMutableArray.count < self.maxNumberOfAssets) {
        return YES;
    } else {
		NSString *tip = self.maxNumberLimitText.xy_isEmpty ? @"已达到最大照片数限制" : self.maxNumberLimitText;
        [UIAlertController xy_showTitle:@"友情提示" message:tip];
		return NO;
	}
}

- (void)removeSelectedAsset:(PHAsset *)asset
{
    [self.selectedAssetsMutableArray removeObject:asset];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CKPhotoMultiImagePickerNotifications.assetsChanged object:asset];
}

- (void)resetSelectedAsset:(NSArray <PHAsset *>*)assets
{
	[self.selectedAssetsMutableArray removeAllObjects];
	
	NSMutableArray <PHAsset *> *deleteAssets = @[].mutableCopy;
	[assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if (![self assetIsInMediaType:obj]) {
			[deleteAssets addObject:obj];
		}
	}];
	NSMutableArray <PHAsset *> *newAssets = assets.mutableCopy;
	[newAssets removeObjectsInArray:deleteAssets];
	
	if (self.maxNumberOfAssets <= 0 || (self.maxNumberOfAssets>0 && self.maxNumberOfAssets>newAssets.count)) {
		// 个数无限制 或者 未达到最大个数限制
		[self.selectedAssetsMutableArray addObjectsFromArray:newAssets];
	} else {
		// 超出限制个数，裁剪
		[self.selectedAssetsMutableArray addObjectsFromArray:[newAssets subarrayWithRange:NSMakeRange(0, self.maxNumberOfAssets)]];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:CKPhotoMultiImagePickerNotifications.assetsChanged object:nil];
}

- (NSArray *)selectedAssets
{
    return [self.selectedAssetsMutableArray copy];
}

#pragma mark - Helpers

- (BOOL)assetIsInMediaType:(PHAsset *)asset;
{
	if (![asset isKindOfClass:[PHAsset class]]) {
		return NO;
	}
	
    if (self.mediaType == PHAssetMediaTypeUnknown) {
        return YES;
    } else if (asset.mediaType == self.mediaType) {
        return YES;
    }
    return NO;
}

@end
