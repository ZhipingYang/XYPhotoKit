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
	
    XYPhotoCollectionFlowLayout *layout = [[XYPhotoCollectionFlowLayout alloc] init];
	self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = false;
    self.collectionView.allowsMultipleSelection = true;
    [self.view addSubview:self.collectionView];
    
    self.bottomView = [[XYPhotoSelectedAssetPreviewView alloc] initWithFrame:self.view.frame];
    self.bottomView.translatesAutoresizingMaskIntoConstraints = false;
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];

    if (@available(iOS 13.0, *)) {
        self.collectionView.backgroundColor = [UIColor systemBackgroundColor];
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor whiteColor];
    }
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
    self.dataSource.shouldCache = true;
}

- (void)addConstrains
{
	BOOL isSingleSelected = [XYPhotoSelectedAssetManager sharedManager].maxNumberOfAssets == 1;
    self.bottomView.hidden = isSingleSelected;
    
    [NSLayoutConstraint activateConstraints:@[
        [_collectionView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_collectionView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_collectionView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_collectionView.bottomAnchor constraintEqualToAnchor:self.bottomView.topAnchor],
        [_bottomView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_bottomView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_bottomView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [_bottomView.heightAnchor constraintEqualToConstant:isSingleSelected ? 0:60]
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
