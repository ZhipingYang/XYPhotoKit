//
//  XYPhotoKitDemo.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CKPhotoMultiImagePicker.h"

#import "CKPhotoDataCategory.h"
#import "CKPhotoAlbumListController.h"
#import "CKPhotoCollectionViewCell.h"
#import "CKPhotoAlbumDetailController.h"
#import "CKPhotoKitHelper.h"
#import "CKPhotoSelectedAssetManager.h"

@interface CKPhotoMultiImagePicker ()<CKPhotoSelectedAssetManagerDelegate>

@end

@implementation CKPhotoMultiImagePicker

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init]) {
		[self setViewControllers:@[[[CKPhotoAlbumListController alloc] init]] animated:NO];
		[[CKPhotoSelectedAssetManager sharedManager] resetManager];
		[CKPhotoSelectedAssetManager sharedManager].delegate = self;
		self.allowNetRequestIfiCloud = NO;
		self.navigationBar.tintColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if ([CKPhotoKitHelper isAvailableAccessPhoto]) {
		[self setupView];
	}
	
	// 不能在初始化的时候调用此方法，需CKPhotoSelectedAssetManager的各个参数设置完毕后执行，即set方法执行完毕
	if ([self.pickerDataSource respondsToSelector:@selector(multiImagePickerLoadPresetSelectedAssets)]) {
		[[CKPhotoSelectedAssetManager sharedManager] resetSelectedAsset:[self.pickerDataSource multiImagePickerLoadPresetSelectedAssets]];
	}
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[CKPhotoSelectedAssetManager sharedManager].delegate = nil;
}

#pragma mark - Setup

- (void)setupView
{
	if (self.startPosition == CLPhotoMultiPickerStartPositionCameraRoll) {
		PHFetchResult *fetchResult = [PHFetchResult xy_fetchResultWithAssetsOfType:self.mediaType];
		CKPhotoAlbumDetailController *cameraRollViewController = [[CKPhotoAlbumDetailController alloc] initWithFetchResult:fetchResult];
		cameraRollViewController.title = CKPhotoImagePickerName.cameraRoll;
		NSMutableArray *vcs = self.viewControllers.mutableCopy;
		[vcs addObject:cameraRollViewController];
		[self setViewControllers:vcs animated:NO];
	}
}

#pragma mark - Values passed to the manager.

- (void)setMaxNumberOfAssets:(NSUInteger)maxNumberOfAssets
{
    _maxNumberOfAssets = maxNumberOfAssets;
    [CKPhotoSelectedAssetManager sharedManager].maxNumberOfAssets = maxNumberOfAssets;
}

- (void)setMediaType:(PHAssetMediaType)mediaType
{
    _mediaType = mediaType;
    [CKPhotoSelectedAssetManager sharedManager].mediaType = mediaType;
}

- (void)setAssetCollectionViewColumnCount:(NSInteger)assetCollectionViewColumnCount
{
    _assetCollectionViewColumnCount = assetCollectionViewColumnCount;
    [CKPhotoSelectedAssetManager sharedManager].assetCollectionViewColumnCount = assetCollectionViewColumnCount;
}

- (void)setAllowNetRequestIfiCloud:(BOOL)allowNetRequestIfiCloud
{
	_allowNetRequestIfiCloud = allowNetRequestIfiCloud;
	[CKPhotoSelectedAssetManager sharedManager].allowNetRequestIfiCloud = allowNetRequestIfiCloud;
}

#pragma mark - CKPhotoSelectedAssetManagerDelegate

- (void)doneSelectingAssets
{
	if ([self.pickerDelegate respondsToSelector:@selector(multiImagePicker:selectedAssets:)]) {
		[self.pickerDelegate multiImagePicker:self selectedAssets:[[CKPhotoSelectedAssetManager sharedManager] selectedAssets]];
	}
	[self dismissViewControllerAnimated:YES completion:^{
		[[CKPhotoSelectedAssetManager sharedManager] resetManager];
	}];
}

@end
