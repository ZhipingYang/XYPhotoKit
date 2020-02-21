//
//  XYPhotoKitHelper.m
//  XYPhotoKitDemo-iOS
//
//  Created by XcodeYang on 30/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//
#import "XYPhotoKitHelper.h"

@import AssetsLibrary;
@import AVFoundation;

@implementation XYPhotoKitHelper

const struct XYPhotoMultiImagePickerNotifications XYPhotoMultiImagePickerNotifications = {
    .assetsChanged = @"XYPhotoMultiImagePickerNotificationAssetsChanged",
	.assetsDeleted = @"XYPhotoMultiImagePickerNotificationAssetsDeleted",
	.assetsAdded = @"XYPhotoMultiImagePickerNotificationAssetsAdded",
};

const struct XYPhotoImagePickerName XYPhotoImagePickerName = {
	.selectAnAlbum = @"相册列表",
	.cameraRoll = @"Camera Roll",
};

+ (BOOL)isAvailableAccessPhoto
{
	ALAuthorizationStatus photoStatus = [ALAssetsLibrary authorizationStatus];
	return photoStatus == ALAuthorizationStatusAuthorized || photoStatus == ALAuthorizationStatusNotDetermined;
}

+ (BOOL)isAuthorizedAccessPhoto
{
	ALAuthorizationStatus photoStatus = [ALAssetsLibrary authorizationStatus];
	return photoStatus == ALAuthorizationStatusAuthorized;
}

+ (BOOL)isAvailableAccessCamera
{
	AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	BOOL hasCamera = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
	return hasCamera && (videoStatus == AVAuthorizationStatusAuthorized || videoStatus == AVAuthorizationStatusNotDetermined);
}

+ (BOOL)isAuthorizedAccessCamera
{
	AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	BOOL hasCamera = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
	return hasCamera && videoStatus == AVAuthorizationStatusAuthorized;
}

@end
