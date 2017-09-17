//
//  CKPhotoCameraController.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 13/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CKPhotoCameraController.h"
#import "CKPhotoCameraOverlayView.h"
#import "CKPhotoDataCategory.h"
#import "CKPhotoPreviewViewController.h"
#import "CKPhotoMultiCameraPicker.h"
#import "CKPhotoSelectedAssetManager.h"

@interface CKPhotoCameraController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, CKPhotoCameraOverlayViewDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) CKPhotoCameraOverlayView *overlayView;

@end

@implementation CKPhotoCameraController

- (void)loadView
{
	[super loadView];
	self.view.backgroundColor = [UIColor blackColor];
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		if ([UIAlertController xy_showAlertCameraSettingIfUnauthorized]) {
			self.imagePicker = [[UIImagePickerController alloc] init];
			self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			self.imagePicker.delegate = self;
			self.imagePicker.showsCameraControls = NO;
			[self.view addSubview:self.imagePicker.view];
			[self addChildViewController:self.imagePicker];
			[self.imagePicker didMoveToParentViewController:self];
		}
	} else {
        [UIAlertController xy_showTitle:nil message:@"该设备不支持相机功能"];
	}
	
	_overlayView = [[CKPhotoCameraOverlayView alloc] initWithFrame:self.view.bounds];
	_overlayView.delegate = self;
	_overlayView.flashMode = UIImagePickerControllerCameraFlashModeAuto;
	_overlayView.cameraDeivce = UIImagePickerControllerCameraDeviceRear;
	[self.view addSubview:_overlayView];
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
	[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
		[PHAssetChangeRequest creationRequestForAssetFromImage:[info valueForKey:UIImagePickerControllerOriginalImage]];
	} completionHandler:^(BOOL success, NSError * _Nullable error) {
		if (success) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				PHAsset *asset = [PHAsset xy_getTheCloestAsset];
                dispatch_async(dispatch_get_main_queue(), ^{
					[[CKPhotoSelectedAssetManager sharedManager] addSelectedAsset:asset];
				});
			});
		} else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIAlertController xy_showTitle:nil message:@"获取照片失败"];
			});
		}
	}];
}

#pragma mark - CKPhotoCameraOverlayViewDelegate

- (void)cameraOverlayView:(CKPhotoCameraOverlayView *)overlayView didShutted:(UIButton *)sender
{
	// 限制保护
	CKPhotoSelectedAssetManager *manager = [CKPhotoSelectedAssetManager sharedManager];
	if (manager.maxNumberOfAssets != 0 && manager.maxNumberOfAssets <= manager.selectedAssets.count) {
		NSString *tip = manager.maxNumberLimitText.xy_isEmpty ? @"已达到最大照片数限制" : manager.maxNumberLimitText;
        [UIAlertController xy_showTitle:nil message:tip];
		return;
	}
	
	[_imagePicker takePicture];
	
	UIView *flashView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[flashView setBackgroundColor:[UIColor whiteColor]];
	[self.view insertSubview:flashView belowSubview:_overlayView];
	[UIView animateWithDuration:.4f animations:^{
		[flashView setAlpha:0.f];
	} completion:^(BOOL finished){
		[flashView removeFromSuperview];
	}];
}

- (void)cameraOverlayView:(CKPhotoCameraOverlayView *)overlayView didSwitchedCameraDeivce:(UIImagePickerControllerCameraDevice)cameraDeivce
{
	[_imagePicker setCameraDevice:cameraDeivce];
}

- (void)cameraOverlayView:(CKPhotoCameraOverlayView *)overlayView didSwitchedFlashMode:(UIImagePickerControllerCameraFlashMode)flashMode
{
	[_imagePicker setCameraFlashMode:flashMode];
}

- (void)canceledCameraOverlayView:(CKPhotoCameraOverlayView *)overlayView
{
	CKPhotoMultiCameraPicker *picker = (CKPhotoMultiCameraPicker *)self.navigationController;
	
	if ([picker.pickerDelegate respondsToSelector:@selector(multiCameraPickerDidCancel:)]) {
		[picker.pickerDelegate multiCameraPickerDidCancel:picker];
	} else {
		[self dismissViewControllerAnimated:YES completion:^{
			[[CKPhotoSelectedAssetManager sharedManager] resetManager];
		}];
	}
}

- (void)finishedCameraOverlayView:(CKPhotoCameraOverlayView *)overlayView
{
	if ([[CKPhotoSelectedAssetManager sharedManager].delegate respondsToSelector:@selector(doneSelectingAssets)]) {
		[[CKPhotoSelectedAssetManager sharedManager].delegate doneSelectingAssets];
	}
}

- (void)assetsSelectedPreviewView:(CKPhotoSelectedAssetPreviewView *)previewView didClickWithIndex:(NSInteger)index asset:(PHAsset *)asset
{
	CKPhotoPreviewViewController *previewController = [[CKPhotoPreviewViewController alloc] init];
	previewController.photos = [CKPhotoSelectedAssetManager sharedManager].selectedAssets;
	previewController.selectedIndex = index;
	[self.navigationController pushViewController:previewController animated:YES];
}


@end
