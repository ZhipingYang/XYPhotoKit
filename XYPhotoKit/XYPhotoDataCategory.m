//
//  CLPhotoDataCategory.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 30/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoDataCategory.h"

@import AVFoundation;
@import Photos;

@implementation NSString (CLPhotoKit)

- (BOOL)xy_isEmpty
{
    NSString *tempStr = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([tempStr length] == 0 || [self isEqualToString:@"NULL"] || [self isEqualToString:@"null"] || [self isEqualToString:@"(null)"]) {
        return YES;
    }
    return NO;
}

@end

@implementation NSIndexSet (CLPhotoKit)

- (NSArray *)xy_indexPathsFromIndexesWithSection:(NSUInteger)section
{
	NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
	}];
	return indexPaths;
}

@end


@implementation PHFetchResult (CLPhotoKit)

+ (instancetype)xy_fetchResultWithAssetCollection:(PHAssetCollection *)assetCollection mediaType:(PHAssetMediaType)type
{
	PHFetchOptions *fetchOptions = [PHFetchOptions new];
	
	if (type != PHAssetMediaTypeUnknown) {
		fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %@", @(type)];
	}
	
	fetchOptions.sortDescriptors = @[[self xy_creationDateSortDescriptor]];
	return [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
}

+ (instancetype)xy_fetchResultWithAssetsOfType:(PHAssetMediaType)type
{
	PHFetchOptions *fetchOptions = [PHFetchOptions new];
	fetchOptions.sortDescriptors = @[[self xy_creationDateSortDescriptor]];
	
	if (type != PHAssetMediaTypeUnknown) {
		return [PHAsset fetchAssetsWithMediaType:type options:fetchOptions];
	}
	return [PHAsset fetchAssetsWithOptions:fetchOptions];
}

+ (NSSortDescriptor *)xy_creationDateSortDescriptor
{
	return [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
}

@end


@implementation UICollectionView (CLPhotoKit)

- (NSArray *)xy_indexPathsForElementsInRect:(CGRect)rect
{
	NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
	if (!allLayoutAttributes.count) {
		return nil;
	}
	
	NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
	for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
		NSIndexPath *indexPath = layoutAttributes.indexPath;
		[indexPaths addObject:indexPath];
	}
	return indexPaths;
}

@end

@implementation UIAlertController (CLPhotoKit)

+ (BOOL)xy_showAlertPhotoSettingIfUnauthorized
{
    PHAuthorizationStatus photoStatus = PHPhotoLibrary.authorizationStatus;
	if (photoStatus == PHAuthorizationStatusRestricted || photoStatus == PHAuthorizationStatusDenied) {
		NSString *mes = photoStatus==PHAuthorizationStatusDenied ? @"该功能需要相册服务，你可以在设置中打开对App的相册服务":@"该设备的相册功能被限制了";
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:mes preferredStyle:UIAlertControllerStyleAlert];
		[alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
		if (photoStatus == PHAuthorizationStatusDenied) {
			[alertController addAction:[UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
			}]];
		}
		[[UIApplication sharedApplication].xy_topViewController presentViewController:alertController animated:YES completion:nil];
		return NO;
	}
	return YES;
}

+ (BOOL)xy_showAlertCameraSettingIfUnauthorized
{
	AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	if (videoStatus==AVAuthorizationStatusDenied || videoStatus==AVAuthorizationStatusRestricted) {
		NSString *mes = videoStatus==AVAuthorizationStatusDenied ? @"该功能需要相机服务，你可以在设置中打开对App的相机服务":@"该应用的相机功能被限制了";
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:mes preferredStyle:UIAlertControllerStyleAlert];
		[alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
		if (videoStatus == AVAuthorizationStatusDenied) {
			[alertController addAction:[UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
			}]];
		}
		[[UIApplication sharedApplication].xy_topViewController presentViewController:alertController animated:YES completion:nil];
		return NO;
	}
	return YES;
}

+ (void)xy_showTitle:(NSString *)title message:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleCancel handler:nil]];
    [[UIApplication sharedApplication].xy_topViewController presentViewController:alert animated:YES completion:nil];
}

@end

@implementation UIImage (CLPhotoKit)

+ (UIImage *)xy_imageWithName:(NSString *)imageName
{
	UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"XYPhotoKit.bundle/image/%@",imageName]];
	return image;
}

+ (UIImage *)xy_imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@implementation UIApplication (CLPhotoKit)

- (UIViewController *)xy_topViewController
{
    UIViewController *rootController = [[[UIApplication sharedApplication].delegate window] rootViewController];
    
    while (rootController.presentedViewController!=nil || [rootController isKindOfClass:[UINavigationController class]]) {
        if (rootController.presentedViewController!=nil) {
            rootController = rootController.presentedViewController;
        }
        if ([rootController isKindOfClass:[UINavigationController class]]) {
            rootController = [[(UINavigationController *)rootController viewControllers] lastObject];
        }
    }
    return rootController;
}

@end

@implementation PHAsset (CLPhotoKit)

+ (nullable PHAsset *)xy_getTheCloestAsset
{
	PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
	fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
	PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
	return [fetchResult lastObject];
}

//- (UIImage *)xy_getImageSize:(CGSize)size
//{
//	return nil;
//}
//
//- (UIImage *)xy_getThumbnailWithSize:(CGSize)size
//{
//	return nil;
//}
//
//- (UIImage *)xy_getOriginImage
//{
//	return nil;
//}
//
//- (UIImage *)xy_getImageWithSize:(CGSize)size iCloud:(BOOL)iCould
//{
//	return nil;
//}

@end
