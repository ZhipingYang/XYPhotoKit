//
//  XYPhotoAlbumDetailController.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoAlbumDetailController.h"

#import "XYPhotoCollectionDataSource.h"
#import "XYPhotoCollectionFlowLayout.h"
#import "XYPhotoSelectedAssetPreviewView.h"
#import "XYPhotoSelectedAssetManager.h"
#import "XYPhotoMultiImagePicker.h"
#import "XYPhotoPreviewViewController.h"

@interface XYPhotoAlbumDetailController ()<XYPhotoSelectedAssetPreviewViewDelegate, XYPhotoCollectionDataSourceDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) XYPhotoSelectedAssetPreviewView *bottomView;

@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) XYPhotoCollectionDataSource *dataSource;

@end

@implementation XYPhotoAlbumDetailController

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
	
	self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:[[XYPhotoCollectionFlowLayout alloc] init]];
    if (@available(iOS 13.0, *)) {
        self.collectionView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.collectionView.backgroundColor = [UIColor whiteColor];
    }
	self.collectionView.allowsMultipleSelection = YES;
	[self.view addSubview:self.collectionView];
	
	self.bottomView = [[XYPhotoSelectedAssetPreviewView alloc] initWithFrame:self.view.frame];
	self.bottomView.delegate = self;
	[self.view addSubview:self.bottomView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self addConstrains];
	
	// 等loadView完成后调用
	self.dataSource = [[XYPhotoCollectionDataSource alloc] initWithCollectionView:self.collectionView fetchResult:self.fetchResult];
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
	
	BOOL isSingleSelected = [XYPhotoSelectedAssetManager sharedManager].maxNumberOfAssets == 1;
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
	XYPhotoMultiImagePicker *picker = (XYPhotoMultiImagePicker *)self.navigationController;
	
	if ([picker.pickerDelegate respondsToSelector:@selector(multiImagePickerDidCancel:)]) {
		[picker.pickerDelegate multiImagePickerDidCancel:picker];
	} else {
		[self.navigationController dismissViewControllerAnimated:YES completion:^{
			[[XYPhotoSelectedAssetManager sharedManager] resetManager];
		}];
	}
}

#pragma mark - XYPhotoSelectedAssetPreviewViewDelegate

- (void)assetsSelectedPreviewView:(XYPhotoSelectedAssetPreviewView *)previewView didClickWithIndex:(NSInteger)index asset:(PHAsset *)asset;
{
	XYPhotoPreviewViewController *previewController = [[XYPhotoPreviewViewController alloc] init];
	previewController.photos = [XYPhotoSelectedAssetManager sharedManager].selectedAssets;
	previewController.selectedIndex = index;
	[self.navigationController pushViewController:previewController animated:YES];
}

#pragma mark - XYPhotoCollectionDataSourceDelegate

- (void)assetCollectionDataSource:(XYPhotoCollectionDataSource *)dataSource selectedIndex:(NSInteger)selectedIndex inFetchResult:(PHFetchResult *)fetchResult
{
	XYPhotoPreviewViewController *previewController = [[XYPhotoPreviewViewController alloc] init];
	previewController.fetchResult = fetchResult;
	previewController.selectedIndex = selectedIndex;
	[self.navigationController pushViewController:previewController animated:YES];
}

@end
