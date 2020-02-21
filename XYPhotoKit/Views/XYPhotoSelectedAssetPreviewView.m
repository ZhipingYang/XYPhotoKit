//
//  XYPhotoSelectedAssetPreviewView..m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 30/08/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoSelectedAssetPreviewView.h"
#import "XYPhotoCollectionFlowLayout.h"
#import "XYPhotoSelectedAssetManager.h"
#import "XYPhotoBottomPreviewCell.h"
#import "XYPhotoKitHelper.h"
#import "XYPhotoDataCategory.h"

@interface XYPhotoSelectedAssetPreviewView ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
	NSInteger _currentIndex;
}
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) UILabel *badgeLabel;

@end

@implementation XYPhotoSelectedAssetPreviewView

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self initBaseViews];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedAssetsChanged) name:XYPhotoMultiImagePickerNotifications.assetsChanged object:nil];
		// 用于初始化
		self.assetArray = [XYPhotoSelectedAssetManager sharedManager].selectedAssets;
		// 用于调整collection的cell布局（意义性不大，本可以忽略但是这边要保留，等同于`setAssetArray:`**不要去除这片脏代码**）
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			_assetArray = [XYPhotoSelectedAssetManager sharedManager].selectedAssets;
			_doneButton.enabled = _assetArray.count>0;
			_badgeLabel.text = @(_assetArray.count).stringValue;
			[_collectionView reloadData];
		});
    }
    return self;
}

- (void)initBaseViews
{
	self.backgroundColor = [UIColor darkGrayColor];
	
	XYPhotoCollectionFlowLayout *layout = [[XYPhotoCollectionFlowLayout alloc] init];
	layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	
	// 预览已选择的assets
	self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
	[self.collectionView registerClass:[XYPhotoBottomPreviewCell class] forCellWithReuseIdentifier:NSStringFromClass([XYPhotoBottomPreviewCell class])];
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.alwaysBounceHorizontal = YES;
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;
	[self addSubview:self.collectionView];
	self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
	
	// 完成按钮
	self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.doneButton setBackgroundImage:[UIImage xy_imageWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
	[self.doneButton setBackgroundImage:[UIImage xy_imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
	self.doneButton.enabled = NO;
	self.doneButton.layer.cornerRadius = 4;
	self.doneButton.clipsToBounds = YES;
	self.doneButton.titleLabel.font = [UIFont systemFontOfSize:14];
	[self.doneButton setTitle:@"完成" forState:UIControlStateNormal];
	[self.doneButton addTarget:[XYPhotoSelectedAssetManager sharedManager].delegate action:@selector(doneSelectingAssets) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.doneButton];
	self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
	
	// 徽标
	self.badgeLabel = [[UILabel alloc] init];
	self.badgeLabel.text = @"0";
	self.badgeLabel.backgroundColor = [UIColor whiteColor];
	self.badgeLabel.textAlignment = NSTextAlignmentCenter;
	self.badgeLabel.font = [UIFont systemFontOfSize:8];
	self.badgeLabel.textColor = [UIColor blueColor];
	self.badgeLabel.layer.cornerRadius = 9;
	self.badgeLabel.clipsToBounds = YES;
	[self addSubview:self.badgeLabel];
	self.badgeLabel.translatesAutoresizingMaskIntoConstraints = NO;

	self.hideControls = NO;
}

- (void)setAssetArray:(NSArray<PHAsset *> *)assetArray
{
	_assetArray = assetArray;
	_doneButton.enabled = assetArray.count>0;
	_badgeLabel.text = @(assetArray.count).stringValue;
	[_collectionView reloadData];
	
	// 添加完成滚动到最后一个
	if (assetArray.count>0) {
		[self setCurrentIndex:assetArray.count - 1];
	}
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
	// 无符号与有符号比较出现bug ((NSInteger)-1) > ((NSUInteger)2)
	_currentIndex = currentIndex>=(NSInteger)_assetArray.count ? (_assetArray.count-1) : currentIndex;
	[_collectionView reloadData];
	
	if (_currentIndex>=0) {
		[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]
								atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
										animated:YES];
	}
}

- (void)setHideControls:(BOOL)hideControls
{
	_hideControls = hideControls;
	_doneButton.hidden = hideControls;
	_badgeLabel.hidden = hideControls;
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	
	if (_hideControls) {
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[view]-8-|" options:0 metrics:nil views:@{ @"view": _collectionView }]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[view]-8-|" options:0 metrics:nil views:@{ @"view": _collectionView }]];
		
	} else {
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[view]-8-|" options:0 metrics:nil views:@{ @"view": _collectionView }]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[view]-80-|" options:0 metrics:nil views:@{ @"view": _collectionView }]];
		
		// centerY与父视图居中
		NSDictionary *doneButtonLayoutInfo = @{ @"view": _doneButton, @"subview": _doneButton.superview };
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view]-(<=1)-[subview]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:doneButtonLayoutInfo]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(55)]-10-|" options:0 metrics:nil views:doneButtonLayoutInfo]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(30)]" options:0 metrics:nil views:doneButtonLayoutInfo]];
		
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(18)]-6-|" options:0 metrics:nil views:@{@"label":self.badgeLabel}]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(18)]-(-10)-[button]" options:0 metrics:nil views:@{@"label":self.badgeLabel, @"button":self.doneButton}]];
	}
	[self layoutIfNeeded];
}

- (void)scrollToAssetIfNeed:(PHAsset *)asset
{
	if ([[XYPhotoSelectedAssetManager sharedManager].selectedAssets containsObject:asset]) {
		NSInteger index = [[XYPhotoSelectedAssetManager sharedManager].selectedAssets indexOfObject:asset];
		[self setCurrentIndex:index];
	} else {
		[self setCurrentIndex:-1];
	}
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	XYPhotoSelectedAssetManager *manager = [XYPhotoSelectedAssetManager sharedManager];
	if (manager.maxNumberOfAssets==0 || self.assetArray.count<manager.maxNumberOfAssets) {
		// 添加一个占位图
		return self.assetArray.count+1;
	} else {
		return self.assetArray.count;
	}
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	XYPhotoBottomPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XYPhotoBottomPreviewCell class]) forIndexPath:indexPath];
	XYPhotoSelectedAssetManager *manager = [XYPhotoSelectedAssetManager sharedManager];
	if ((manager.maxNumberOfAssets == 0 || self.assetArray.count < manager.maxNumberOfAssets) && indexPath.row == self.assetArray.count) {
		cell.imageView.image = [UIImage xy_imageWithName:@"cl_photokit_placeholder"];
	} else {
		PHAsset *asset = self.assetArray[indexPath.row];
		[cell setAsset:asset indexPath:indexPath collectionView:self.collectionView];
	}
	cell.highlighted = indexPath.row == _currentIndex;
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	// 占位点击
	if (indexPath.row>=self.assetArray.count) {
		return;
	}
	
	if ([self.delegate respondsToSelector:@selector(assetsSelectedPreviewView:didClickWithIndex:asset:)]) {
		[self.delegate assetsSelectedPreviewView:self didClickWithIndex:indexPath.row asset:self.assetArray[indexPath.row]];
	}
	_currentIndex = indexPath.row;
	[_collectionView reloadData];
}

#pragma mark - Notification

- (void)selectedAssetsChanged
{
	self.assetArray = [XYPhotoSelectedAssetManager sharedManager].selectedAssets;
	[self.collectionView reloadData];
}

@end
