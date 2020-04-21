//
//  XYPhotoMultiCameraPicker.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 08/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoMultiCameraPicker.h"
#import "XYPhotoSelectedAssetManager.h"
#import "XYPhotoCameraController.h"

@interface XYPhotoMultiCameraPicker ()<XYPhotoSelectedAssetManagerDelegate>

@end

@implementation XYPhotoMultiCameraPicker

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.allowNetRequestIfiCloud = false;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        [self setViewControllers:@[[[XYPhotoCameraController alloc] init]] animated:NO];
		[[XYPhotoSelectedAssetManager sharedManager] resetManager];
		[XYPhotoSelectedAssetManager sharedManager].mediaType = PHAssetMediaTypeImage;
		[XYPhotoSelectedAssetManager sharedManager].delegate = self;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// 不能在初始化的时候调用此方法，需XYPhotoSelectedAssetManager的各个参数设置完毕后执行，即set方法执行完毕
	if ([self.pickerDataSource respondsToSelector:@selector(multiCameraPickerLoadPresetSelectedAssets)]) {
		[[XYPhotoSelectedAssetManager sharedManager] resetSelectedAsset:[self.pickerDataSource multiCameraPickerLoadPresetSelectedAssets]];
	}
}

- (void)setMaxNumberOfAssets:(NSUInteger)maxNumberOfAssets
{
	_maxNumberOfAssets = maxNumberOfAssets;
	[XYPhotoSelectedAssetManager sharedManager].maxNumberOfAssets = maxNumberOfAssets;
}

- (void)setAllowNetRequestIfiCloud:(BOOL)allowNetRequestIfiCloud
{
	_allowNetRequestIfiCloud = allowNetRequestIfiCloud;
	[XYPhotoSelectedAssetManager sharedManager].allowNetRequestIfiCloud = allowNetRequestIfiCloud;
}

#pragma mark - XYPhotoSelectedAssetManagerDelegate

- (void)doneSelectingAssets
{
	if ([self.pickerDelegate respondsToSelector:@selector(multiCameraPicker:selectedAssets:)]) {
		[self.pickerDelegate multiCameraPicker:self selectedAssets:[XYPhotoSelectedAssetManager sharedManager].selectedAssets];
	}
	
	[self dismissViewControllerAnimated:YES completion:^{
		[[XYPhotoSelectedAssetManager sharedManager] resetManager];
	}];
}

@end
