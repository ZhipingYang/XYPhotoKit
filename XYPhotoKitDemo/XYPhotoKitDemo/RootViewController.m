//
//  ViewController.m
//  CLPhotoKitDemo
//
//  Created by XcodeYang on 30/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "RootViewController.h"
#import "XYPhotoMultiCameraPicker.h"
#import "XYPhotoMultiImagePicker.h"
#import "XYDemoCollectionViewCell.h"

@interface RootViewController ()<XYPhotoMultiImagePickerDelegate, XYPhotoMultiImagePickerDataSource,
								XYPhotoMultiCameraPickerDelegate, XYPhotoMultiCameraPickerDataSource,
								UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *mediaType;
@property (weak, nonatomic) IBOutlet UITextField *maxNumber;
@property (weak, nonatomic) IBOutlet UITextField *columnNumber;
@property (weak, nonatomic) IBOutlet UISegmentedControl *startFrom;
@property (weak, nonatomic) IBOutlet UISwitch *iCloudRequest;

@property (nonatomic, strong) NSArray<PHAsset *> *selectedAssets;

@end

@implementation RootViewController

- (void)showCameraPicker
{
	XYPhotoMultiCameraPicker *camera = [[XYPhotoMultiCameraPicker alloc] init];
	camera.pickerDelegate = self;
	camera.pickerDataSource = self;
	camera.maxNumberOfAssets = [self.maxNumber.text integerValue];
	camera.allowNetRequestIfiCloud = self.iCloudRequest.on;
	[self presentViewController:camera animated:YES completion:nil];
}

- (void)showImagePicker
{
	XYPhotoMultiImagePicker *multiImagePicker = [[XYPhotoMultiImagePicker alloc] init];
	multiImagePicker.pickerDelegate = self;
	multiImagePicker.pickerDataSource = self;
	
	switch (self.mediaType.selectedSegmentIndex) {
		case 0: multiImagePicker.mediaType = PHAssetMediaTypeImage; break;
		case 1: multiImagePicker.mediaType = PHAssetMediaTypeVideo; break;
		default: multiImagePicker.mediaType = PHAssetMediaTypeUnknown; break;
	}
	
	multiImagePicker.maxNumberOfAssets = [self.maxNumber.text integerValue];
	multiImagePicker.assetCollectionViewColumnCount = self.columnNumber.text.integerValue;
	multiImagePicker.startPosition = self.startFrom.selectedSegmentIndex==0 ? CLPhotoMultiPickerStartPositionAlbums : CLPhotoMultiPickerStartPositionCameraRoll;
	multiImagePicker.allowNetRequestIfiCloud = self.iCloudRequest.on;
	[self presentViewController:multiImagePicker animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.row==0 && indexPath.section==0) {
		[self showImagePicker];
	} else if(indexPath.row==1 && indexPath.section==0) {
		[self showCameraPicker];
	}
}

#pragma mark - XYPhotoMultiCameraPickerDelegate, XYPhotoMultiCameraPickerDataSource

- (void)multiCameraPicker:(XYPhotoMultiCameraPicker *)multiImagePicker selectedAssets:(NSArray<PHAsset *> *)assets
{
	_selectedAssets = assets.copy;
	[self.collectionView reloadData];
	NSLog(@"%@",assets);
}

- (NSArray<PHAsset *> *)multiCameraPickerLoadPresetSelectedAssets
{
    return _selectedAssets;
}

#pragma mark - XYPhotoMultiImagePickerDelegate, XYPhotoMultiImagePickerDataSource

- (void)multiImagePicker:(XYPhotoMultiImagePicker *)multiImagePicker selectedAssets:(NSArray<PHAsset *> *)assets
{
	_selectedAssets = assets;
	[self.collectionView reloadData];
	NSLog(@"%@", @(assets.count));
	for (PHAsset *asset in assets) {
		NSLog(@"%@", asset);
	}
}

- (NSArray<PHAsset *> *)multiImagePickerLoadPresetSelectedAssets
{
	return _selectedAssets;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _selectedAssets.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	XYDemoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XYDemoCollectionViewCell class]) forIndexPath:indexPath];
	if (indexPath.row == _selectedAssets.count) {
		cell.imageVew.image = [UIImage imageNamed:@"add"];
	} else {
		PHAsset *asset = _selectedAssets[indexPath.row];
		[[PHImageManager defaultManager] requestImageForAsset:asset
												   targetSize:CGSizeMake(160, 160)
												  contentMode:PHImageContentModeAspectFill
													  options:nil
												resultHandler:^(UIImage *result, NSDictionary *info) {
													cell.imageVew.image = result;
												}];
	}
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	if (indexPath.row == _selectedAssets.count) {
		UIAlertController *alrt = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
		[alrt addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
		[alrt addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			[self showCameraPicker];
		}]];
		[alrt addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			[self showImagePicker];
		}]];
		[self presentViewController:alrt animated:YES completion:nil];
	}
}

@end


