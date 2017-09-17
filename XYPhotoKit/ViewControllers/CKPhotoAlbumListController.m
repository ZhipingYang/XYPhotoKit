//
//  CKPhotoAlbumListController.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CKPhotoAlbumListController.h"
#import "CKPhotoDataCategory.h"
#import "CKPhotoTableDataSource.h"
#import "CKPhotoAlbumDetailController.h"
#import "CKPhotoSelectedAssetManager.h"
#import "CKPhotoKitHelper.h"
#import "CKPhotoMultiImagePicker.h"

@interface CKPhotoAlbumListController () <CKPhotoTableDataSourceDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CKPhotoTableDataSource *dataSource;

@end

@implementation CKPhotoAlbumListController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = CKPhotoImagePickerName.selectAnAlbum;
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
	self.navigationItem.rightBarButtonItems = @[cancel];
	
	[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
			if (status == PHAuthorizationStatusAuthorized) {
				[self initTableViewAndData];
			} else {
				[self showPhotoAccessHelpView];
			}
		});
	}];
}

- (void)initTableViewAndData
{
	if (!self.tableView) {
		self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		[self.view addSubview:self.tableView];
		self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
		NSDictionary *layoutViews = @{ @"tableView": self.tableView };
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|"
																		  options:0
																		  metrics:nil
																			views:layoutViews]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|"
																		  options:0
																		  metrics:nil
																			views:layoutViews]];
	}
	
	self.dataSource = [[CKPhotoTableDataSource alloc] initWithTableView:self.tableView];
	self.dataSource.delegate = self;
}

- (void)showPhotoAccessHelpView
{
	[UIAlertController xy_showAlertPhotoSettingIfUnauthorized];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage xy_imageWithName:@"cl_photo_picker_inaccessible"]];
	imageView.frame = self.view.bounds;
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.view addSubview:imageView];
}

- (void)close
{
	CKPhotoMultiImagePicker *picker = (CKPhotoMultiImagePicker *)self.navigationController;
	
	if ([picker.pickerDelegate respondsToSelector:@selector(multiImagePickerDidCancel:)]) {
		[picker.pickerDelegate multiImagePickerDidCancel:picker];
	} else {
		[self.navigationController dismissViewControllerAnimated:YES completion:^{
			[[CKPhotoSelectedAssetManager sharedManager] resetManager];
		}];
	}
}

#pragma mark - CKPhotoTableDataSourceDelegate

- (void)assetTableDataSource:(CKPhotoTableDataSource *)dataSource selectedAssetCollection:(PHAssetCollection *)assetCollection
{
    PHFetchResult *fetchResult = [PHFetchResult xy_fetchResultWithAssetCollection:assetCollection mediaType:[CKPhotoSelectedAssetManager sharedManager].mediaType];
    CKPhotoAlbumDetailController *assetsViewController = [[CKPhotoAlbumDetailController alloc] initWithFetchResult:fetchResult];
    assetsViewController.title = assetCollection.localizedTitle;
    [self.navigationController pushViewController:assetsViewController animated:YES];
}

@end
