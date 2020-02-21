//
//  XYPhotoPreviewOverlayView.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 06/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoPreviewOverlayView.h"
#import "XYPhotoSelectedAssetManager.h"
#import "XYPhotoDataCategory.h"

@interface XYPhotoPreviewOverlayView()
{
	UIButton *_rightButton;
	UINavigationItem *_navBarItem;
	PHAsset *_asset;
}
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, strong) XYPhotoSelectedAssetPreviewView *previewView;

@end

@implementation XYPhotoPreviewOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		
		_navBarItem = [[UINavigationItem alloc] initWithTitle:@"照片预览"];
		_rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_rightButton setImage:[UIImage xy_imageWithName:@"cl_photo_picker_unpicked"] forState:UIControlStateNormal];
		[_rightButton setImage:[UIImage xy_imageWithName:@"cl_photo_picker_picked"] forState:UIControlStateSelected];
		[_rightButton addTarget:self action:@selector(selectedStateChanged) forControlEvents:UIControlEventTouchUpInside];
		_rightButton.selected = NO;
		
		UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
		_navBarItem.rightBarButtonItem = rightBarButtonItem;
		UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close:)];
		_navBarItem.leftBarButtonItem = leftBarButtonItem;
		
		_navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 44)];
		_navBar.barTintColor = [UIColor whiteColor];
		[_navBar setBackgroundImage:[UIImage xy_imageWithColor:[UIColor colorWithWhite:0 alpha:0.5]] forBarMetrics:UIBarMetricsDefault];
		[_navBar setShadowImage:[UIImage xy_imageWithColor:[UIColor clearColor]]];
		[_navBar setItems:@[_navBarItem]];
		_navBar.tintColor = [UIColor whiteColor];
		[_navBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
		[self addSubview:_navBar];
		
		UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 10)];
		topView.image = [UIImage xy_imageWithColor:[UIColor colorWithWhite:0 alpha:0.5]];
		[self addSubview:topView];
		
		_previewView = [[XYPhotoSelectedAssetPreviewView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-60, self.frame.size.width, 60)];
		_previewView.delegate = _delegate;
		_previewView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
		[self addSubview:_previewView];
	}
	return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *touchView = [super hitTest:point withEvent:event];
	return touchView==self ? nil : touchView;
}

- (void)setDelegate:(id<XYPhotoPreviewOverlayViewDelegate>)delegate
{
	_delegate = delegate;
	_previewView.delegate = delegate;
}

- (void)updateTitleAtIndex:(NSInteger)index sum:(NSInteger)sum
{
	_navBarItem.title = [NSString stringWithFormat:@"%zd / %zd",index+1,sum];
	NSMutableAttributedString *firstAtt = [[NSMutableAttributedString alloc] initWithString:@(index+1).stringValue
																				 attributes:@{
																							  NSForegroundColorAttributeName:[UIColor colorWithWhite:0.9 alpha:1],
																							  NSFontAttributeName:[UIFont boldSystemFontOfSize:17]
																							  }];
	NSAttributedString *secondAtt = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" / %zd",sum]
																	attributes:@{
																				 NSForegroundColorAttributeName:[UIColor colorWithWhite:0.9 alpha:1],
																				 NSFontAttributeName:[UIFont systemFontOfSize:14]
																				 }];
	[firstAtt appendAttributedString:secondAtt];
	
	UILabel *label = [[UILabel alloc] init];
	label.attributedText = firstAtt;
	_navBarItem.titleView = label;
}

#pragma amrk - actions

- (void)selectedStateChanged
{
	if (_rightButton.selected) {
		[[XYPhotoSelectedAssetManager sharedManager] removeSelectedAsset:_asset];
		_rightButton.selected = NO;
	} else if ([[XYPhotoSelectedAssetManager sharedManager] addSelectedAsset:_asset]) {
		_rightButton.selected = YES;
	}
}

- (void)close:(UIBarButtonItem *)item
{
	if ([self.delegate respondsToSelector:@selector(previewOverlayView:closeBarButtonItemClick:)]) {
		[self.delegate previewOverlayView:self closeBarButtonItemClick:item];
	}
}

#pragma mark - private

- (void)updateSelectedAsset:(PHAsset *)asset
{
	_asset = asset;
	_rightButton.selected = [[XYPhotoSelectedAssetManager sharedManager].selectedAssets containsObject:asset];
	[_previewView scrollToAssetIfNeed:asset];
}

@end
