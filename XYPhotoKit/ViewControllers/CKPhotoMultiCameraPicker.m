//
//  CKPhotoMultiCameraPicker.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 08/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CKPhotoMultiCameraPicker.h"
#import "CKPhotoSelectedAssetManager.h"
#import "CKPhotoCameraController.h"

@interface CKPhotoMultiCameraPicker ()<CKPhotoSelectedAssetManagerDelegate>

@end

@implementation CKPhotoMultiCameraPicker

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self setViewControllers:@[[[CKPhotoCameraController alloc] init]] animated:NO];
		self.allowNetRequestIfiCloud = NO;
		[[CKPhotoSelectedAssetManager sharedManager] resetManager];
		[CKPhotoSelectedAssetManager sharedManager].mediaType = PHAssetMediaTypeImage;
		[CKPhotoSelectedAssetManager sharedManager].delegate = self;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// 不能在初始化的时候调用此方法，需CKPhotoSelectedAssetManager的各个参数设置完毕后执行，即set方法执行完毕
	if ([self.pickerDataSource respondsToSelector:@selector(multiCameraPickerLoadPresetSelectedAssets)]) {
		[[CKPhotoSelectedAssetManager sharedManager] resetSelectedAsset:[self.pickerDataSource multiCameraPickerLoadPresetSelectedAssets]];
	}
}

- (void)setMaxNumberOfAssets:(NSUInteger)maxNumberOfAssets
{
	_maxNumberOfAssets = maxNumberOfAssets;
	[CKPhotoSelectedAssetManager sharedManager].maxNumberOfAssets = maxNumberOfAssets;
}

- (void)setAllowNetRequestIfiCloud:(BOOL)allowNetRequestIfiCloud
{
	_allowNetRequestIfiCloud = allowNetRequestIfiCloud;
	[CKPhotoSelectedAssetManager sharedManager].allowNetRequestIfiCloud = allowNetRequestIfiCloud;
}

#pragma mark - CKPhotoSelectedAssetManagerDelegate

- (void)doneSelectingAssets
{
	if ([self.pickerDelegate respondsToSelector:@selector(multiCameraPicker:selectedAssets:)]) {
		[self.pickerDelegate multiCameraPicker:self selectedAssets:[CKPhotoSelectedAssetManager sharedManager].selectedAssets];
	}
	
	[self dismissViewControllerAnimated:YES completion:^{
		[[CKPhotoSelectedAssetManager sharedManager] resetManager];
	}];
}

@end
