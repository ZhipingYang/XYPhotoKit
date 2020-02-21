//
//  XYPhotoCameraController.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 13/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoCameraController.h"
#import "XYPhotoCameraOverlayView.h"
#import "XYPhotoDataCategory.h"
#import "XYPhotoPreviewViewController.h"
#import "XYPhotoMultiCameraPicker.h"
#import "XYPhotoSelectedAssetManager.h"

@interface XYPhotoCameraController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, XYPhotoCameraOverlayViewDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) XYPhotoCameraOverlayView *overlayView;

@end

@implementation XYPhotoCameraController

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
	
	_overlayView = [[XYPhotoCameraOverlayView alloc] initWithFrame:self.view.bounds];
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
					[[XYPhotoSelectedAssetManager sharedManager] addSelectedAsset:asset];
				});
			});
		} else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIAlertController xy_showTitle:nil message:@"获取照片失败"];
			});
		}
	}];
}

#pragma mark - XYPhotoCameraOverlayViewDelegate

- (void)cameraOverlayView:(XYPhotoCameraOverlayView *)overlayView didShutted:(UIButton *)sender
{
	// 限制保护
	XYPhotoSelectedAssetManager *manager = [XYPhotoSelectedAssetManager sharedManager];
	if (manager.maxNumberOfAssets != 0 && manager.maxNumberOfAssets <= manager.selectedAssets.count) {
		NSString *tip = manager.maxNumberLimitText.xy_isEmpty ? @"已达到最大照片数限制" : manager.maxNumberLimitText;
        [UIAlertController xy_showTitle:nil message:tip];
		return;
	}
	
	[_imagePicker takePicture];
	
	UIView *flashView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if (@available(iOS 13.0, *)) {
        [flashView setBackgroundColor:[UIColor systemBackgroundColor]];
    } else {
        [flashView setBackgroundColor:[UIColor whiteColor]];
    }
	[self.view insertSubview:flashView belowSubview:_overlayView];
	[UIView animateWithDuration:.4f animations:^{
		[flashView setAlpha:0.f];
	} completion:^(BOOL finished){
		[flashView removeFromSuperview];
	}];
}

- (void)cameraOverlayView:(XYPhotoCameraOverlayView *)overlayView didSwitchedCameraDeivce:(UIImagePickerControllerCameraDevice)cameraDeivce
{
	[_imagePicker setCameraDevice:cameraDeivce];
}

- (void)cameraOverlayView:(XYPhotoCameraOverlayView *)overlayView didSwitchedFlashMode:(UIImagePickerControllerCameraFlashMode)flashMode
{
	[_imagePicker setCameraFlashMode:flashMode];
}

- (void)canceledCameraOverlayView:(XYPhotoCameraOverlayView *)overlayView
{
	XYPhotoMultiCameraPicker *picker = (XYPhotoMultiCameraPicker *)self.navigationController;
	
	if ([picker.pickerDelegate respondsToSelector:@selector(multiCameraPickerDidCancel:)]) {
		[picker.pickerDelegate multiCameraPickerDidCancel:picker];
	} else {
		[self dismissViewControllerAnimated:YES completion:^{
			[[XYPhotoSelectedAssetManager sharedManager] resetManager];
		}];
	}
}

- (void)finishedCameraOverlayView:(XYPhotoCameraOverlayView *)overlayView
{
	if ([[XYPhotoSelectedAssetManager sharedManager].delegate respondsToSelector:@selector(doneSelectingAssets)]) {
		[[XYPhotoSelectedAssetManager sharedManager].delegate doneSelectingAssets];
	}
}

- (void)assetsSelectedPreviewView:(XYPhotoSelectedAssetPreviewView *)previewView didClickWithIndex:(NSInteger)index asset:(PHAsset *)asset
{
	XYPhotoPreviewViewController *previewController = [[XYPhotoPreviewViewController alloc] init];
	previewController.photos = [XYPhotoSelectedAssetManager sharedManager].selectedAssets;
	previewController.selectedIndex = index;
	[self.navigationController pushViewController:previewController animated:YES];
}


@end
