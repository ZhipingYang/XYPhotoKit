//
//  CKPhotoTableDataSource.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CKPhotoTableDataSource.h"

#import "CKPhotoTableCell.h"
#import "CKPhotoSelectedAssetManager.h"
#import "CKPhotoDataCategory.h"

@interface CKPhotoTableDataSource () <PHPhotoLibraryChangeObserver, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray <PHFetchResult *> *collectionFetchResults;
@property (nonatomic) NSArray <NSArray <PHAssetCollection *> *> *collectionArrays;

@end

@implementation CKPhotoTableDataSource

NS_ENUM(NSInteger, CLPhotoAlbumDataSourceType) {
    CLPhotoAlbumDataSourceTypeAlbums = 0,
    CLPhotoAlbumDataSourceTypeTopLevelUserCollections = 1,
    
    CLPhotoAlbumDataSourceTypeCount = 2
};

- (void)dealloc
{
	[[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (instancetype)initWithTableView:(UITableView *)tableView
{
    if (self = [super init]) {
        _tableView = tableView;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = CLPhotoCollectionCellRowHeight;
        [_tableView registerClass:[CKPhotoTableCell class] forCellReuseIdentifier:CKPhotoTableCellReuseIdentifier];
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
				
                PHFetchResult <PHAssetCollection *> *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                 subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                                 options:nil];
                //获取用户的相册集合
				PHFetchResult <PHCollection *> *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
                
                _collectionFetchResults = @[albums, topLevelUserCollections];
                
                [self updateCollectionArrays];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableView reloadData];
                });
                
                [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
            } else {
				[UIAlertController xy_showAlertPhotoSettingIfUnauthorized];
            }
        }];
    }
    return self;
}

- (void)updateCollectionArrays
{
    PHFetchResult <PHAssetCollection *> *albums = self.collectionFetchResults[CLPhotoAlbumDataSourceTypeAlbums];
    NSMutableArray *albumsWithAssetsArray = [NSMutableArray arrayWithCapacity:albums.count];
    [albums enumerateObjectsUsingBlock:^(PHAssetCollection *obj, NSUInteger idx, BOOL *stop) {
        PHFetchResult *assetsInCollection = [PHFetchResult xy_fetchResultWithAssetCollection:obj mediaType:[CKPhotoSelectedAssetManager sharedManager].mediaType];
        if (assetsInCollection.count > 0 && assetsInCollection.count < NSNotFound) {
            [albumsWithAssetsArray addObject:obj];
        }
    }];
    
    PHFetchResult <PHCollection *> *topLevelUserCollections = self.collectionFetchResults[CLPhotoAlbumDataSourceTypeTopLevelUserCollections];
    NSMutableArray *topLevelUserCollectionsWithAssetsArray = [NSMutableArray arrayWithCapacity:topLevelUserCollections.count];
    [topLevelUserCollections enumerateObjectsUsingBlock:^(PHCollection *obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[PHAssetCollection class]]) {
			PHFetchResult *assetsInCollection = [PHFetchResult xy_fetchResultWithAssetCollection:(PHAssetCollection *)obj mediaType:[CKPhotoSelectedAssetManager sharedManager].mediaType];
			if (assetsInCollection.count > 0 && assetsInCollection.count < NSNotFound) {
				[topLevelUserCollectionsWithAssetsArray addObject:obj];
			}
		}
    }];
    
    self.collectionArrays = @[albumsWithAssetsArray, topLevelUserCollectionsWithAssetsArray];
}

- (PHAssetCollection *)assetCollectionForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *fetchResults = self.collectionArrays[indexPath.section];
    return fetchResults[indexPath.row];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_block_t dispatchBlock = ^{
        NSMutableArray *updatedCollectionsFetchResults = nil;
        
        for (PHFetchResult *collectionsFetchResult in self.collectionFetchResults) {
			if (collectionsFetchResult.count<=0) {
				continue;
			}
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails) {
                if (!updatedCollectionsFetchResults) {
                    updatedCollectionsFetchResults = [self.collectionFetchResults mutableCopy];
                }
                [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
            }
        }
        
        if (updatedCollectionsFetchResults) {
            self.collectionFetchResults = updatedCollectionsFetchResults;
            [self updateCollectionArrays];
            [self.tableView reloadData];
        }
    };
    
    if ([NSThread currentThread] != [NSThread mainThread]) {
        dispatch_async(dispatch_get_main_queue(), dispatchBlock);
    } else {
        dispatchBlock();
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return CLPhotoAlbumDataSourceTypeCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.collectionArrays[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKPhotoTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CKPhotoTableCellReuseIdentifier forIndexPath:indexPath];
	cell.collection = [self assetCollectionForIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHAssetCollection *assetCollection = [self assetCollectionForIndexPath:indexPath];
	if ([self.delegate respondsToSelector:@selector(assetTableDataSource:selectedAssetCollection:)]) {
		[self.delegate assetTableDataSource:self selectedAssetCollection:assetCollection];
	}
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
