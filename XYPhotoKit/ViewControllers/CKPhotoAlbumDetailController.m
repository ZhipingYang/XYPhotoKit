//
//  CKPhotoAlbumDetailController.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CKPhotoAlbumDetailController.h"

#import "CKPhotoCollectionDataSource.h"
#import "CKPhotoCollectionFlowLayout.h"
#import "CKPhotoSelectedAssetPreviewView.h"
#import "CKPhotoSelectedAssetManager.h"
#import "CKPhotoMultiImagePicker.h"
#import "CKPhotoPreviewViewController.h"

@interface CKPhotoAlbumDetailController ()<CKPhotoSelectedAssetPreviewViewDelegate, CKPhotoCollectionDataSourceDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CKPhotoSelectedAssetPreviewView *bottomView;

@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) CKPhotoCollectionDataSource *dataSource;

@end

@implementation CKPhotoAlbumDetailController

- (instancetype)initWithFetchResult:(PHFetchResult *)fetchResult
{
    if (self = [super init]) {
        _fetchResult = fetchResult;
    }
    return self;
}

- (void)loadView
{
	[super loadView];
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
	self.navigationItem.rightBarButtonItems = @[cancel];
	
	self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:[[CKPhotoCollectionFlowLayout alloc] init]];
	self.collectionView.backgroundColor = [UIColor whiteColor];
	self.collectionView.allowsMultipleSelection = YES;
	[self.view addSubview:self.collectionView];
	
	self.bottomView = [[CKPhotoSelectedAssetPreviewView alloc] initWithFrame:self.view.frame];
	self.bottomView.delegate = self;
	[self.view addSubview:self.bottomView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self addConstrains];
	
	// 等loadView完成后调用
	self.dataSource = [[CKPhotoCollectionDataSource alloc] initWithCollectionView:self.collectionView fetchResult:self.fetchResult];
	self.dataSource.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
    self.dataSource.shouldCache = YES;
}

- (void)addConstrains
{
	self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
	self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
	
	BOOL isSingleSelected = [CKPhotoSelectedAssetManager sharedManager].maxNumberOfAssets == 1;
	if (isSingleSelected) {
		NSDictionary *layoutViews = @{ @"collectionView": self.collectionView };
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:layoutViews]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:layoutViews]];
	} else {
		NSDictionary *layoutViews = @{ @"collectionView": self.collectionView };
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]-60-|" options:0 metrics:nil views:layoutViews]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:layoutViews]];
		
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomview]|" options:0 metrics:nil views:@{@"bottomview":self.bottomView}]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomview(60)]|" options:0 metrics:nil views:@{@"bottomview":self.bottomView}]];
	}
	self.bottomView.hidden = isSingleSelected;
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

#pragma mark - CKPhotoSelectedAssetPreviewViewDelegate

- (void)assetsSelectedPreviewView:(CKPhotoSelectedAssetPreviewView *)previewView didClickWithIndex:(NSInteger)index asset:(PHAsset *)asset;
{
	CKPhotoPreviewViewController *previewController = [[CKPhotoPreviewViewController alloc] init];
	previewController.photos = [CKPhotoSelectedAssetManager sharedManager].selectedAssets;
	previewController.selectedIndex = index;
	[self.navigationController pushViewController:previewController animated:YES];
}

#pragma mark - CKPhotoCollectionDataSourceDelegate

- (void)assetCollectionDataSource:(CKPhotoCollectionDataSource *)dataSource selectedIndex:(NSInteger)selectedIndex inFetchResult:(PHFetchResult *)fetchResult
{
	CKPhotoPreviewViewController *previewController = [[CKPhotoPreviewViewController alloc] init];
	previewController.fetchResult = fetchResult;
	previewController.selectedIndex = selectedIndex;
	[self.navigationController pushViewController:previewController animated:YES];
}

@end
