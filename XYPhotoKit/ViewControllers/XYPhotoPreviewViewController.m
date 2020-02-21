//
//  XYPhotoPreviewViewController.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 31/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoPreviewViewController.h"
#import "XYPhotoPreviewOverlayView.h"
#import "XYPhotoHorizontalScrollItemView.h"

@interface XYPhotoPreviewViewController ()<PHPhotoLibraryChangeObserver, XYPhotoHorizontalScrollViewDelegate, XYPhotoHorizontalScrollViewDataSource, XYPhotoPreviewOverlayViewDelegate, XYPhotoHorizontalScrollItemViewDelegate>
{
	XYPhotoHorizontalScrollView *_scrollView;
	XYPhotoPreviewOverlayView *_overLayView;
	BOOL _navigationBarHiddenBeforeEnter;
}
@end

@implementation XYPhotoPreviewViewController

- (void)dealloc
{
	[[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)setFetchResult:(PHFetchResult *)fetchResult
{
	_fetchResult = fetchResult;
	// 查看某个相册大图，则需要观察lib变化
	if (fetchResult) {
		[[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
	}
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
	_selectedIndex = selectedIndex;
//    self.disableBackGesture = selectedIndex!=0;
	if (_scrollView) {
		[_scrollView setCurrentIndex:_selectedIndex animated:NO];
		[_overLayView updateSelectedAsset:_fetchResult ? _fetchResult[selectedIndex]:_photos[selectedIndex]];
		[_overLayView updateTitleAtIndex:_selectedIndex sum:_fetchResult ? _fetchResult.count:_photos.count];
	}
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
	return UIStatusBarAnimationFade;
}

- (void)loadView
{
	[super loadView];
	self.view.backgroundColor = [UIColor blackColor];
	self.view.clipsToBounds = YES;
	
	_scrollView = [[XYPhotoHorizontalScrollView alloc] initWithFrame:CGRectMake(-5, 0, self.view.frame.size.width+10, self.view.frame.size.height)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	_scrollView.backgroundColor = [UIColor blackColor];
	_scrollView.horizontalDelegate = self;
	_scrollView.horizontalDataSource = self;
	[self.view addSubview:_scrollView];
	
	_overLayView = [[XYPhotoPreviewOverlayView alloc] initWithFrame:self.view.bounds];
	_overLayView.delegate = self;
	[self.view addSubview:_overLayView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	_navigationBarHiddenBeforeEnter = self.navigationController.isNavigationBarHidden;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	[self.navigationController setNavigationBarHidden:_navigationBarHiddenBeforeEnter animated:animated];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[_scrollView reloadData];
	[self setSelectedIndex:_selectedIndex];
}

#pragma mark - BPHorizontalScrollViewDataSource & BPHorizontalScrollViewDelegate
- (XYHorizontalScrollItemView *)horizontalScrollView:(XYPhotoHorizontalScrollView *)scroller itemViewForIndex:(NSInteger)index
{
	XYPhotoHorizontalScrollItemView *view = (XYPhotoHorizontalScrollItemView *)[scroller dequeueReusableItemView];
	if (!view) {
		view = [[XYPhotoHorizontalScrollItemView alloc] initWithFrame:scroller.bounds];
		view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		view.photokitDelegate = self;
	}
	view.frame = scroller.bounds;
	view.asset = _fetchResult ? _fetchResult[index] : _photos[index];
	return (XYHorizontalScrollItemView *)view;
}

- (NSInteger)numberOfItems
{
	return _fetchResult ? _fetchResult.count : _photos.count;
}

- (void)horizontalScrollView:(XYPhotoHorizontalScrollView *)scroller didSelectIndex:(NSInteger)index
{
	_selectedIndex = index;
//    self.disableBackGesture = index!=0;
	PHAsset *asset = _fetchResult ? _fetchResult[index] : _photos[index];
	[_overLayView updateSelectedAsset:asset];
	[_overLayView updateTitleAtIndex:_selectedIndex sum:_fetchResult ? _fetchResult.count:_photos.count];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
	// 后台线程更新检查
	dispatch_async(dispatch_get_main_queue(), ^{
		
		// assets 被修改了 (增、删、改)
		PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.fetchResult];
		if (collectionChanges) {
			self.fetchResult = [collectionChanges fetchResultAfterChanges];
			if (_selectedIndex>=self.fetchResult.count) {
				_selectedIndex = self.fetchResult.count-1;
			}
			[_overLayView updateSelectedAsset:self.fetchResult[_selectedIndex]];
			[_scrollView reloadData];
			_scrollView.currentIndex = _selectedIndex;
		}
	});
}

#pragma mark - XYPhotoPreviewOverlayViewDelegate

- (void)previewOverlayView:(XYPhotoPreviewOverlayView *)view closeBarButtonItemClick:(UIBarButtonItem *)barbuttonItem
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - XYPhotoSelectedAssetPreviewViewDelegate

- (void)assetsSelectedPreviewView:(XYPhotoSelectedAssetPreviewView *)previewView didClickWithIndex:(NSInteger)index asset:(PHAsset *)asset
{
	if (_fetchResult) {
		[_fetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			if ([obj.localIdentifier isEqualToString:asset.localIdentifier]) {
				[self setSelectedIndex:idx];
				*stop = YES;
			}
		}];
	} else if ([_photos containsObject:asset]) {
		[self setSelectedIndex:[_photos indexOfObject:asset]];
	}
}

#pragma mark - XYPhotoHorizontalScrollItemView

- (void)didTapped:(XYPhotoHorizontalScrollItemView *)scrollItemView;
{
	[UIView animateWithDuration:0.3 animations:^{
		_overLayView.alpha = _overLayView.alpha<=0 ? 1:0;
	}];
}

@end
