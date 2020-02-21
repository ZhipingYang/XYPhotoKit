//
//  XYPhotoKitDemo.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoMultiImagePicker.h"

#import "XYPhotoDataCategory.h"
#import "XYPhotoAlbumListController.h"
#import "XYPhotoCollectionViewCell.h"
#import "XYPhotoAlbumDetailController.h"
#import "XYPhotoKitHelper.h"
#import "XYPhotoSelectedAssetManager.h"

@interface XYPhotoMultiImagePicker ()<XYPhotoSelectedAssetManagerDelegate>

@end

@implementation XYPhotoMultiImagePicker

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init]) {
		[self setViewControllers:@[[[XYPhotoAlbumListController alloc] init]] animated:NO];
		[[XYPhotoSelectedAssetManager sharedManager] resetManager];
		[XYPhotoSelectedAssetManager sharedManager].delegate = self;
		self.allowNetRequestIfiCloud = NO;
		self.navigationBar.tintColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if ([XYPhotoKitHelper isAvailableAccessPhoto]) {
		[self setupView];
	}
	
	// 不能在初始化的时候调用此方法，需XYPhotoSelectedAssetManager的各个参数设置完毕后执行，即set方法执行完毕
	if ([self.pickerDataSource respondsToSelector:@selector(multiImagePickerLoadPresetSelectedAssets)]) {
		[[XYPhotoSelectedAssetManager sharedManager] resetSelectedAsset:[self.pickerDataSource multiImagePickerLoadPresetSelectedAssets]];
	}
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[XYPhotoSelectedAssetManager sharedManager].delegate = nil;
}

#pragma mark - Setup

- (void)setupView
{
	if (self.startPosition == CLPhotoMultiPickerStartPositionCameraRoll) {
		PHFetchResult *fetchResult = [PHFetchResult xy_fetchResultWithAssetsOfType:self.mediaType];
		XYPhotoAlbumDetailController *cameraRollViewController = [[XYPhotoAlbumDetailController alloc] initWithFetchResult:fetchResult];
		cameraRollViewController.title = XYPhotoImagePickerName.cameraRoll;
		NSMutableArray *vcs = self.viewControllers.mutableCopy;
		[vcs addObject:cameraRollViewController];
		[self setViewControllers:vcs animated:NO];
	}
}

#pragma mark - Values passed to the manager.

- (void)setMaxNumberOfAssets:(NSUInteger)maxNumberOfAssets
{
    _maxNumberOfAssets = maxNumberOfAssets;
    [XYPhotoSelectedAssetManager sharedManager].maxNumberOfAssets = maxNumberOfAssets;
}

- (void)setMediaType:(PHAssetMediaType)mediaType
{
    _mediaType = mediaType;
    [XYPhotoSelectedAssetManager sharedManager].mediaType = mediaType;
}

- (void)setAssetCollectionViewColumnCount:(NSInteger)assetCollectionViewColumnCount
{
    _assetCollectionViewColumnCount = assetCollectionViewColumnCount;
    [XYPhotoSelectedAssetManager sharedManager].assetCollectionViewColumnCount = assetCollectionViewColumnCount;
}

- (void)setAllowNetRequestIfiCloud:(BOOL)allowNetRequestIfiCloud
{
	_allowNetRequestIfiCloud = allowNetRequestIfiCloud;
	[XYPhotoSelectedAssetManager sharedManager].allowNetRequestIfiCloud = allowNetRequestIfiCloud;
}

#pragma mark - XYPhotoSelectedAssetManagerDelegate

- (void)doneSelectingAssets
{
	if ([self.pickerDelegate respondsToSelector:@selector(multiImagePicker:selectedAssets:)]) {
		[self.pickerDelegate multiImagePicker:self selectedAssets:[[XYPhotoSelectedAssetManager sharedManager] selectedAssets]];
	}
	[self dismissViewControllerAnimated:YES completion:^{
		[[XYPhotoSelectedAssetManager sharedManager] resetManager];
	}];
}

@end
