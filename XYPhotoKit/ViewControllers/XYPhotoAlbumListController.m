//
//  XYPhotoAlbumListController.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoAlbumListController.h"
#import "XYPhotoDataCategory.h"
#import "XYPhotoTableDataSource.h"
#import "XYPhotoAlbumDetailController.h"
#import "XYPhotoSelectedAssetManager.h"
#import "XYPhotoKitHelper.h"
#import "XYPhotoMultiImagePicker.h"

@interface XYPhotoAlbumListController () <XYPhotoTableDataSourceDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) XYPhotoTableDataSource *dataSource;

@end

@implementation XYPhotoAlbumListController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = XYPhotoImagePickerName.selectAnAlbum;
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    }
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
        self.tableView.translatesAutoresizingMaskIntoConstraints = false;
		[self.view addSubview:self.tableView];
    }
    
    self.dataSource = [[XYPhotoTableDataSource alloc] initWithTableView:self.tableView];
    self.dataSource.delegate = self;
    
    [NSLayoutConstraint activateConstraints:@[
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];
}

- (void)showPhotoAccessHelpView
{
	[UIAlertController xy_showAlertPhotoSettingIfUnauthorized];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage xy_imageWithName:@"cl_photo_picker_inaccessible"]];
    imageView.translatesAutoresizingMaskIntoConstraints = false;
	imageView.contentMode = UIViewContentModeCenter;
	[self.view addSubview:imageView];
    
    [NSLayoutConstraint activateConstraints:@[
        [imageView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [imageView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [imageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [imageView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];
}

- (void)close
{
	XYPhotoMultiImagePicker *picker = (XYPhotoMultiImagePicker *)self.navigationController;
	
	if ([picker.pickerDelegate respondsToSelector:@selector(multiImagePickerDidCancel:)]) {
		[picker.pickerDelegate multiImagePickerDidCancel:picker];
	} else {
		[self.navigationController dismissViewControllerAnimated:YES completion:^{
			[[XYPhotoSelectedAssetManager sharedManager] resetManager];
		}];
	}
}

#pragma mark - XYPhotoTableDataSourceDelegate

- (void)assetTableDataSource:(XYPhotoTableDataSource *)dataSource selectedAssetCollection:(PHAssetCollection *)assetCollection
{
    PHFetchResult *fetchResult = [PHFetchResult xy_fetchResultWithAssetCollection:assetCollection mediaType:XYPhotoSelectedAssetManager.sharedManager.mediaType];
    XYPhotoAlbumDetailController *assetsViewController = [[XYPhotoAlbumDetailController alloc] initWithFetchResult:fetchResult];
    assetsViewController.title = assetCollection.localizedTitle;
    [self.navigationController pushViewController:assetsViewController animated:YES];
}

@end
