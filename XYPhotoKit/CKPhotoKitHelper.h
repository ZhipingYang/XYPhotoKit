//
//  CKPhotoKitHelper.h
//  XYPhotoKitDemo-iOS
//
//  Created by XcodeYang on 12/10/14.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

@import UIKit;


CG_INLINE CGSize
CGSizeScale(CGSize size, CGFloat scale) {
	return CGSizeMake(size.width * scale, size.height * scale);
}

@interface CKPhotoKitHelper : NSObject

//通知名字
FOUNDATION_EXPORT const struct CKPhotoMultiImagePickerNotifications {
    // asset 添加或删除.
    __unsafe_unretained NSString *assetsChanged;
	// 成功删除
	__unsafe_unretained NSString *assetsDeleted;
	// 成功添加
	__unsafe_unretained NSString *assetsAdded;

} CKPhotoMultiImagePickerNotifications;


FOUNDATION_EXPORT const struct CKPhotoImagePickerName {
	__unsafe_unretained NSString *selectAnAlbum;
	__unsafe_unretained NSString *cameraRoll;
} CKPhotoImagePickerName;


+ (BOOL)isAvailableAccessPhoto;

+ (BOOL)isAuthorizedAccessPhoto;

+ (BOOL)isAvailableAccessCamera;

+ (BOOL)isAuthorizedAccessCamera;


@end


