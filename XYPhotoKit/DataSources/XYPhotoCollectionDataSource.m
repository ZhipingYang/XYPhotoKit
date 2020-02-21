//
//  XYPhotoCollectionDataSource.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoCollectionDataSource.h"

#import "XYPhotoDataCategory.h"
#import "XYPhotoCollectionViewCell.h"
#import "XYPhotoCollectionFlowLayout.h"
#import "XYPhotoSelectedAssetManager.h"
#import "XYPhotoKitHelper.h"

@interface XYPhotoCollectionDataSource () <PHPhotoLibraryChangeObserver, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, copy) PHFetchResult *results;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic) CGRect previousPreheatRect;

@end

@implementation XYPhotoCollectionDataSource

static NSString *const XYPhotoCollectionDataSourceCellReuseIdentifier = @"XYPhotoCollectionDataSourceCellReuseIdentifier";

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView fetchResult:(PHFetchResult *)fetchResult
{
    if (self = [super init]) {
        _collectionView = collectionView;
        _collectionView.dataSource = self;
		_collectionView.delegate = self;
		[_collectionView registerClass:[XYPhotoCollectionViewCell class] forCellWithReuseIdentifier:XYPhotoCollectionDataSourceCellReuseIdentifier];

        _results = fetchResult.copy;
		
		[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
			if (status == PHAuthorizationStatusAuthorized) {
				dispatch_async(dispatch_get_main_queue(), ^{
					self.imageManager = [[PHCachingImageManager alloc] init];
					[self resetCachedAssets];
					[self.collectionView reloadData];
					[[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
					[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedAssetsChanged) name:XYPhotoMultiImagePickerNotifications.assetsChanged object:nil];
				});
			} else {
				[UIAlertController xy_showAlertPhotoSettingIfUnauthorized];
			}
		}];
    }
    return self;
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (NSArray<PHAsset *> *)assets
{
	if (!_results) { return nil; }
	NSMutableArray *array = @[].mutableCopy;
	[_results enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[array addObject:obj];
	}];
	return array;
}

#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets
{
    if (!self.shouldCache) {
        return;
    }
	
	CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
	
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
		
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect
                                   andRect:preheatRect
                            removedHandler:^(CGRect removedRect) {
                                NSArray *indexPaths = [self.collectionView xy_indexPathsForElementsInRect:removedRect];
                                [removedIndexPaths addObjectsFromArray:indexPaths];
                            } addedHandler:^(CGRect addedRect) {
                                NSArray *indexPaths = [self.collectionView xy_indexPathsForElementsInRect:addedRect];
                                [addedIndexPaths addObjectsFromArray:indexPaths];
                            }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        CGSize itemSize = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout itemSize];
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:CGSizeScale(itemSize, [UIScreen mainScreen].scale)
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:CGSizeScale(itemSize, [UIScreen mainScreen].scale)
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect
                             andRect:(CGRect)newRect
                      removedHandler:(void (^)(CGRect removedRect))removedHandler
                        addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        // 如果像个区域有交集
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
		// 没有交集
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) {
        return nil;
    }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.results[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // 后台线程更新检查
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // assets 被修改了 (增、删、改)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.results];
        if (collectionChanges) {
            
            self.results = [collectionChanges fetchResultAfterChanges];
			
			// 未修改、或位置移动
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                [self.collectionView reloadData];
            } else {
                // 照片被修改了 insert/delete/update
                [self.collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if (removedIndexes.count) {
                        [self.collectionView deleteItemsAtIndexPaths:[removedIndexes xy_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if (insertedIndexes.count) {
                        [self.collectionView insertItemsAtIndexPaths:[insertedIndexes xy_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if (changedIndexes.count) {
                        [self.collectionView reloadItemsAtIndexPaths:[changedIndexes xy_indexPathsFromIndexesWithSection:0]];
                    }
                } completion:NULL];
            }
            
            [self resetCachedAssets];
        }
    });
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.results.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XYPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:XYPhotoCollectionDataSourceCellReuseIdentifier forIndexPath:indexPath];
    PHAsset *asset = self.results[indexPath.row];
	[cell setAsset:asset atIndexPath:indexPath inCollectionView:self.collectionView withCacheManager:_imageManager];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	
	// 单一选择时，无需查看大图
	BOOL isSingleSelected = [XYPhotoSelectedAssetManager sharedManager].maxNumberOfAssets == 1;
	if (isSingleSelected && [[XYPhotoSelectedAssetManager sharedManager].delegate respondsToSelector:@selector(doneSelectingAssets)]) {
		if ([[XYPhotoSelectedAssetManager sharedManager] addSelectedAsset:self.results[indexPath.row]]) {
			[[XYPhotoSelectedAssetManager sharedManager].delegate doneSelectingAssets];
		}
	} else if ([self.delegate respondsToSelector:@selector(assetCollectionDataSource:selectedIndex:inFetchResult:)]) {
		[self.delegate assetCollectionDataSource:self selectedIndex:indexPath.row inFetchResult:self.results];
	}
}

#pragma mark - Notification

- (void)selectedAssetsChanged
{
	if (!self.collectionView.window) {
		[self.collectionView reloadData];
	}
}

@end
